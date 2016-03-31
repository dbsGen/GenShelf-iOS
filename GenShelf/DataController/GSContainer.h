//
//  GSContainer.h
//  GenShelf
//
//  Created by Gen on 16/3/14.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSContainer<ObjectType> : NSObject

@property (nonatomic, weak) ObjectType object;

+ (instancetype)containerWithObject:(ObjectType)object;

@end

typedef BOOL(^GSContainerQueueBlock)(id object);

@interface GSContainerQueue<ObjectType> : NSObject

@property (nonatomic, readonly) NSDictionary<NSString* ,GSContainer<ObjectType>*> *containers;
- (void)addObject:(ObjectType)object forKey:(NSString*)key;
- (void)removeObjectForKey:(NSString*)key;
- (ObjectType)objectForKey:(NSString*)key;

@end