//
//  GSModelNetPage.h
//  GenShelf
//
//  Created by Gen on 16/2/25.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


typedef enum : NSUInteger {
    GSPageStatusNotStart    = 0,
    GSPageStatusProgressing,
    GSPageStatusComplete,
} GSPageStatus;

NS_ASSUME_NONNULL_BEGIN

@class GSModelNetBook;

@interface GSModelNetPage : NSManagedObject

@property (nonatomic, assign) GSPageStatus pageStatus;
- (void)checkStatus;

@end

NS_ASSUME_NONNULL_END

#import "GSModelNetPage+CoreDataProperties.h"
