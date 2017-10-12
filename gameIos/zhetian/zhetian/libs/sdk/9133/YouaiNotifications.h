//
//  YouaiNotifications.h
//  YouaiSDK
//
//  Created by 莫 东荣 on 13-4-10.
//  Copyright (c) 2013年 莫 东荣. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const youaiExitNotification;                  /**<  退出 */
extern NSString * const youaiLoginNotification;					/**< 登录完成的通知*/
extern NSString * const youaiPaytNotification;                  /**< 支付通知 */
extern NSString * const youaiShareNotification;                 /**<  分享通知 */
extern NSString * const youaiCenterNotification;                /**<  用户中心通知  */
extern NSString * const youaiErrorNotification;                 /**<  出错 */


@interface YouaiNotifications : NSObject

@end
