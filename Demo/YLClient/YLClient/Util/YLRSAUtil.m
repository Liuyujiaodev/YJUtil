//
//  YLRSAUtil.m
//  YLClient
//
//  Created by 刘玉娇 on 2018/6/6.
//  Copyright © 2018年 yunli. All rights reserved.
//

#import "YLRSAUtil.h"
#import "Base64.h"
#import <zlib.h>
#import "WXRSASign.h"
#include "openssl/rsa.h"
#include "openssl/pem.h"

#define kPublicDecodeFile [[NSBundle mainBundle] pathForResource:@"public_decode" ofType:@"pem"]
#define kPublicEncodeFile [[NSBundle mainBundle] pathForResource:@"public_encode" ofType:@"pem"]

#define kPublicKey  @"-----BEGIN PUBLIC KEY-----MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0SVurBKmHwQpSgvaL8u0ogmau5z3+hiGzR42nk5o0bG6RQ6dBNfhvVHFgXeGQKIsNTEaZDRbfGE9JWOvoWiF4zVaxb7G4YjtH1+n2vC4XYPaUhlZjTzvu2LZ3NSx3o/SAAtTpAlv+pNymHCrrQoeaBYSuM695cKiigzqaIypuCWPRcDnJIX55vuohGCv/HJTLS3ua03LymsPtZo1JYAJ4j2vAnqmc914gpSeXydVBDFynWx8wo0nAKQoQbp0LsT4xN3OYNFD0jSMso2Jb8jyY7/04qVNpMqYGzuKkTEhyLOGHh40FS3R7NQz6D16hEyJ0nZGL0UeaWm0QhBve0237QIDAQAB-----END PUBLIC KEY-----"

static RSA* rsa;

@implementation YLRSAUtil

//解密入口
+ (NSDictionary*)decodeWithStr:(NSString*)str {
    
    NSData* base64Data = [str base64DecodedData];
    NSData *data1 = [self uncompressZippedData:base64Data];
    NSError* error = nil;
    
    NSArray* array = [[NSJSONSerialization JSONObjectWithData:data1
                                                      options:NSJSONReadingAllowFragments
                                                        error:&error] mutableCopy];
    
    NSMutableString* buffer = [NSMutableString string];
    for (NSString* value in array) {
        
        NSString* newStr = [self decode:value];
        [buffer appendString:newStr];
    }
    NSMutableString* buffer1 = [[buffer base64DecodedString] mutableCopy];
    
    //过滤掉所有的转义字符
    NSString* jsonStr = [buffer1 stringByTrimmingCharactersInSet:[NSCharacterSet controlCharacterSet]];
    NSDictionary* dic;
    if (jsonStr && ![jsonStr isEmptyStr]) {
        dic = [[NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error] mutableCopy];
    }
    

    return dic;
}

//加密入口
+ (NSDictionary*)encodeDic:(NSDictionary*)dic {
//    dic = [NSDictionary dictionaryWithObject:@"a" forKey:@"cuid"];
    NSError *parseError = nil;
    //前端先把数据格式化成json
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString* jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    //base64
    NSString* base64Str = jsonStr.base64EncodedString;
    
    //把base64按照一定长度截取加密放到数组
    NSMutableArray* strArray = [NSMutableArray array];
    while (base64Str.length > 0) {
        NSInteger index = base64Str.length > 100 ? 100 : base64Str.length;
        NSString* tmpStr = [base64Str substringWithRange:NSMakeRange(0, index)];
        //RSA分段加密
        NSString* encodeStr = [self encode:tmpStr];
        [strArray addObject:encodeStr];
        base64Str = [base64Str substringFromIndex:index];
    }
    
    //数组变成字符串
    NSString* finalJsonStr  = [YLUtil jsonStrWithArray:strArray];
    //把数据格式化成json
    NSString* finalBase64Str = finalJsonStr.base64EncodedString;

    return [NSDictionary dictionaryWithObject:finalBase64Str forKey:@"requestData"];
}

