//
//  LoginDelegate.h
//  YawiiB
//
//  Created by wenqing zhou on 10/25/12.
//  Copyright (c) 2012 Yawii. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YawiiServiceDelegate

- (void)successfulToRequest:(NSDictionary *)response;
- (void)failToRequestWithError:(NSString *)errorStr;
@end
