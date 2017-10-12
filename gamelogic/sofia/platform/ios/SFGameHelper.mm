#include "../gamelogic/include/platform/SFGameHelper.h"
#include "platform/CCFileUtils.h"
#include "script_support/CCScriptSupport.h"
#include "include/package/SFPackageManager.h"
#import "Reachability.h"
#import <UIKit/UIKit.h>
#include <sys/param.h>
#include <sys/mount.h>
#import <sys/sysctl.h>
#import <mach/mach.h>
//#import <Frontia/Frontia.h>
#import "IosSDKHelper.h"
#import "sys/utsname.h"

std::string SFGameHelper::getExtStoragePath( ){
    return cocos2d::CCFileUtils::sharedFileUtils()->getWritablePath();
}


bool SFGameHelper::isDirExist(const char* path){
    return  [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:path]];
}

bool SFGameHelper::createDir(const char* path){
    
    return  [[NSFileManager defaultManager]
             createDirectoryAtPath:[NSString stringWithUTF8String:path]
             withIntermediateDirectories:YES
             attributes:nil
             error:nil ];
}

void SFGameHelper::copyResouce(const char* resPath, const char* destPath,int handler){
    dispatch_queue_t copyQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(copyQueue, ^{
        NSString* dest = [NSString stringWithUTF8String:destPath];
        NSString* extPath = [NSString stringWithUTF8String:cocos2d::CCFileUtils::sharedFileUtils()->getWritablePath().c_str()];
        NSString* baseName = [[dest lastPathComponent] stringByDeletingPathExtension];
        NSString* tempPath = [NSString stringWithFormat:@"%@//%@.tmp",extPath,baseName];
        NSString* restString = [NSString stringWithUTF8String:resPath];
        BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:restString];
        if (fileExist) {
            [[NSFileManager defaultManager] copyItemAtPath:restString
                                                    toPath:tempPath
                                                     error:nil];
            [[NSFileManager defaultManager]removeItemAtPath:dest error:nil];
            NSError * error= nil;
            [[NSFileManager defaultManager] moveItemAtPath:tempPath toPath:dest error:&error];
           
        }else{
            CCLOG("file do not exist ");
        }
        cocos2d::CCScriptEngineProtocol* pEngine = cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine();
        dispatch_sync(dispatch_get_main_queue(), ^{
            pEngine->executeControlEvent(handler,0);
        });
    });
}

std::string SFGameHelper::getClientVersion(){
    NSDictionary* inforDict = [[NSBundle mainBundle] infoDictionary];
    NSString* appVersion = [inforDict objectForKey:@"CFBundleShortVersionString"];
    return [appVersion UTF8String];
}

void SFGameHelper::updateClient(const char *pszUrl, const char *pszNewVersion, bool bForce)
{
    [[IosSDKHelper sharedSKDHelper] updateClientWithURL:[NSString stringWithUTF8String:pszUrl]];
}

int SFGameHelper::getMainVersion()
{
	return 0;
}

int SFGameHelper::getSubVersion()
{
	return 0;
}

int SFGameHelper::getCurrentNetWork()
{
    Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
            // 没有网络连接
            return kNotNetwork;
            break;
        case ReachableViaWWAN:
            // 使用3G网络
            return kNotWifi;
            break;
        case ReachableViaWiFi:
            // 使用WiFi网络
            return kWifi;
            break;
    }
}

void SFGameHelper::moveFile(const char* resPath, const char* destPath,int handler)
{
    NSError * error= nil;
    NSString* res = [NSString stringWithUTF8String:resPath];
    NSString* des = [NSString stringWithUTF8String:destPath];
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:des];
    if (fileExist) {
        [[NSFileManager defaultManager]removeItemAtPath:des error:nil];
    }
    [[NSFileManager defaultManager] moveItemAtPath:res toPath:des error:&error];
    cocos2d::CCScriptEngineProtocol* pEngine = cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine();
    dispatch_async(dispatch_get_main_queue(), ^{
        pEngine->executeControlEvent(handler,0);
    });
}

void SFGameHelper::deleteFile(const char* resPath,int handler)
{
    NSError * error= nil;
    [[NSFileManager defaultManager]removeItemAtPath:[NSString stringWithUTF8String:resPath] error:&error];
    cocos2d::CCScriptEngineProtocol* pEngine = cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine();
    dispatch_async(dispatch_get_main_queue(), ^{
        pEngine->executeControlEvent(handler,0);
    });
}

