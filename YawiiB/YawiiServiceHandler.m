//
//  YawiiServiceHandler.m
//  YawiiB
//
//  Created by wenqing zhou on 10/25/12.
//  Copyright (c) 2012 Yawii. All rights reserved.
//

#import "YawiiServiceHandler.h"

@implementation YawiiServiceHandler

-(void)requestForUrl:(NSURL *)url
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
        NSLog(@"response:%@",response);
        YawiiJSONPaser *parser=[[YawiiJSONPaser alloc] initWithResponse:response];
        parser.delegate=self;
        [parser parse];
    }
    else
    {
        NSLog(@"error in request url:%@",[error description]);
        [self.delegate failToRequestWithError:@"Network error!"];
    }
}

-(void)postRequestForUrl:(NSURL *)url dict:(NSDictionary *)dict
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request addPostValues:dict];
    NSLog(@"requesting...%@",url);
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
        NSLog(@"response:%@",response);
        YawiiJSONPaser *parser=[[YawiiJSONPaser alloc] initWithResponse:response];
        parser.delegate=self;
        [parser parse];
    }
    else
    {
        NSLog(@"error in request url:%@",[error description]);
       [self.delegate failToRequestWithError:@"Network error!"];
    }
}


#pragma JSONPaserDelegate methods
- (void)successfulToParse:(NSDictionary *)response
{
    [self.delegate successfulToRequest:response];
}
- (void)failToPaserWithError:(NSString *)errorStr;
{
    NSLog(@"Failed to parse!");
}

@end
