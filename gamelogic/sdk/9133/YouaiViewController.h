//
//  YouaiViewController.h
//  YouaiSDK
//
//  Created by 莫 东荣 on 13-4-9.
//  Copyright (c) 2013年 莫 东荣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YouaiLoginInfo.h"

@interface YouaiViewController : UIViewController<UIWebViewDelegate>
{
    UIWebView *webView_;
    UIActivityIndicatorView *activityIndicator;
    

}


//@property(assign) int webViewWidth;
//@property(assign) int webViewHeight;
//@property(assign) int screenwidth;
//@property(assign) int screenHeight;

-(void)setView:(int)webViewWidth :(int) webViewHeight :(int) screenwidth :(int) screenHeight;
- (void)initWebView;
- (void)loadWebPageWithString:(NSString *)url;
- (void)postNotification:(NSString *)name : (NSString *)code;


@end
