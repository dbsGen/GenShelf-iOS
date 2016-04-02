//
//  GSModelNetPage.h
//  GenShelf
//
//  Created by Gen on 16/2/25.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define PAGE_ITEM_REQUEST_IMAGE @"page_item_request_image"
#define PAGE_ITEM_SET_IMAGE     @"page_item_set_image"

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

- (NSString *)imagePath;

- (void)requestImage;
- (void)complete;
- (void)reset;

@end

NS_ASSUME_NONNULL_END

#import "GSModelNetPage+CoreDataProperties.h"
