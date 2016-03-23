//
//  AppDelegate.m
//  GenShelf
//
//  Created by Gen on 16/2/16.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "AppDelegate.h"
#import "GSHomeController.h"
#import "GSGlobals.h"
#import "GCoreDataManager.h"
#import "ASIHTTPRequest.h"
#import "GSLofiDataControl.h"
#import "GSEHentaiDataControl.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [ASIHTTPRequest sharedQueue].maxConcurrentOperationCount = 3;
    
    [GSGlobals registerDataControl:[[GSLofiDataControl alloc] init]];
    [GSGlobals registerDataControl:[[GSEHentaiDataControl alloc] init]];
    [GSGlobals runShadowsocksThread];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    GSHomeController *menu = [[GSHomeController alloc] init];
    self.window.rootViewController = menu;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [GSGlobals resetShadowsocks];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [[GCoreDataManager shareManager] save];
}

@end