+(NSData *)uncompressZippedData:(NSData *)compressedData  {
    if ([compressedData length] == 0) return compressedData;
    unsigned full_length = [compressedData length];
    unsigned half_length = [compressedData length] / 2;
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
    BOOL done = NO;
    int status;
    z_stream strm;
    strm.next_in = (Bytef *)[compressedData bytes];
    strm.avail_in = [compressedData length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
    while (!done) {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length]) {
            [decompressed increaseLengthBy: half_length];
        }
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = [decompressed length] - strm.total_out;
        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) {
            done = YES;
        } else if (status != Z_OK) {
            break;
        }
    }
    if (inflateEnd (&strm) != Z_OK) return nil;
    // Set real length.
    if (done) {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    } else {
        return nil;
    }
}

+ (NSString*)encode:(NSString*)str {
    //公钥和私钥文件
    const char* pub_key = [kPublicEncodeFile UTF8String];
    // 打开私钥文件
    FILE* pub_fp=fopen(pub_key,"r");
    if(pub_fp==NULL){
        printf("Open Failed!! The Priv_Key File :%s!\n", pub_key);
        return @"";
    }
    
    
    // 从文件中读取公钥
    RSA *rsa = PEM_read_RSA_PUBKEY(pub_fp, NULL, NULL, NULL);
    fclose(pub_fp);

    int status;
    int length  = (int)[str length];
    unsigned char input[length + 1];
    bzero(input, length + 1);
    int i = 0;
    for (; i < length; i++)
    {
        input[i] = [str characterAtIndex:i];
    }
    
    NSInteger  flen = RSA_size(rsa) - 11;
    
    char *encData = (char*)malloc(flen);
    bzero(encData, flen);
    status = RSA_public_encrypt(length, (unsigned char*)input, (unsigned char*)encData, rsa, RSA_PKCS1_PADDING);
    
    if (status){
        NSData *returnData = [NSData dataWithBytes:encData length:status];
        free(encData);
        encData = NULL;
        
        //NSString *ret = [returnData base64EncodedString];
        NSString *ret = [returnData base64EncodedStringWithOptions: NSDataBase64Encoding64CharacterLineLength];
        return ret;
    }

    free(encData);
    encData = NULL;
    
    return nil;
}

+ (NSString*)decode:(NSString*)str {
    unsigned char encrypted[1024];
    bzero(encrypted, sizeof(encrypted));
    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:0];
    
    //明文
    char decrypted[1024];
    //公钥和私钥文件
    const char* pub_key = [kPublicDecodeFile UTF8String];
    // 打开私钥文件
    FILE* pub_fp=fopen(pub_key,"r");
    if(pub_fp==NULL){
        printf("Open Failed!! The Priv_Key File :%s!\n", pub_key);
        return @"";
    }
    
    
    // 从文件中读取公钥
    RSA *rsa = PEM_read_RSA_PUBKEY(pub_fp, NULL, NULL, NULL);
    fclose(pub_fp);

    if(rsa==NULL){
        printf("Pub_Key Read Failure!!\n");
        return @"";
    }
    // 用公钥解密
    int state = RSA_size(rsa);
    state = RSA_public_decrypt(state, (unsigned char*)[data bytes], (unsigned char*)decrypted, rsa, RSA_PKCS1_PADDING);
    if(state == -1){
        printf("Decrypt Failed!!\n");
        return @"";
    }
    
    
    // 输出解密后的明文
    decrypted[state]=0;
    NSString *result = [NSString stringWithUTF8String:decrypted];
    NSLog(@"%@",result);
    return result;
}

