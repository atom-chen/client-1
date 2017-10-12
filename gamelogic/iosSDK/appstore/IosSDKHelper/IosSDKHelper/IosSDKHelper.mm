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
#include "Base64.h"
#define KEY @"e37f701def68a994afac"
#define SECRET @"9a792963b16341150bba"
#import "LDSDK.h"

@interface PaymentDelegate : NSObject<PayBackDelegate>

@end

@implementation PaymentDelegate

/**
 *  关闭支付页面
 */
- (void)ClosePayView
{
    NSLog(@"取消支付");
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提示" message:@"取消支付" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [av show];
}

//关闭登录页面
-(void)closeLoginView
{
    NSLog(@"登录关闭");
}

/**
 *  创建订单成功
 */
- (void)createOrderSuccess:(id)info
{
    NSLog(@"创建订单成功: %@",info[@"result"]);
    
}

- (void)IAPPaySucceed
{
    //此时订单已经在APPstore验证成功
    NSLog(@"支付成功");
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提示" message:@"支付成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [av show];
}

- (void)IAPPayFailed
{
    NSLog(@"支付失败");
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提示" message:@"支付失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [av show];
}

@end

@implementation IosSDKHelper
{
    NSDictionary* _config;
    NSDictionary* _loginData;
    NSMutableData* _jsonData;
    NSMutableDictionary* _authData;
    NSMutableDictionary* _topupConfig;
    PaymentDelegate* _paymentDelegate;
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
        NSLog(@"%@",_config);
    }
    return _config;
}

+(IosSDKHelper*) sharedSKDHelper
{
    if (_sharedHelper == NULL) {
        _sharedHelper = [[IosSDKHelper alloc] init];
    }
    return _sharedHelper;
}

-(void) initSDK
{
    [self getConfig];
    _topupConfig = [NSMutableDictionary dictionary];
}

-(void) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _paymentDelegate = [PaymentDelegate new];
    [[LDSDK shareInstance] initWithModel:0];
    [[LDSDK shareInstance] gameOncreate:application];
    [LDSDK shareInstance].rootViewController = [self getRootController];
    [[LDSDK shareInstance] setDelegate:_paymentDelegate];
}

-(void)applicationWillTerminate:(UIApplication *)application
{
     [[LDSDK shareInstance] gameOndestroy:application];
}

-(void)applicationDidEnterBackground:(UIApplication *)application
{
    [[LDSDK shareInstance] gameOnpause:application];
}

-(void)applicationWillEnterForeground:(UIApplication *)application
{
     [[LDSDK shareInstance] gameOnresume:application];
}

-(void) login
{
    [LDSDK showLoginView:^(id info, NSError *error) {
        SFLoginManager* loginManager = SFLoginManager::getInstance();
        NSString* gameKey = [NSString stringWithCString:loginManager->getGameKey().c_str() encoding:NSUTF8StringEncoding];
        NSString* authData = [NSString stringWithFormat:@"game_id=%@&open_id=%@&sessionid=%@&gameKey=%@&userName=%@&platform=2",info[@"game_id"],info[@"open_id"],info[@"session_id"],gameKey,info[@"open_id"]];
        NSLog(@"%@",info);
        NSLog(@"url:%@", authData);
        [IosSDKHelper sharedSKDHelper].m_authData = authData;
        loginManager->gotoBridgeAuth();
    } autoLogin:YES];
}


- (void)onUnloginExit:(NSNotification *)notification
{

}

-(void) registNotification
{

}

-(NSString*) getUUID
{
    return @"iosAppstore";
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


-(NSString*) base64UrlWithString:(NSString*) data
{
    NSString *result = [[NSString alloc] initWithData:[Base64 encodeData:[data dataUsingEncoding:NSUTF8StringEncoding]]  encoding:NSUTF8StringEncoding];
    result = [result stringByReplacingOccurrencesOfString:@"=" withString:@"_REP_"];
    result = [result stringByReplacingOccurrencesOfString:@"+" withString:@"_RAP_"];
    result = [result stringByReplacingOccurrencesOfString:@"-" withString:@"_RBP_"];
    result = [result stringByReplacingOccurrencesOfString:@"\\" withString:@"_RCP_"];
    return result;
}



-(void)setFloatButtonVisible:(BOOL)show
{
    if (true) {
        [LDSDK showFloatView];
    }else{
        [LDSDK hideFloatView];
    }
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


-(void) openPayWithDict:(NSDictionary *)dict withHandler:(int)handler
{
    if (dict) {
        
    }
}

-(void) openPayWithDict:(NSDictionary *)dict withHandler:(int)handler withOrderID:(NSString*) orderId
{
    if (dict) {
        NSString* refId = [dict valueForKey:@"refId"];
        NSString *pName = [dict valueForKey:@"heroName"];
        pName = [self base64Enocde:pName];
        
        NSString* server  = [NSString stringWithUTF8String:SFLoginManager::getInstance()->getServerId()];
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
        [[LDSDK shareInstance] requestIAPWithProductID:refId extraInfo:extraInfo];
    }
}


-(NSMutableURLRequest*) createRequest:(NSMutableDictionary*) dict
{
    NSString* url = [_config valueForKey:@"orderURL"];
    NSLog(@"%@",url);
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSString* qdCode1 = [NSString stringWithFormat:@"%d",SFLoginManager::getInstance()->getQDCode1()];
    NSString* qdCode2 = [NSString stringWithFormat:@"%d",SFLoginManager::getInstance()->getQDCode2()];
    NSString* identityId = [NSString stringWithUTF8String:SFLoginManager::getInstance()->getPlayerId()];
    NSString* server  = [NSString stringWithUTF8String:SFLoginManager::getInstance()->getServerId()];
    NSString *pName = [dict valueForKey:@"heroName"];
    pName = [self base64UrlWithString:pName];
    NSLog(@"%@",pName);
    NSString* gameKey = [NSString stringWithCString:SFLoginManager::getInstance()->getGameKey().c_str() encoding:NSUTF8StringEncoding];
    NSString *exchangeURL = @"";
    if (_loginData) {
        NSLog(@"loginData %@",_loginData);
        NSArray* urlArray  = [_loginData objectForKey:@"serversList"];
        NSLog(@"urlDict %@",urlArray);
        NSDictionary* urlDict = [urlArray objectAtIndex:[server integerValue]-1];
        exchangeURL = [urlDict valueForKey:@"servicesUrl"];
        NSLog(@"url %@",exchangeURL);
        exchangeURL = [self base64UrlWithString:exchangeURL];
    }
    NSString* userId = [_authData valueForKey:@"userId"];
    NSString *post = [NSString stringWithFormat:@"qdCode1=%@&qdCode2=%@&serverId=%@&playerId=%@&identityName=%@&playerName=%@&exchangeUrl=%@&gameKey=%@&userId=%@",qdCode1,qdCode2,server,identityId,pName,pName,exchangeURL,gameKey,userId];
    
    NSLog(@"post:%@",post);
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPMethod:@"POST"];
    return request;
}

-(void) handleOpenURL:(NSURL *)url
{

}

-(void)showUserCenter
{
    
}

-(NSString*) base64Enocde:(NSString *)code
{
    return [self base64UrlWithString:code];
}

-(void) updateClientWithURL:(NSString*) appid
{
    NSString *url = [NSString stringWithFormat:@"http://itunes.apple.com/us/app/id%@",appid];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}
@end
