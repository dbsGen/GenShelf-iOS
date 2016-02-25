//
//  NSObject+GTools.m
//  GenShelf
//
//  Created by Gen on 16/2/25.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "NSObject+GTools.h"

@implementation NSObject (GTools)

- (void)performBlock:(GToolsBlock)block afterDelay:(NSTimeInterval)delay {
    [self performSelector:@selector(blockCallback:)
               withObject:block
               afterDelay:delay];
}

- (void)blockCallback:(GToolsBlock)block {
    if (block) {
        block();
    }
}

@end
