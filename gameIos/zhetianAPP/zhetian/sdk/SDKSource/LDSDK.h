//
//  LDSDK.h
//  LDSDK
//
//  Created by Leo on 13-12-6.
//  Copyright (c) 2013年 Leo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// 登录回调
typedef void (^CompletionLoginBlock)(id info,NSError *error);
// 注册回调
typedef void (^CompletionRegisterBlock)(id info,NSError *error);
// 支付回调
typedef void (^CompletionChargeBlock)(id info,NSError *error);



@protocol PayBackDelegate;

@interface LDSDK : NSObject



@property (nonatomic, readonly) NSString *appKey;
@property (nonatomic, readonly) NSString *appSecret;
@property (nonatomic, readonly) NSString *channel;

@property (readonly,strong,nonatomic)NSManagedObjectContext *managedObjectContext;
@property (readonly,strong,nonatomic)NSManagedObjectModel *managedObjectModel;
@property (readonly,strong,nonatomic)NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) id rootViewController;
@property (nonatomic, weak) id<PayBackDelegate> delegate;

@property (nonatomic, assign) int model;
@property (nonatomic, strong) NSString *extraInfo;

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
 *  初始化平台
 *
 *  @param model     支付验证模式  0 服务器验证    1 客户端验证 （推荐用0服务器验证，验证结果发送到cp服务器，服务器地址需后台配置）
 */
- (void)initWithModel:(int)model;

/**
 *  初始化平台
 *
 *  @param model     支付验证模式  0 服务器验证    1 客户端验证 （推荐服务器验证，验证结果发送到cp服务器，服务器地址需后台配置）
 *  @param rootController   应用的 RootViewController
 */
- (void)initWithModel:(int)model rootViewController:(id)rootController;

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

/**
 *  IAP 支付
 *
 *  @param productID 商品ID（iTunes connect）
 *  @param extraInfo 额外信息
 */
- (void)requestIAPWithProductID:(NSString *)productID extraInfo:(NSString *)extraInfo;

@end


@protocol PayBackDelegate <NSObject>


@optional

/**
 *  取消支付页面
 */
- (void)ClosePayView;

/**
 *  关闭登录页面
 */
- (void)closeLoginView;

/**
 *  创建订单成功
 */
- (void)createOrderSuccess:(id)info;

/**
 *  iap支付验证成功
 */
- (void)IAPPaySucceed;

/**
 *  iap支付验证失败
 */
- (void)IAPPayFailed;

@end

