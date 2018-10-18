//
//  YLSearchController.h
//  YLClient
//
//  Created by 刘玉娇 on 2018/1/27.
//  Copyright © 2018年 yunli. All rights reserved.
//

#import "BaseEntityController.h"

@protocol YLSearchDelegate <NSObject>

- (void)yl_searchWithId:(NSString*)searchId;

@end

@interface YLSearchController : BaseEntityController

@property (nonatomic, assign) id<YLSearchDelegate> delegate;

@end
