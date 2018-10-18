//
//  YLContactPhoneUtil.m
//  YLClient
//
//  Created by 刘玉娇 on 2018/1/25.
//  Copyright © 2018年 yunli. All rights reserved.
//

#import "YLAuthUtil.h"
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
#import <CoreTelephony/CTCellularData.h>

@implementation YLAuthUtil

#pragma mark -
#pragma mark 拿到本地通讯录

+ (BOOL)isGetContactAuth {
    if (iSiOS9) {
        if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {
            return NO;
        }
        return YES;
    } else {
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            return NO;
        }
        return YES;
    }
}

+ (void)reqeustAuth:(void (^)(BOOL granted))completionHandler{
    if (iSiOS9) {
        CNContactStore* store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            completionHandler(granted);
        }];
    } else {
        ABAddressBookRef bookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRequestAccessWithCompletion(bookRef, ^(bool granted, CFErrorRef error) {
            completionHandler(granted);
        });
    }
}

+ (YLAuthUtilStatus)getContactStatus {
    if (iSiOS9) {
        CNContactStore* store = [[CNContactStore alloc] init];
        if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusRestricted || [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusDenied) {
            return YLAuthUtilStatusDefined;
        } else if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) {
            return YLAuthUtilStatusAuthed;
        } else {
            return YLAuthUtilStatusNotDetermined;
        }
    } else {
        __block BOOL authorizedToAccess = NO;
        
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            return YLAuthUtilStatusAuthed;
        } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            return YLAuthUtilStatusNotDetermined;
        }
        else  {
            return YLAuthUtilStatusDefined;
        }
    }
}

+ (void)sendContactsToServer:(NSArray*)contactsArray success:(sendContactSuccess)success failure:(sendContactFailure)failure {
    //need fix
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:[YLUserDataManager getCuid] forKey:@"cuid"];
    [params setObject:[YLUtil jsonStrWithArray:contactsArray] forKey:@"phoneContacts"];
    [[YLHttpRequest sharedInstance] sendRequest:YL_API_SEND_CONTACT params:params success:^(NSDictionary *dic) {
        DLog(@"=======通讯录发送成功");
        success();
    } requestFailure:^(NSDictionary *dic) {
        
    } failure:^(NSError *error) {
        failure();
    }];
}

