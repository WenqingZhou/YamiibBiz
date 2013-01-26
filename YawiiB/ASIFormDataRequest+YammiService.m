//
//  PostRequestComposer.m
//  YamiiC
//
//  Created by wenqing zhou on 11/10/12.
//  Copyright (c) 2012 Yamii Oy. All rights reserved.
//

#import "ASIFormDataRequest+YammiService.h"
#import "ConstantStrings.h"

@implementation ASIFormDataRequest (YammiService)

- (void)addPostValues:(NSDictionary *)dict
{
    for (NSString *key in dict) {
        [self addPostValue:[dict objectForKey:key] forKey:key];
        NSLog(@"add %@ to post header at key :%@",[dict objectForKey:key],key);
    }
    [self addPostValue:@"en_us" forKey:@"lang"];
}

@end

