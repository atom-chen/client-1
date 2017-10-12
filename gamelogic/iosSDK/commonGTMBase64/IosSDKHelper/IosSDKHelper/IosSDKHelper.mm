//
//  IosSDKHelper.m
//  IosSDKHelper
//
//  Created by youai on 14-5-15.
//  Copyright (c) 2014年 youai. All rights reserved.
//

#import "IosSDKHelper.h"
#import "GTMBase64.h"

@implementation IosSDKHelper


static IosSDKHelper* _sharedHelper;

+(MainSDKHelper*) sharedSKDHelper
{
    if (_sharedHelper == NULL) {
        _sharedHelper = [[IosSDKHelper alloc] init];
    }
    return _sharedHelper;
}

-(NSString*) base64Enocde:(NSString *)code
{
    NSString *result = [[NSString alloc] initWithData:[GTMBase64 encodeData:[code dataUsingEncoding:NSUTF8StringEncoding]]  encoding:NSUTF8StringEncoding];
    result = [result stringByReplacingOccurrencesOfString:@"=" withString:@"_REP_"];
    result = [result stringByReplacingOccurrencesOfString:@"+" withString:@"_RAP_"];
    result = [result stringByReplacingOccurrencesOfString:@"-" withString:@"_RBP_"];
    result = [result stringByReplacingOccurrencesOfString:@"\\" withString:@"_RCP_"];
    return result;
}
@end
