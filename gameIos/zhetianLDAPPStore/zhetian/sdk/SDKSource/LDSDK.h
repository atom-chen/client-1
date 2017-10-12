//
//  LDSDK.h
//  LDSDK
//
//  Created by Leo on 13-12-6.
//  Copyright (c) 2013年 Leo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDConfig.h"
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>


// 登录回调
typedef void (^CompletionLoginBlock)(id info,NSError *error);
// 注册回调
typedef void (^CompletionRegisterBlock)(id info,NSError *error);
// 支付回调
typedef void (^CompletionChargeBlock)(id info,NSError *error);



@protocol PayBackDelegate;

@interface LDSDK : NSObject

@property (nonatomic, readonly) LDConfig *config;

@property (nonatomic, readonly) NSString *appKey;
@property (nonatomic, readonly) NSString *appSecret;
@property (nonatomic, readonly) NSString *channel;
@property (readonly,strong,nonatomic)NSManagedObjectContext *managedObjectContext;
@property (readonly,strong,nonatomic)NSManagedObjectModel *managedObjectModel;
@property (readonly,strong,nonatomic)NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) id rootViewController;
@property (nonatomic, weak) id<PayBackDelegate> delegate;

/**
 *  获取实例
 *
 *  @return LDSDK实例
 */
+ (instancetype)shareInstance;

-(NSPersistentStoreCoordinator *)persistentStoreCoordinator;
//managedObjectModel的初始化赋值函数
-(NSManagedObjectModel *)managedObjectModel;
//managedObjectContext的初始化赋值函数
-(NSManagedObjectContext *)managedObjectContext;

/**
 *  初始化平台,自动从Config.plist中读取appkey等数据,不需要再调用initWithAppKey 方法
 *
 */
+ (void)initSdk;


/**
 *  初始化平台, 可用initSdk方法代替
 *
 *  @param appKey    乐逗appkey
 *  @param appSecret 乐逗appSecret
 *  @param cfg       平台配置
 *  
 */
+ (void)initWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret congfig:(LDConfig *)cfg;


/**
 *  初始化平台, 可用initSdk方法代替
 *
 *  @param appKey           乐逗appkey
 *  @param appSecret        乐逗appSecret
 *  @param cfg              平台配置
 *  @param rootController   应用的 RootViewController
 */
+ (void)initWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret congfig:(LDConfig *)cfg rootViewController:(id)rootController;

/**
 *  显示登陆视图，允许自动登录
 *
 *  @param block 登陆回调方法，
 */
+ (void)showLoginView:(CompletionLoginBlock)block;


/**
 *  显示登陆视图
 *
 *  @param block 登陆回调方法
 *  @param canAutoLogin 是否允许自动登录，
 */
+ (void)showLoginView:(CompletionLoginBlock)block autoLogin:(BOOL)canAutoLogin;


/**
 *  显示设置页面
 *
 *  @param block 离开设置页面回调方法
 */
+ (void)showSettingView:(void (^)(void))block;

// 浮层
+ (void)showFloatView;
+ (void)hideFloatView;
// 设置浮层方向，暂无
+ (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;


/**
 *	@brief	显示乐逗支付中心, 自选金额
 *
 *	@param 	serverid 	服务器id
 *	@param 	extraInfo 	自定义参数,会透传到游戏服务器
 *  @param  block       支付的结果回调方法
 */
+ (void)showChargeViewWithServerId:(NSString *)serverid extraInfo:(NSString *)extraInfo block:(void (^)(id info,NSError *error))block;


/**
 *	@brief	显示乐逗支付中心, 指定金额
 *
 *	@param 	serverid 	服务器id
  *	@param 	price 	    充值金额 (单位为元)
 *	@param 	extraInfo 	自定义参数,会透传到游戏服务器
 *  @param  block       支付的结果回调方法
 */
+ (void)showChargeViewWithServerId:(NSString *)serverid extraInfo:(NSString *)extraInfo price:(float)price desc:(NSString *)desc block:(void (^)(id info,NSError *error))block;


+ (id)getRootController;


- (void)close:(NSNumber *)num;


/**
 *  游戏开始,didFinishLaunchingWithOptions
 */
- (void)gameOncreate:(UIApplication *)application;

/**
 *  游戏暂停,进入后台 applicationDidEnterBackground
 */
- (void)gameOnpause:(UIApplication *)application;

/**
 *  游戏恢复,重新进入前台 applicationWillEnterForeground
 */
- (void)gameOnresume:(UIApplication *)application;

/**
 *  游戏结束,applicationWillTerminate
 */
- (void)gameOndestroy:(UIApplication *)application;

/**
 *  数据上报 - 通用
 */
- (void)IDSSDKTalkingReport:(NSString *)actionID;

/**
 *  保存token
 *
 *  @param token 设备编号
 */
- (void)saveDeviceToken:(NSData *)token;

@end


@protocol PayBackDelegate <NSObject>


@optional

/**
 *  关闭支付页面
 */
- (void)ClosePayView;

//关闭登录页面
-(void)closeLoginView;
@end

