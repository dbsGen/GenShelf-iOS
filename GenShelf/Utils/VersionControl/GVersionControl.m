//
//  GVersionControl.m
//  GenShelf
//
//  Created by Gen on 16/3/22.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GVersionControl.h"

GVersionControl *__instance;

@implementation GVersionControl

+ (instancetype)instance {
    @synchronized(self) {
        if (!__instance) {
            __instance = [[GVersionControl alloc] init];
        }
    }
    return __instance;
}

- (id)init {
    self = [super init];
    if (self) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        
        NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        NSLog(@"%@", app_Version);
    }
    return self;
}

@end
