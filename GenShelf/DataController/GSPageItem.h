//
//  GSPageItem.h
//  GenShelf
//
//  Created by Gen on 16/2/23.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSModelNetPage.h"

@class GSBookItem;

#define PAGE_ITEM_SET_IMAGE     @"page_item_set_image"
#define PAGE_ITEM_REQUEST_IMAGE @"page_item_request_image"

typedef enum : NSUInteger {
    GSPageItemStatusNotStart    = 0,
    GSPageItemStatusProgressing,
    GSPageItemStatusComplete,
} GSPageItemStatus;

@interface GSPageItem : NSObject

@property (nonatomic, retain) NSString *source;
@property (nonatomic, weak) GSBookItem *book;
@property (nonatomic, assign) GSPageItemStatus status;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong) NSString *pageUrl;
@property (nonatomic, strong) NSString *thumUrl;
@property (nonatomic, strong) NSString *custmorData;
@property (nonatomic, strong) NSString *imageUrl;

- (NSString *)imagePath;

+ (instancetype)itemWithUrl:(NSString *)pageUrl;
+ (instancetype)itemWithModel:(GSModelNetPage*)page;
- (GSModelNetPage *)model;

- (void)checkPage;
- (void)updateData;

- (void)requestImage;
- (void)complete;
- (void)reset;

@end
