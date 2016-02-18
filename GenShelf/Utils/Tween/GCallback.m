//
//  GCallback.m
//  GTween
//
//  Created by zrz on 14-7-27.
//  Copyright (c) 2014年 zrz. All rights reserved.
//

#import "GCallback.h"



@interface GCallbackTarget : NSObject

@property (nonatomic) BOOL isBlock;
@property (nonatomic, weak) id target;
@property (nonatomic) SEL action;
@property (nonatomic, copy) GCallbackBlock block;
@property (nonatomic, strong) id userData;
+ (id)target:(id)target action:(SEL)action;
+ (id)targetWithBlock:(GCallbackBlock)block;
- (void)invoke;

@end

@implementation GCallback {
    NSMutableArray *_targets;
}

- (id)init
{
    self = [super init];
    if (self) {
        _targets = [NSMutableArray array];
    }
    return self;
}

- (NSArray*)targets
{
    NSArray *res;
    @synchronized(_targets) {
        res =[_targets copy];
    }
    return res;
}


- (void)addTarget:(id)target action:(SEL)action with:(id)userData
{
    GCallbackTarget *tar = [GCallbackTarget target:target action:action];
    tar.userData = userData;
    @synchronized(_targets) {
        [_targets addObject:tar];
    }
    
}
- (void)addBlock:(GCallbackBlock)block
{
    @synchronized(_targets) {
        [_targets addObject:[GCallbackTarget targetWithBlock:block]];
    }
}

- (void)invoke
{
    @synchronized(_targets) {
        [_targets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj invoke];
        }];
    }
}

- (void)clean
{
    @synchronized(_targets) {
        [_targets removeAllObjects];
    }
}

@end

@implementation GCallbackTarget

+ (id)target:(id)target action:(SEL)action
{
    GCallbackTarget *tar = [[self alloc] init];
    tar.target = target;
    tar.action = action;
    tar.isBlock = false;
    return tar;
}

+ (id)targetWithBlock:(GCallbackBlock)block
{
    GCallbackTarget *tar = [[self alloc] init];
    tar.block = block;
    tar.isBlock = true;
    return tar;
}

- (void)invoke
{
    if (self.isBlock) {
        self.block();
    }else {
        [self.target performSelector:self.action
                          withObject:nil];
    }
}

@end