/*
+ (NSString *)encryptString:(NSString *)str publicKey:(NSString *)pubKey{
    NSData *data = [self encryptData:[str dataUsingEncoding:NSUTF8StringEncoding] publicKey:pubKey];
    NSString *ret = data.base64EncodedString;
    return ret;
}

+ (NSData *)encryptData:(NSData *)data publicKey:(NSString *)pubKey{
    if(!data || !pubKey){
        return nil;
    }
    SecKeyRef keyRef = [self addPublicKey:pubKey];
    if(!keyRef){
        return nil;
    }
    return [self encryptData:data withKeyRef:keyRef];
}

+ (SecKeyRef)addPublicKey:(NSString *)key{
    NSRange spos = [key rangeOfString:@"-----BEGIN PUBLIC KEY-----"];
    NSRange epos = [key rangeOfString:@"-----END PUBLIC KEY-----"];
    if(spos.location != NSNotFound && epos.location != NSNotFound){
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s, e-s);
        key = [key substringWithRange:range];
    }
    key = [key stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@" "  withString:@""];
    
    // This will be base64 encoded, decode it.
    NSData *data = key.base64DecodedData;
    data = [self stripPublicKeyHeader:data];
    if(!data){
        return nil;
    }
    
    //a tag to read/write keychain storage
    NSString *tag = @"RSAUtil_PubKey";
    NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];
    
    // Delete any old lingering key with the same tag
    NSMutableDictionary *publicKey = [[NSMutableDictionary alloc] init];
    [publicKey setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];
    [publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [publicKey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
//    SecItemDelete((__bridge CFDictionaryRef)publicKey);
    
    // Add persistent version of the key to system keychain
    [publicKey setObject:data forKey:(__bridge id)kSecValueData];
    [publicKey setObject:(__bridge id) kSecAttrKeyClassPublic forKey:(__bridge id)
     kSecAttrKeyClass];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)
     kSecReturnPersistentRef];
    
    CFTypeRef persistKey = nil;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)publicKey, &persistKey);
    if (persistKey != nil){
        CFRelease(persistKey);
    }
    if ((status != noErr) && (status != errSecDuplicateItem)) {
        return nil;
    }
    
    [publicKey removeObjectForKey:(__bridge id)kSecValueData];
    [publicKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    // Now fetch the SecKeyRef version of the key
    SecKeyRef keyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)publicKey, (CFTypeRef *)&keyRef);
    if(status != noErr){
        return nil;
    }
    return keyRef;
}

+ (NSData *)encryptData:(NSData *)data withKeyRef:(SecKeyRef) keyRef{
    const uint8_t *srcbuf = (const uint8_t *)[data bytes];
    size_t srclen = (size_t)data.length;
    
    size_t block_size = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
    void *outbuf = malloc(block_size);
    size_t src_block_size = block_size - 11;
    
    NSMutableData *ret = [[NSMutableData alloc] init];
    for(int idx=0; idx<srclen; idx+=src_block_size){
        //NSLog(@"%d/%d block_size: %d", idx, (int)srclen, (int)block_size);
        size_t data_len = srclen - idx;
        if(data_len > src_block_size){
            data_len = src_block_size;
        }
        
        size_t outlen = block_size;
        OSStatus status = noErr;
        status = SecKeyEncrypt(keyRef,
                               kSecPaddingPKCS1,
                               srcbuf + idx,
                               data_len,
                               outbuf,
                               &outlen
                               );
        if (status != 0) {
            NSLog(@"SecKeyEncrypt fail. Error Code: %d", status);
            ret = nil;
            break;
        }else{
            [ret appendBytes:outbuf length:outlen];
        }
    }
    
    free(outbuf);
    CFRelease(keyRef);
    return ret;
}


+ (NSData *)stripPublicKeyHeader:(NSData *)d_key{
    // Skip ASN.1 public key header
    if (d_key == nil) return(nil);
    
    unsigned long len = [d_key length];
    if (!len) return(nil);
    
    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int  idx     = 0;
    
    if (c_key[idx++] != 0x30) return(nil);
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
    // PKCS #1 rsaEncryption szOID_RSA_RSA
    static unsigned char seqiod[] =
    { 0x30,   0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
        0x01, 0x05, 0x00 };
    if (memcmp(&c_key[idx], seqiod, 15)) return(nil);
    
    idx += 15;
    
    if (c_key[idx++] != 0x03) return(nil);
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
    if (c_key[idx++] != '\0') return(nil);
    
    // Now make a new NSData from this buffer
    return ([NSData dataWithBytes:&c_key[idx] length:len - idx]);
}
*/
@end