void SFGameHelper::setPushResultHandler(BaiduResultHandler handler)
{
    
}
void SFGameHelper::setShareResultHandler(BaiduResultHandler handler)
{
    
}
void SFGameHelper::setTag(cocos2d::CCArray* tags)   //设置推送组
{
//    FrontiaPush* push = [Frontia getPush];
//    NSMutableArray* nsTags = [NSMutableArray array];
//    for (int i=0; i<tags->count(); i++) {
//        cocos2d::CCString* tag = dynamic_cast<cocos2d::CCString*>(tags->objectAtIndex(i));
//        if (tag) {
//            [nsTags addObject:[NSString stringWithUTF8String:tag->getCString()]];
//        }
//    }
//    if ([nsTags count] > 0) {
//        NSArray* array = [NSArray arrayWithArray:nsTags];
//        [push setTags:array tagOpResult:^(int count, NSArray *failureTag) {
//            
//        } failureResult:^(NSString *action, int errorCode, NSString *errorMessage) {
//            
//        }];
//    }
    
}
void SFGameHelper::removeTag(const char* tag)
{
//    FrontiaPush* push = [Frontia getPush];
//    [push delTag:[NSString stringWithUTF8String:tag] tagOpResult:^(int count, NSArray *failureTag) {
//        
//    } failureResult:^(NSString *action, int errorCode, NSString *errorMessage) {
//        
//    }];
}

void SFGameHelper::startPush()
{
//    [[Frontia getPush] bindChannel:^(NSString *appId, NSString *userId, NSString *channelId) {
//        
//    } failureResult:^(NSString *action, int errorCode, NSString *errorMessage) {
//        
//     } ];
}

void SFGameHelper::stopPush()
{
//    [[Frontia getPush] unbindChannel:^{
//        
//    } failureResult:^(NSString *action, int errorCode, NSString *errorMessage) {
//    } ];

}

void SFGameHelper::showMenu(const char* title, const char* content, const char* linkUrl, const char* imgUrl,int handler)
{
//    FrontiaShare *share = [Frontia getShare];
//    //授权取消回调函数
//    FrontiaShareCancelCallback onCancel = ^(){
//        NSLog(@"OnCancel: share is cancelled");
//    };
//    
//    //授权失败回调函数
//    FrontiaShareFailureCallback onFailure = ^(int errorCode, NSString *errorMessage){
//        NSLog(@"OnFailure: %d  %@", errorCode, errorMessage);
//    };
//    
//    //授权成功回调函数
//    FrontiaMultiShareResultCallback onResult = ^(NSDictionary *respones){
//        NSLog(@"OnResult: %@", [respones description]);
//    };
//    
//    FrontiaShareContent *shareContent = [[FrontiaShareContent alloc] init];
//    shareContent.url = [NSString stringWithUTF8String:linkUrl];
//    shareContent.title = [NSString stringWithUTF8String:title];
//    shareContent.description = [NSString stringWithUTF8String:content];
//    shareContent.imageObj = [NSString stringWithUTF8String:imgUrl];
//    
//    NSArray *platforms = @[FRONTIA_SOCIAL_SHARE_PLATFORM_SINAWEIBO,FRONTIA_SOCIAL_SHARE_PLATFORM_QQWEIBO,FRONTIA_SOCIAL_SHARE_PLATFORM_QQ,FRONTIA_SOCIAL_SHARE_PLATFORM_RENREN,FRONTIA_SOCIAL_SHARE_PLATFORM_KAIXIN,FRONTIA_SOCIAL_SHARE_PLATFORM_EMAIL,FRONTIA_SOCIAL_SHARE_PLATFORM_WEIXIN_SESSION,FRONTIA_SOCIAL_SHARE_PLATFORM_WEIXIN_TIMELINE,FRONTIA_SOCIAL_SHARE_PLATFORM_QQFRIEND];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [share showShareMenuWithShareContent:shareContent displayPlatforms:platforms supportedInterfaceOrientations:UIInterfaceOrientationMaskLandscape isStatusBarHidden:YES targetViewForPad:nil  cancelListener:onCancel failureListener:onFailure resultListener:onResult];
//    });
    
}

void SFGameHelper::share(const char* platform, bool bEdit,const char* title, const char* content, const char* linkUrl, const char* imgUrl,int handler)
{
//    FrontiaShare *share = [Frontia getShare];
//    //授权取消回调函数
//    FrontiaShareContent *shareContent = [[FrontiaShareContent alloc] init];
//    shareContent.url = [NSString stringWithUTF8String:linkUrl];
//    shareContent.title = [NSString stringWithUTF8String:title];
//    shareContent.description = [NSString stringWithUTF8String:content];
//    shareContent.imageObj = [NSString stringWithUTF8String:imgUrl];
//    
//    NSString* nsPlatform = [NSString stringWithUTF8String:platform];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [share shareWithPlatform:nsPlatform content:shareContent supportedInterfaceOrientations:UIInterfaceOrientationMaskLandscape isStatusBarHidden:YES cancelListener:^{
//            NSLog(@"OnCancel: share is cancelled");
//        } failureListener:^(int errorCode, NSString *errorMessage) {
//           NSLog(@"OnFailure: %d  %@", errorCode, errorMessage);
//        } resultListener:^{
//            
//        }];
//    });
}

