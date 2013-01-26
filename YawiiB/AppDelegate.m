//
//  AppDelegate.m
//  YawiiB
//
//  Created by wenqing zhou on 10/25/12.
//  Copyright (c) 2012 Yawii. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "Utility.h"
#import "AccountInfoHandler.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [_nvc release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //[Utility redirectNSLog];
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    [self loadFirstView];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)loadFirstView
{
    UIViewController *rootView;
    NSDictionary *userData=[[AccountInfoHandler sharedAccountHandler] _dict];
    NSLog(@"data:%@",userData);
    if ([[userData objectForKey:ACCOUNT_DICT_USER_LOGINED] boolValue])
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            rootView = [[AddSpecialViewController alloc] initWithNibName:@"AddSpecialViewController_iPhone" bundle:nil];
        } else
        {
            rootView = [[AddSpecialViewController alloc] initWithNibName:@"AddSpecialViewController_iPad" bundle:nil];
        }
    }
    else
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            rootView = [[[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil] autorelease];
        } else {
            rootView = [[[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil] autorelease];
        }
    }
    _nvc=[[UINavigationController alloc] initWithRootViewController:rootView];
    self.window.rootViewController = self.nvc;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
