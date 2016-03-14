//
//  GSContainer.m
//  GenShelf
//
//  Created by Gen on 16/3/14.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSContainer.h"

@implementation GSContainer 

+ (instancetype)containerWithObject:(id)object {
    GSContainer *con = [[self alloc] init];
    con.object = object;
    return con;
}

@end

@implementation GSContainerQueue {
    NSMutableArray<GSContainer *> *_containers;
}

- (id)init {
    self = [super init];
    if (self) {
        _containers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray<GSContainer*>*)containers {
    return _containers;
}

- (void)addObject:(id)object {
    [_containers addObject:[GSContainer containerWithObject:object]];
}

- (void)removeObject:(id)object {
    __block GSContainer *target = nil;
    [_containers enumerateObjectsUsingBlock:^(GSContainer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.object == object) {
            *stop = YES;
            target = obj;
        }
    }];
    if (target)  [_containers removeObject:target];
}

- (id)object:(GSContainerQueueBlock)block {
    __block GSContainer *target = nil;
    [_containers enumerateObjectsUsingBlock:^(GSContainer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (block(obj.object)) {
            *stop = YES;
            target = obj;
        }
    }];
    return target.object;
}

@end