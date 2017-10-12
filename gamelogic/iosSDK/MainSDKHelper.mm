//
//  IosSDKHelper.m
//  IosSDKHelper
//
//  Created by youai on 14-5-15.
//  Copyright (c) 2014年 youai. All rights reserved.
//

#import "IosSDKHelper.h"
#include "SFLoginManager.h"
#import <UIKit/UIKit.h>
#include "SFGameHelper.h"
#define GAMEID @"5098"
#define MD5KEY @"rvhrmrvtG4Lqj1o5jpFwDRQkp4FyBae3"
#define APPKEY @"f176329e985e29f8a70dd505fb20f5c1"
#import "LDGAMEAdapter.h"
@interface SDKHelper : NSObject<LDGAMEAdapterDelegate>

@end

@implementation SDKHelper

- (void)loginResult:(NSDictionary *)result error:(NSError *)error
{
    if (result) {
        [[IosSDKHelper sharedSKDHelper] setIsLogined:YES];
        NSLog(@"登录成功\n open_id = %@,\n game_id = %@,\n session_id = %@",result[@"open_id"],result[@"game_id"],result[@"session_id"]);
        SFLoginManager* loginManager = SFLoginManager::getInstance();
        NSString* gameKey = [NSString stringWithCString:loginManager->getGameKey().c_str() encoding:NSUTF8StringEncoding];
        NSString* authData = [NSString stringWithFormat:@"game_id=%@&open_id=%@&sessionid=%@&gameKey=%@&userName=%@&platform=2",result[@"game_id"],result[@"open_id"],result[@"session_id"],gameKey,result[@"open_id"]];
        NSLog(@"url:%@", authData);
        [IosSDKHelper sharedSKDHelper].m_authData = authData;
        loginManager->gotoBridgeAuth();
    } else {
        NSLog(@"登录错误:%@",error);
    }
}

#pragma mark - 创建订单回调

- (void)createOrder:(NSDictionary *)info error:(NSError *)error
{
    if (!error) {
        NSLog(@"创建成功%@",info);
        NSLog(@"订单id = %@",info[@"id"]);
        
    } else {
        NSLog(@"创建失败%@",error);
    }
}

#pragma mark - 离开充值
/**
 *  威锋平台没有
 */
- (void)orderFinished
{
    NSLog(@"离开充值");
}

- (void)LDGAMEinitComplete
{
    [[IosSDKHelper sharedSKDHelper] setIsFinishInit:YES];
}


-(void)LDGAMEPlatformLogout
{
    [[IosSDKHelper sharedSKDHelper] setIsLogined:NO];
    NSString* isNeedLogOut = [[[IosSDKHelper sharedSKDHelper] getConfigDict] valueForKey:@"isNeedLogOut"];
    NSString* needShowLogin = [[[IosSDKHelper sharedSKDHelper] getConfigDict] valueForKey:@"needShowLogin"];
    if (not [isNeedLogOut isEqualToString:@"NO"]) {
        BOOL needShowLoginFlag = not [needShowLogin isEqualToString:@"NO"];
        SFLoginManager::getInstance()->excuteLogOutCallBack(needShowLoginFlag);
    }
}

@end

@implementation MainSDKHelper
{
    NSDictionary* _config;
    NSDictionary* _loginData;
    NSMutableData* _jsonData;
    SDKHelper* _delegate;
    NSMutableDictionary* _authData;
    bool _isOpen;
    NSMutableDictionary* _topupConfig;
    BOOL _isFinishinit;
    BOOL _isLogined;
}

-(void) setIsFinishInit:(BOOL) isFinish
{
    _isFinishinit = isFinish;
}

-(void) setIsLogined:(BOOL)isLogined
{
    _isLogined = isLogined;
}
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

-(SDKHelper*) getSDKHelper
{
    if (_delegate == nil) {
        _delegate = [[SDKHelper alloc]init];
    }
    return _delegate;
}

-(NSDictionary*) getConfig
{
    if (_config == NULL) {
        NSString* string = [[NSBundle mainBundle] pathForResource:@"sdkConfig" ofType:@"plist"];
        
        _config = [[NSDictionary alloc]initWithContentsOfFile:string];
    }
    return _config;
}



-(void) initSDK
{
    
    _isOpen = NO;
    [self getConfig];
    _topupConfig = [NSMutableDictionary dictionary];

}

-(void) updateClientWithURL:(NSString *)url
{
    NSString* doNotNeedUpdate = [_config valueForKey:@"doNotNeedUpdate"];
    if (not ([doNotNeedUpdate isEqualToString:@"YES"])) {
        NSURL *updateURL = [NSURL URLWithString:url];
        [[UIApplication sharedApplication] openURL:updateURL];
        NSLog(@"update with url %@",url);
    }
}

