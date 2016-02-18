//
//  GCallback.h
//  GTween
//
//  Created by zrz on 14-7-27.
//  Copyright (c) 2014年 zrz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^GCallbackBlock)();

@interface GCallback : NSObject

@property (nonatomic, readonly) NSArray *targets;
- (void)addTarget:(id)target action:(SEL)action with:(id)userData;
- (void)addBlock:(GCallbackBlock)block;
- (void)invoke;
- (void)clean;

@end
