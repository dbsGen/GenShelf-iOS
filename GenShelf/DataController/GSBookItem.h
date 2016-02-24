//
//  GSNetBook.h
//  GenShelf
//
//  Created by Gen on 16/2/20.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSPageItem.h"

#define BOOK_ITEM_UPDATE    @"book_item_update"

typedef enum : NSUInteger {
    GSBookItemStatusNotStart    = 0,
    GSBookItemStatusProgressing,
    GSBookItemStatusComplete,
} GSBookItemStatus;

@interface GSBookItem : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *pageUrl;
@property (nonatomic, retain) NSString *imageUrl;

@property (nonatomic, assign) GSBookItemStatus status;
@property (nonatomic, readonly) NSArray<GSPageItem *> *pages;

- (void)loadPages:(NSArray<GSPageItem *> *)pages;

@end
