//
//  IosSDKHelper.m
//  IosSDKHelper
//
//  Created by youai on 14-5-15.
//  Copyright (c) 2014年 youai. All rights reserved.
//

#import "IosSDKHelper.h"
#import "YouaiSDKMgr.h"
#import "YouaiNotifications.h"
#import "YouaiLoginInfo.h"
#include "SFLoginManager.h"

@implementation IosSDKHelper
{
    NSDictionary* _config;
}
static IosSDKHelper* _sharedHelper;

-(UIViewController*) getRootController
{
    UIViewController* cotrol;
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        // warning: addSubView doesn't work on iOS6
        NSArray* array=[[UIApplication sharedApplication]windows];
        UIWindow* win=[array objectAtIndex:0];
        
        UIView* ui=[[win subviews] objectAtIndex:0];
        cotrol =(UIViewController*)[ui nextResponder];
    }
    else
    {
        // use this method on ios6
        cotrol=[UIApplication sharedApplication].keyWindow.rootViewController;
    }
    return cotrol;
}

-(NSDictionary*) getConfig
{
    if (_config == NULL) {
        NSString* string = [[NSBundle mainBundle] pathForResource:@"sdkConfig" ofType:@"plist"];
        
        _config = [[NSDictionary alloc]initWithContentsOfFile:string];
    }
    return _config;
}

+(MainSDKHelper*) sharedSKDHelper
{
    if (_sharedHelper == NULL) {
        _sharedHelper = [[IosSDKHelper alloc] init];
    }
    return _sharedHelper;
}

-(void)initSDK
{
    
}

-(void) login
{
    UIViewController* control = [self getRootController];
    NSDictionary* config = [self getConfig];
    NSString* appId = [config objectForKey:@"QD_Property1"];
    NSString* appKey = [config objectForKey:@"QD_Property2"];
	[[YouaiSDKMgr getInstance] openLogin:appId :appKey :control];
}

-(void) registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveLoginMessage:) name:youaiLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePayMessage:) name:youaiPaytNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCenterMessage:) name:youaiCenterNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveShareMessage:) name:youaiShareNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveErrorMessage:) name:youaiErrorNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveExitMessage:) name:youaiExitNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePayFinishedMessage:) name:youaiPaytNotification object:nil];
}

-(NSString*) getUUID
{
     NSString *uuid = [[YouaiLoginInfo getInstance] openId];
    return uuid;
}

-(void) openPayWithName:(NSString*) playerName withServerId:(NSString*) serverId withData:(NSString*) data withHandle:(int) handler
{
    [[YouaiSDKMgr getInstance] openPay:serverId
                                      :playerName
                                      :data
                                      :[self getRootController]];
}

-(void) openPayWithAmount:(float) amount withName:(NSString*) playerName withServerId:(NSString*) serverId withData:(NSString*) data withHandle:(int) handler
{
    [[YouaiSDKMgr getInstance] openPay:serverId
                                      :playerName
                                      :[NSNumber numberWithInt:amount]
                                      :data
                                      :[self getRootController]];
}

- (void)receivePayFinishedMessage:(NSNotification *)notification
{
    NSLog(@"url: receivePayFinishedMessage");
}

- (void)receiveLoginMessage:(NSNotification *)notification
{
    SFLoginManager* loginManager = SFLoginManager::getInstance();
    NSString* openid = [[YouaiLoginInfo getInstance] openId];
    NSString* token = [[YouaiLoginInfo getInstance] token];
    NSString* timestamp  = [[YouaiLoginInfo getInstance] timestamp];
    NSString *usrname = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(nil,
                                                                           (CFStringRef)openid, nil,
                                                                           (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
    NSString* gameKey = [NSString stringWithCString:loginManager->getGameKey().c_str() encoding:NSUTF8StringEncoding];
    NSString* authData = [NSString stringWithFormat:@"userId=%@&userName=%@&sign=%@&tstamp=%@&gameKey=%@",openid,usrname,token,timestamp,gameKey];
    NSLog(@"url:%@", authData);
    self.m_authData = authData;
    loginManager->gotoBridgeAuth();
}

- (void)receivePayMessage : (NSNotification *)notification;
{
    NSString *order_id = [notification object];
    NSLog(@"订单ID:%@", order_id);
}
- (void)receiveCenterMessage : (NSNotification *)notification
{
    NSString *message = [notification object];
    NSLog(@"用户中心:%@", message);
}
- (void)receiveShareMessage: (NSNotification *)notification
{
    NSString *message = [notification object];
    NSLog(@"分享:%@", message);
}
- (void)receiveErrorMessage: (NSNotification *)notification
{
    NSString *message = [notification object];
    NSLog(@"出错:%@", message);
}

- (void)receiveExitMessage: (NSNotification *)notification
{
    NSString *message = [notification object];
    NSLog(@"退出:%@", message);
}

-(NSString*) getAuthData
{
    return self.m_authData;
}


-(void)setFloatButtonVisible:(BOOL)show
{
    
}

-(void)submitExtendData:(NSString *)data
{
    
}

-(void)setLoginData:(NSString *)data
{
    
}

-(void) sendPaymentCheckWithJson:(NSString *)json withHandler:(int)handler
{
    
}

-(void) openPayWithDict:(NSDictionary *)dict withHandler:(int)handler
{
    
}

-(void) handleOpenURL:(NSURL *)url
{
    
}

-(void) setLoginAuthData:(NSString*) json
{
    
}
-(void) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
}
-(void)applicationDidEnterBackground:(UIApplication *)application
{
    
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    
}
-(void) showUserCenter
{
    
}
-(NSString*) base64Enocde:(NSString*) code
{
    return @"";
}
@end
