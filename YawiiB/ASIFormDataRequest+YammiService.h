//
//  PostRequestComposer.h
//  YamiiC
//
//  Created by wenqing zhou on 11/10/12.
//  Copyright (c) 2012 Yamii Oy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"

@interface ASIFormDataRequest (YammiService)

- (void)addPostValues:(NSDictionary *)dict;

@end
