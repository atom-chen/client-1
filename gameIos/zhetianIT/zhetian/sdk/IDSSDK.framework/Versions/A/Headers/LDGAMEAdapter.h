//
//  DLAdapterIDS.h
//  IDSSDK
//
//  Created by sdk on 14-2-19.
//  Copyright (c) 2014年 Leo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LDGAMEAdapterDelegate;
@interface LDGAMEAdapter: NSObject
@property (nonatomic, assign) id<LDGAMEAdapterDelegate> delegate;

/**
 *  检测是否登录
 */
@property (nonatomic, assign) BOOL isLogined;

/**
 *  设置是否自动旋转  (仅对部分 第三方平台sdk 起作用)
 */
@property (nonatomic, assign) BOOL isAutoRotate;


/**
 *	@brief 设置屏幕方向
 */
@property (nonatomic, assign) UIInterfaceOrientation orientation;


/**
 *	@brief	设置第三方的rootViewController
 */
@property (nonatomic, strong) id rootViewController;



+ (LDGAMEAdapter *)shareInstance;


/**
 *	@brief	平台初始化接口,必须调用
 */
-(void)initSdk;


/**
 *  登录
 *
 *  @param delegate  IDSLoginProtocol  代理
 *  @param extraInfo 登录附加信息，登录成功后原样返回
 *
 *  未登录，则直接显示登录界面，如果有登录用户，则会先注销当前登录用户后显示登录界面
 */
- (void)showLoginViewWithDelegate:(id)delegate extraInfo:(NSString *)extraInfo;

/**
 *  用户中心
 */
- (void)showUserCenter;

/**
 *  注销
 */
- (void)logout;

/**
 *  道具购买接口
 *  @param serverid  服务器id
 *  @param productName  道具名称
 *  @param extraInfo  附加信息，原样返回
 *  @param delegate  IDSCreateOrderProtocol  创建订单成功回调代理
 */
- (void)showRechargeWithServerid:(NSString *)serverid
                           price:(float)price
                     productName:(NSString *)productName
                       extraInfo:(NSString *)extraInfo
                        delegate:(id)delegate;


/**
    支付宝快捷支付返回 App  需设置 URL Schemes 建议使用 ‘平台名缩写-包名’ 的格式
    各平台需要不同处理      
    标记 Schemes  需设置 info.plit中URL Schemes
 
 * PP      Schemes
 * TB      none
 * 91      Schemes
 * DJ      none
 * HX      none
 * KY      Schemes
 * DL      Schemes
 * UC      Schemes
 * WeGame  Schemes    //此处的 URL Schemes 需填写到威锋的 商家后台中
 *
 *  @param application
 *  @param url
 */
- (void)parseAliPayResultWithURL:(UIApplication *)application handleOpenURL:(NSURL *)url;

/**
 支付宝快捷支付返回 App  需设置 URL Schemes 建议使用 ‘平台名缩写-包名’ 的格式
 各平台需要不同处理
 标记 Schemes  需设置 info.plit中URL Schemes
 
 * PP      Schemes
 * TB      none
 * 91      Schemes
 * DJ      none
 * HX      none
 * KY      Schemes
 * DL      Schemes
 * UC      Schemes
 * WeGame  Schemes    //此处的 URL Schemes 需填写到威锋的 商家后台中
 *
 *  @param application
 *  @param url
 *  @param sourceApplication  可判别是哪个程序跳转过来的
 */
- (void)parseAliPayResultWithURL:(UIApplication *)application handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;


/*************************
    需要特别注意的不同平台的      差异  如下
*************************/
/**
 *  上报在线玩家数量 登录之后方可调用 必需 -wegame
 *  @param players  在线玩家数量
 */
- (void)uploadPlayerNUM:(NSString *)players;

/**
 *  显示暂停页 必需 - 91
 */
- (void)showPauseView;

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
 *	@brief	显示浮层
 */
- (void)showFloatView;

/**
 *	@brief	关闭浮层
 */
- (void)hideFloatView;



@end



/**
 *  代理
 */
@protocol LDGAMEAdapterDelegate <NSObject>


@optional

/**
 *  初始化成功回调
 */
- (void)LDGAMEinitComplete;

/**
 *  关闭登录页面
 */
- (void)LDGAMECloseLoginView;

/**
 *  注销回调
 */
- (void)LDGAMEPlatformLogout;

/**
 *  支付结束, 可能是成功,可能是关闭
 */
- (void)orderFinished;


/**
 *  暂停页关闭回调 - 91
 */
- (void)LDGAMELeavePauseView;

@end

