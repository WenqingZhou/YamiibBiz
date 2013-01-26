//
//  URLHandler.m
//  YawiiB
//
//  Created by wenqing zhou on 10/27/12.
//  Copyright (c) 2012 Yawii. All rights reserved.
//

#import "URLHandler.h"
#import "NSString+MD5.h"
#import "AccountInfoHandler.h"
#import "Constant.h"
#import "Utility.h"

static URLHandler *_urlHandler;

@implementation URLHandler

+(URLHandler *)sharedURLHandler
{
    if (!_urlHandler) {
        _urlHandler=[[URLHandler alloc] init];
    }
    return _urlHandler;
}

- (URLHandler *)init
{
    self=[super init];
#ifdef DEV_MODE
    baseUrl=WEBSERVICE_BASE_DEV_URL;
#elif RELEASE_MODE
    baseUrl=WEBSERVICE_BASE_URL;
#endif
    

    
    
    
    return self;
}

- (NSString *)loginURL
{
    return [NSString stringWithFormat:@"%@default/login",baseUrl];
}

- (NSString *)newSpecial:(NSDictionary *)params
{
    return [NSString stringWithFormat:@"%@special/sendInstant",baseUrl];
}

-(NSString *)getHidParameter
{
    return [NSString stringWithFormat:@"&"];
}

- (NSString *)languageUrl
{
    return [NSString stringWithFormat:@"lang=%@",[Utility currentLanguageString]];
}



@end
