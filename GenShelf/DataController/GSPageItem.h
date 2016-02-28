//
//  GSPageItem.h
//  GenShelf
//
//  Created by Gen on 16/2/23.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSModelNetPage.h"

#define PAGE_ITEM_SET_IMAGE     @"page_item_set_image"
#define PAGE_ITEM_REQUEST_IMAGE @"page_item_request_image"

typedef enum : NSUInteger {
    GSPageItemStatusNotStart    = 0,
    GSPageItemStatusProgressing,
    GSPageItemStatusComplete,
} GSPageItemStatus;

@interface GSPageItem : NSObject

@property (nonatomic, assign) GSPageItemStatus status;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong) NSString *pageUrl;
@property (nonatomic, strong) NSString *thumUrl;
@property (nonatomic, strong) NSString *imageUrl;

- (id)initWithModel:(GSModelNetPage*)page;
- (GSModelNetPage *)model;

- (void)updateData;

- (void)requestImage;
- (void)complete;
- (void)reset;

@end
