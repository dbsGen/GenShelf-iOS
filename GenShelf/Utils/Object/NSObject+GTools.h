//
//  NSObject+GTools.h
//  GenShelf
//
//  Created by Gen on 16/2/25.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^GToolsBlock)();

@interface NSObject (GTools)

- (void)performBlock:(GToolsBlock)block afterDelay:(NSTimeInterval)delay;

@end