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

@property (nonatomic, readonly) NSArray<GSContainer<ObjectType>*> *containers;
- (void)addObject:(ObjectType)object;
- (void)removeObject:(ObjectType)object;
- (ObjectType)object:(GSContainerQueueBlock)checker;

@end