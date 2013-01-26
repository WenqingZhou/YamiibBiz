//
//  AccountInfoHandler.m
//  YawiiB
//
//  Created by wenqing zhou on 10/25/12.
//  Copyright (c) 2012 Yawii. All rights reserved.
//

#import "AccountInfoHandler.h"
#import "Utility.h"
#import "ConstantStrings.h"

static AccountInfoHandler *_handler;

@implementation AccountInfoHandler

@synthesize _dict,_infoPath;

+(AccountInfoHandler *)sharedAccountHandler
{
    if (!_handler)
    {
        _handler=[[AccountInfoHandler alloc] init];
        _handler._infoPath=[NSString stringWithFormat:@"%@/%@",[Utility getDocumentDir],@"/info"];
        _handler._dict=[_handler read];
    }
    return _handler;
}

- (void)updateInfo:(NSMutableDictionary *)newInfo
{
    [self removeOldLogoIfExist:[self._dict objectForKey:@"url_logo_local"]];
    self._dict=nil;
    self._dict=newInfo;
    [self._dict setObject:[NSNumber numberWithBool:YES] forKey:ACCOUNT_DICT_USER_LOGINED];
    NSString *picPath=[[newInfo objectForKey:@"merchant"] objectForKey:@"url_logo"];
    NSURL *picUrl=[NSURL URLWithString:picPath];
    NSString *localPath=[NSString stringWithFormat:@"%@/%@",[Utility getDocumentDir],[[picPath pathComponents] lastObject]];
    NSLog(@"LocalPath:%@",localPath);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:picUrl];
    [request setDownloadDestinationPath:localPath];
    NSMutableDictionary *accountInfo=[self._dict objectForKey:@"merchant"];
    [accountInfo setObject:localPath forKey:ACCOUNT_DICT_URL_LOGO_LOCAL];
    [request setDelegate:self];
    [request startAsynchronous];
    [self write];
}

- (void)removeOldLogoIfExist:(NSString *)path
{
    if (path)
    {
        NSFileManager *fileManager=[NSFileManager defaultManager];
        NSError *error;
        if ([fileManager fileExistsAtPath:path])
        {
            if ([fileManager removeItemAtPath:path error:&error]) {
                NSLog(@"Old logo deleted!");
            }
            else
            {
                NSLog(@"Failed to delete old pic!");
            }
        }
    }
}

-(void)logout
{
    [self._dict setObject:[NSNumber numberWithBool:NO] forKey:ACCOUNT_DICT_USER_LOGINED];
    [self write];
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"Picture downloaded!,%@",[[request url] path]);
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"Picture failed to download!,%@",[request url]);
}

-(NSMutableDictionary *)read
{
	NSFileManager *fileManager=[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self._infoPath])
    {
        NSLog(@"Loading info..");
        return [NSMutableDictionary dictionaryWithContentsOfFile:self._infoPath];
    }
    else
    {
        return nil;
    }
}

-(BOOL)write
{
	NSFileManager *fileManager=[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self._infoPath])
    {
        NSLog(@"Overwrite info..");
        return [self._dict writeToFile:self._infoPath atomically:YES];
    }
    else
    {
        NSLog(@"Initialize info..");
        return [self._dict writeToFile:self._infoPath atomically:YES];
    }
}

- (NSString *)stringForService
{
    return [NSString stringWithFormat:@"hid=%@&key=%@",[_dict objectForKey:ACCOUNT_DICT_HID],[_dict objectForKey:ACCOUNT_DICT_KEY]];
}

- (NSString *)hid
{
    return [_dict objectForKey:ACCOUNT_DICT_HID];
}

- (NSString *)key
{
    return [_dict objectForKey:ACCOUNT_DICT_KEY];
}



@end