-(void) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //初始化sdk
    _isLogined = NO;
    _isFinishinit = NO;
    [self getSDKHelper];
    [[LDGAMEAdapter shareInstance] initSdk];
    [LDGAMEAdapter shareInstance].delegate = _delegate;
    [[LDGAMEAdapter shareInstance] gameOncreate:application];
}

-(void)applicationWillTerminate:(UIApplication *)application
{
    [[LDGAMEAdapter shareInstance] gameOndestroy:application];
}

-(void)applicationDidEnterBackground:(UIApplication *)application
{
    [[LDGAMEAdapter shareInstance] gameOnpause:application];
}

-(void)applicationWillEnterForeground:(UIApplication *)application
{
    [[LDGAMEAdapter shareInstance] gameOnresume:application];
}

-(void) login
{
    if (_isFinishinit) {
        if (!_isLogined) {
            [[LDGAMEAdapter shareInstance] showLoginViewWithDelegate:_delegate extraInfo:@"我的游戏登录"];
        }else{
            SFLoginManager::getInstance()->gotoBridgeAuth();
        }
    }
}


-(void) logout
{

}
-(void)setOrientation:(UIInterfaceOrientation) orientation
{
    [LDGAMEAdapter shareInstance].orientation = orientation;
}

- (void)onUnloginExit:(NSNotification *)notification
{
    
}

-(void) registNotification
{
    
}

-(NSString*) getUUID
{
    return @"iosKY";
}

-(NSString*)DataTOjsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}



-(void)setFloatButtonVisible:(BOOL)show
{
    
}

-(void) submitExtendData:(NSString *)data
{
    
}

-(NSString*) getAuthData
{
    return self.m_authData;
}


-(NSMutableDictionary*) jsonToDict:(NSString*) json
{
    NSError* error;
    NSData* d = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:d options:NSJSONReadingMutableLeaves error:&error];
    return dict;
}

-(void)setLoginData:(NSString *)data
{
    _loginData = [[self jsonToDict:data] copy];
}

-(void)setLoginAuthData:(NSString *)json
{
    _authData = [[self jsonToDict:json] copy];
    NSLog(@"%@",_authData);
}

-(void) sendPaymentCheckWithName:(NSString*) name WirhURL:(NSString*) url withAmount:(float)amount
{
    
}

-(void) openPayWithDict:(NSDictionary *)dict withHandler:(int)handler
{
    if (dict) {
    }
}

-(void) openPayWithDict:(NSDictionary *)dict withHandler:(int)handler withOrderID:(NSString*) orderId
{
    if (dict) {
        NSString *pName = [dict valueForKey:@"heroName"];
        pName = [self base64Enocde:pName];
        
        NSString* server  = [NSString stringWithUTF8String:SFLoginManager::getInstance()->getServerId()];
        float amount = [[dict valueForKey:@"amount"] floatValue];
        NSString* productName = [dict valueForKey:@"productName"];
        NSString* identityId = [NSString stringWithUTF8String:SFLoginManager::getInstance()->getPlayerId()];
        NSString* qdCode1 = [NSString stringWithFormat:@"%d",SFLoginManager::getInstance()->getQDCode1()];
        NSString* qdCode2 = [NSString stringWithFormat:@"%d",SFLoginManager::getInstance()->getQDCode2()];
        NSString *exchangeURL = [_topupConfig valueForKey:server];
        if ( not exchangeURL) {
            if (_loginData) {
                NSLog(@"loginData %@",_loginData);
                NSArray* urlArray  = [_loginData objectForKey:@"serversList"];
                NSLog(@"urlDict %@",urlArray);
                NSDictionary* urlDict = nil;
                for (int i = 0; i< urlArray.count; i++) {
                    urlDict =[urlArray objectAtIndex:i];
                    NSInteger serverId  = [[urlDict valueForKey:@"id"]integerValue];
                    if (serverId == [server integerValue]) {
                        NSLog(@"the select server is %ld",(long)serverId);
                        break;
                    }
                }
                exchangeURL = [urlDict valueForKey:@"servicesUrl"];
                NSLog(@"url %@",exchangeURL);
                exchangeURL = [self base64Enocde:exchangeURL];
                [_topupConfig setValue:exchangeURL forKey:server];
            }
        }
        NSString* gameKey = [NSString stringWithCString:SFLoginManager::getInstance()->getGameKey().c_str() encoding:NSUTF8StringEncoding];
        NSString* extraInfo = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|%@",server,identityId,pName,exchangeURL,qdCode1,qdCode2,gameKey];
        NSLog(@"extraInfo %@",extraInfo);
        NSString* isDebug = [_config valueForKey:@"isDebug"];
        NSLog(@"the amount %f",amount);
        if ([isDebug isEqualToString:@"YES"] ) {
            NSLog(@"debug");
            [[LDGAMEAdapter shareInstance] showRechargeWithServerid:server price:1.0 productName:productName extraInfo:extraInfo delegate:_delegate];
        } else {
            NSLog(@"not debug");
            [[LDGAMEAdapter shareInstance] showRechargeWithServerid:server price:amount productName:productName extraInfo:extraInfo delegate:_delegate];
        }
    }
}


