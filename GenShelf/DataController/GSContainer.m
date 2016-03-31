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
    NSMutableDictionary<NSString* ,GSContainer *> *_containers;
}

- (id)init {
    self = [super init];
    if (self) {
        _containers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSDictionary<NSString* ,GSContainer<id>*>*)containers {
    return _containers;
}

- (void)addObject:(id)object forKey:(NSString *)key {
    [_containers setObject:[GSContainer containerWithObject:object] forKey:key];
}

- (void)removeObjectForKey:(NSString *)key {
    [_containers removeObjectForKey:key];
}

- (id)objectForKey:(NSString *)key {
    GSContainer *container = [_containers objectForKey:key];
    if (container) return container.object;
    return nil;
}

@end