+ (void)sendContactSuccess:(sendContactSuccess)success failure:(sendContactFailure)failure {
    NSMutableArray* localContactItems = [NSMutableArray array];

    if (iSiOS9) {
        CNContactStore* store = [[CNContactStore alloc] init];
        CNContactFetchRequest * request = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]];
        [store enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
            NSString* firstName = contact.givenName;
            NSString* lastName = contact.familyName;
            NSArray* phoneNumbers = contact.phoneNumbers;
            for (CNLabeledValue *labeledValue in phoneNumbers) {
                // 2.1.获取电话号码的KEY
                NSString *tag = [self tagStr:labeledValue.label];
                // 2.2.获取电话号码
                CNPhoneNumber *mobile = labeledValue.value;
                NSString *phoneNumber = mobile.stringValue;
                
                NSString* name = [NSString stringWithFormat:@"%@%@", lastName, firstName];
                
                NSDictionary* itemDic = [NSDictionary dictionaryWithObjectsAndKeys:name, @"displayName", phoneNumber, @"iphone", tag, @"tagLabel", nil];
                [localContactItems addObject:itemDic];
            }
        }];
    } else {
        ABAddressBookRef bookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        CFArrayRef allContactsRef = ABAddressBookCopyArrayOfAllPeople(bookRef);
        for (int i = 0; i < CFArrayGetCount(allContactsRef); i++) {
            ABRecordRef contact = CFArrayGetValueAtIndex(allContactsRef, i);
            
            CFTypeRef firstNameRef = ABRecordCopyValue(contact, kABPersonFirstNameProperty);
            CFTypeRef lastNameRef = ABRecordCopyValue(contact, kABPersonLastNameProperty);
            CFTypeRef companyRef = ABRecordCopyValue(contact, kABPersonOrganizationProperty);
            
            NSString* firstName = (firstNameRef == nil) ? @"" : (__bridge NSString*)firstNameRef;
            NSString* lastName = (lastNameRef == nil) ? @"" : (__bridge NSString*)lastNameRef;
            NSString* companyName = (companyRef == nil) ? @"" :(__bridge NSString*)companyRef;
            
            ABMutableMultiValueRef multIPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
            multIPhone = ABRecordCopyValue(contact, kABPersonPhoneProperty);
            
            NSMutableSet* iphones = [NSMutableSet set];
            for (int j = 0; j < ABMultiValueGetCount(multIPhone); j++) {
                CFStringRef numberRef = ABMultiValueCopyValueAtIndex(multIPhone, j);
                CFStringRef label = ABMultiValueCopyLabelAtIndex(multIPhone, j);
                
                NSString *moblie = [NSString stringWithFormat:@"%@", numberRef];
                NSString *tagLabel = [NSString stringWithFormat:@"%@", label];

                [iphones addObject:[NSDictionary dictionaryWithObjectsAndKeys:moblie,@"phone",tagLabel,@"tagLabel", nil]];
            }
            
            if ([iphones count] == 0)
                continue;
            
            for (NSDictionary* iphoneDic in iphones) {
                NSString* iphone = [iphoneDic objectForKey:@"phone"];
                NSString* tag = [self tagStr:[iphoneDic objectForKey:@"tagLabel"]];

                NSString* phoneNumber = [[[iphone stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@" (" withString:@""] stringByReplacingOccurrencesOfString:@") " withString:@""];
                phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
                phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
                phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
                
                NSString* name = [NSString stringWithFormat:@"%@%@", lastName, firstName];
                if ([name isEqualToString:@""]) {
                    if ([companyName isEqualToString:@""]) {
                        name = phoneNumber;
                    } else if (![companyName isEqualToString:@""]) {
                        name = companyName;
                    }
                }
                NSDictionary* itemDic = [NSDictionary dictionaryWithObjectsAndKeys:name, @"displayName", phoneNumber, @"iphone", tag, @"tagLabel", nil];
                [localContactItems addObject:itemDic];
            }
        }
    }
    [self sendContactsToServer:localContactItems success:success failure:failure];
}

+(NSString*)tagStr:(NSString*)tag {
    if ([tag containsString:@"HomeFAX"]) {
        return @"家庭传真";
    }
    
    if ([tag containsString:@"WorkFAX"]) {
        return @"工作传真";
    }

    if ([tag containsString:@"Work"]) {
        return @"工作";
    }
    
    if ([tag containsString:@"Home"]) {
        return @"家庭";
    }
    
    if ([tag containsString:@"iPhone"]) {
        return @"iPhone";
    }
    if ([tag containsString:@"Mobile"]) {
        return @"手机";
    }
    
    if ([tag containsString:@"Main"]) {
        return @"主要";
    }

    if ([tag containsString:@"Pager"]) {
        return @"传呼机";
    }
    if ([tag containsString:@"Other"]) {
        return @"其他";
    }
    
    return @"其他";
}

#pragma mark - 定位权限
//-------定位权限----------------
+ (void)requestLocationAuth {
    if ([CLLocationManager locationServicesEnabled]) {
        CLLocationManager* locationMag = [[CLLocationManager alloc] init];
        [locationMag requestWhenInUseAuthorization];  //调用了这句,就会弹出允许框了.
        
    }
}

+ (YLAuthLocationStatus)getLocationStatus {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        return YLAuthLocationStatusNotDetermined;
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        return YLAuthLocationStatusDefined;

    } else {
        return YLAuthLocationStatusAuthed;
    }
}

+(void)isNetDefine:(void (^)(BOOL granted))complete {
    if (@available(iOS 9.0, *)) {
        CTCellularData *cellularData = [[CTCellularData alloc] init];
        cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState state){
            if (state == kCTCellularDataRestricted) {
                complete(YES);
            } else {
                complete(NO);
            }
        };
    }
}
@end
