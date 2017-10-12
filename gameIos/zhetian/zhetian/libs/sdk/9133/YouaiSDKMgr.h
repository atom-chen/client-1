//
//  YouaiSDKMgr.h
//  YouaiSDK
//
//  Created by 莫 东荣 on 13-4-9.
//  Copyright (c) 2013年 莫 东荣. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YouaiSDKMgr : NSObject
{
    NSString* appId_;
    NSString* appKey_;
   
    
    NSString* openId;
    NSString* loginKey;

}

+ (YouaiSDKMgr *)getInstance;
- (void)initSDK;
- (void)openLogin:(NSString *)appId : (NSString *)appKey : (UIViewController *)controller;
- (void)openCenter: (UIViewController *)controller;
- (void)openPay: (NSString *)serverId : (NSString *)nickName : (NSString *)callBack : (UIViewController *)controller;
- (void)openPay: (NSString *)serverId : (NSString *)nickName : (NSNumber *)payAmount : (NSString *)callBack : (UIViewController *)controller;
- (void)openShare: (UIViewController *)controller;



@end