void SFGameHelper::copy2PasteBoard(const char *str)
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [NSString stringWithUTF8String:(str)];
    NSLog(@"copy str to paste board=%s", str);
}

void SFGameHelper::setSessionTimeout(int timeout)
{
//    FrontiaStatistics* statTracker = [Frontia getStatistics];
//    statTracker.sessionResumeInterval = timeout;//设置应用进入后台再回到前台为同一次session的间隔时间[0~600s],超过600s则设为600s，默认为30s
}

void SFGameHelper::enableExceptionLog()
{
//    FrontiaStatistics* statTracker = [Frontia getStatistics];
//    statTracker.enableExceptionLog = YES; // 是否允许截获并发送崩溃信息，请设置YES或者NO
}

void SFGameHelper::startStatistics(const char* reportId,const char* channelId)
{
//    FrontiaStatistics* statTracker = [Frontia getStatistics];
//    statTracker.channelId = [NSString stringWithUTF8String:channelId];//设置您的app的发布渠道
//    statTracker.logStrategy = FrontiaStatLogStrategyCustom;//根据开发者设定的时间间隔接口发送 也可以使用启动时发送策略
//    statTracker.logSendWifiOnly = YES; //是否仅在WIfi情况下发送日志数据
//    if (reportId) {
//        [statTracker startWithReportId:[NSString stringWithUTF8String:reportId]];
//    }
    
}

float SFGameHelper::getDensity()
{
    return 1.0;
}

int SFGameHelper::getDensityDpi()
{
    return 120;
}

std::string SFGameHelper::getManuFactuer()
{
    return "apple";
}

std::string SFGameHelper::getModel()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    NSString* result = @"";
    result = deviceString;
    if ([deviceString isEqualToString:@"iPhone1,1"])    result = @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    result =  @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    result =  @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    result =  @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    result =  @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,2"])    result =  @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone3,2"])    result =  @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPod1,1"])      result =  @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      result =  @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      result =  @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      result =  @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPad1,1"])      result =  @"iPad";
    if ([deviceString isEqualToString:@"iPad2,1"])      result =  @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      result =  @"iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])      result =  @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"i386"])         result =  @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       result =  @"Simulator";
    return [result UTF8String];
}

std::string SFGameHelper::getSystemVer()
{
    float systemVer = [[UIDevice currentDevice].systemVersion floatValue];
    NSString* versionStr = [NSString stringWithFormat:@"%f",systemVer];
    return [versionStr UTF8String];
}

void SFGameHelper::setAppUpdateType(int type, int tag)
{
}

void SFGameHelper::setAppCallback(int handler)
{
}

std::string SFGameHelper::urlEncode(const char* str)
{
    NSString* input = [NSString stringWithUTF8String:str];
    NSString *outputStr = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)input,
                                            NULL,
                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                            kCFStringEncodingUTF8));
    return [outputStr UTF8String];
}
std::string SFGameHelper::urlDecode(const char* str)
{
    NSString* input = [NSString stringWithUTF8String:str];
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@" "
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [outputStr length])];
    NSString* outStr =[outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    return [outStr UTF8String];
}

void SFGameHelper::setFloatBtnVisible(bool bVisible)
{
    
}

long long SFGameHelper::getRomFreeSpace()
{
    struct statfs buf;
    long long freespace = -1;
    if(statfs("/var", &buf) >= 0){
       freespace = (long long)(buf.f_bsize * buf.f_bfree);
    }
    //NSLog(@"手机剩余存储空间为：byte" ,freespace/1024/1024);
    return freespace;
}

long long SFGameHelper::getRamSpace()
{
    
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    long long ram = -1;
    ram = ((vm_page_size *vmStats.free_count));
    return ram;
}

std::string SFGameHelper::base64Encode(const char* str)
{
    if (str) {
        std::string aa =[[[IosSDKHelper sharedSKDHelper] base64Enocde:[NSString stringWithUTF8String:str]]UTF8String];
        return aa;
    }
    return "";
}
std::string SFGameHelper::base64Decode(const char* str)
{
    return str;
}


