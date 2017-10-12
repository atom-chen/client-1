//
//  LDConfig.h
//  LDSDK
//
//  Created by Leo on 14-1-10.
//  Copyright (c) 2014年 Leo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDConfig : NSObject

/**
 *  游戏的key和secret在乐逗开发者后台申请
 */
@property (nonatomic, readonly) NSString *key;
@property (nonatomic, readonly) NSString *secret;
/**
 *  渠道
 */
@property (nonatomic, readonly) NSString *channel;

/**
 *  App版本号
 *  
 *  规则: v + 应用版本号 + _s + 乐逗SDK版本号 。   如 应用程序版本号为:1.0  乐逗SDK版本号为:1.0.0 则最后该字段为:v1.0_s1.0.0 
 */
@property (nonatomic, readonly) NSString *appVersion;

/**
 *  构建LDConfig对象
 *
 *  @param filePath 配置文件路径
 *
 *  @return LDConfig对象
 */
+ (instancetype)configWithFilePath:(NSString *)filePath;

@end