-(NSMutableURLRequest*) createRequest:(NSMutableDictionary*) dict
{
    NSString* url = [_config valueForKey:@"orderURL"];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSString* qdCode1 = [NSString stringWithFormat:@"%d",SFLoginManager::getInstance()->getQDCode1()];
    NSString* qdCode2 = [NSString stringWithFormat:@"%d",SFLoginManager::getInstance()->getQDCode2()];
    NSString* identityId = [NSString stringWithUTF8String:SFLoginManager::getInstance()->getPlayerId()];
    NSString* server  = [NSString stringWithUTF8String:SFLoginManager::getInstance()->getServerId()];
    NSString *pName = [dict valueForKey:@"heroName"];
    pName = [self base64Enocde:pName];
    NSLog(@"%@",pName);
    NSString* gameKey = [NSString stringWithCString:SFLoginManager::getInstance()->getGameKey().c_str() encoding:NSUTF8StringEncoding];
    NSString *exchangeURL = [_topupConfig valueForKey:server];
    if ( not exchangeURL) {
        if (_loginData) {
            NSLog(@"loginData %@",_loginData);
            NSArray* urlArray  = [_loginData objectForKey:@"serversList"];
            NSLog(@"urlDict %@",urlArray);
            NSDictionary* urlDict = nil;
            for (int i = 0; i< urlArray.count; i++) {
                urlDict =[urlArray objectAtIndex:i];
                NSInteger serverId  = [[urlDict valueForKey:@"id"]integerValue];
                if (serverId == [server integerValue]) {
                    NSLog(@"the select server is %ld",(long)serverId);
                    break;
                }
            }
            exchangeURL = [urlDict valueForKey:@"servicesUrl"];
            NSLog(@"url %@",exchangeURL);
            exchangeURL = [self base64Enocde:exchangeURL];
            [_topupConfig setValue:exchangeURL forKey:server];
        }
    }
    NSString* userId = [_authData valueForKey:@"userId"];
    NSString *post = [NSString stringWithFormat:@"qdCode1=%@&qdCode2=%@&serverId=%@&playerId=%@&identityName=%@&playerName=%@&exchangeUrl=%@&gameKey=%@&userId=%@",qdCode1,qdCode2,server,identityId,pName,pName,exchangeURL,gameKey,userId];
    
    NSLog(@"post:%@",post);
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPMethod:@"POST"];
    return request;
}

-(void)sendPaymentCheckWithJson:(NSString *)json withHandler:(int)handler
{
    
    NSError* error;
    NSLog(@"%@",json);
    NSData* d = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *jsondict = [NSJSONSerialization JSONObjectWithData:d options:NSJSONReadingMutableLeaves error:&error];
    if (jsondict) {
        NSString* url = [jsondict valueForKey:@"serverURl"];
        url = [NSString stringWithUTF8String:SFGameHelper::urlDecode([url UTF8String]).c_str()];
        if (url) {
            _jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            if (_jsonData) {
                NSError* error;
                NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:_jsonData options:NSJSONReadingMutableLeaves error:&error];
                NSLog(@"error %@",error);
                NSLog(@"dict %@",dict);
                BOOL isOpen = NO;
                if (dict) {
                    if ([dict count] > 0) {
                        isOpen = YES;
                    }
                }
                if (isOpen) {
                    [self openPayWithDict:jsondict withHandler:handler withOrderID:@""];
                }else{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@" "
                                                                        message:@"充值未开放"
                                                                       delegate:self
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                    [alertView show];
                }
                
            }
        }
        
    }
}

-(void) handleOpenURL:(NSURL *)url
{
    
}

- (void)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [[LDGAMEAdapter shareInstance] parseAliPayResultWithURL:application handleOpenURL:url];
}
-(void) showUserCenter
{
    [[LDGAMEAdapter shareInstance] showUserCenter];
}

-(NSString*) base64Enocde:(NSString *)code
{
    return @"";
}


-(void)initPaymentObserver
{
    
}
-(void)setPlayerName:(NSString*) playerName
{
    
}

-(void)showPauseView
{
    [[LDGAMEAdapter shareInstance] showPauseView];
}

-(NSDictionary*) getConfigDict
{
    return _config;
}
@end
