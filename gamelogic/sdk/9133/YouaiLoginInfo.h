//
//  YouaiLoginInfo.h
//  YouaiSDK
//
//  Created by 莫 东荣 on 13-4-10.
//  Copyright (c) 2013年 莫 东荣. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YouaiLoginInfo : NSObject    //用户uid
{
//
NSString *openId;
//token
NSString *token;
//时间戳
NSString *timestamp;

}

@property(retain,nonatomic) NSString *openId;
@property(retain,nonatomic) NSString *token;
@property(retain,nonatomic) NSString *timestamp;
+ (YouaiLoginInfo *)getInstance;
@end