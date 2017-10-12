//
//  MainSDKHelper.h
//  IosSDKHelper
//
//  Created by youai on 14-7-9.
//  Copyright (c) 2014年 youai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MainSDKHelper : NSObject

@property (retain, nonatomic) NSString *m_authData;


-(void) initSDK;
-(void) login;
-(void) logout;
-(void) registNotification;
-(NSString*) getUUID;

-(void) openPayWithDict:(NSDictionary*)dict withHandler:(int)handler;
-(void) setFloatButtonVisible:(BOOL) show;

-(void) submitExtendData:(NSString*) data;
-(NSString*) getAuthData;
-(void) setLoginData:(NSString*) data;
-(void) sendPaymentCheckWithJson:(NSString*) json withHandler:(int) handler;
-(void)handleOpenURL:(NSURL *)url;
-(void) setLoginAuthData:(NSString*) json;
-(void) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
-(void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationWillEnterForeground:(UIApplication *)application;
- (void)applicationWillTerminate:(UIApplication *)application;
-(void) showUserCenter;
- (void)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
-(NSString*) base64Enocde:(NSString*) code;
-(void)initPaymentObserver;
-(void)setPlayerName:(NSString*) playerName;
-(void)setOrientation:(UIInterfaceOrientation) orientation;
-(void) showPauseView;
-(void) setIsFinishInit:(BOOL) isFinish;
-(void) setIsLogined:(BOOL) isLogined;
-(void)updateClientWithURL:(NSString*)url;
-(NSDictionary*) getConfigDict;
@end
