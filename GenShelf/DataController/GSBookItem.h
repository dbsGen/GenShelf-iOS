//
//  GSNetBook.h
//  GenShelf
//
//  Created by Gen on 16/2/20.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSPageItem.h"
#import "GSModelNetBook.h"

#define BOOK_ITEM_UPDATE    @"book_item_update"
#define BOOK_ITEM_OVER      @"book_item_over"
#define BOOK_ITEM_FAILED    @"book_item_failed"

typedef enum : NSUInteger {
    GSBookItemStatusNotStart    = 0,
    GSBookItemStatusProgressing,
    GSBookItemStatusComplete,
} GSBookItemStatus;

@interface GSBookItem : NSObject

- (id)initWithModel:(GSModelNetBook*)book;
- (GSModelNetBook *)model;

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *pageUrl;
@property (nonatomic, retain) NSString *imageUrl;
@property (nonatomic, retain) NSString *otherData;

@property (nonatomic, assign) GSBookItemStatus status;
@property (nonatomic, readonly) NSArray<GSPageItem *> *pages;
@property (nonatomic, assign) BOOL loading;

- (void)loadPages:(NSArray<GSPageItem *> *)pages;

- (void)startLoading;
- (void)complete;
- (void)failed;
- (void)reset;

+ (NSArray *)cachedItems:(NSInteger*)page hasNext:(BOOL*)hasNext expire:(BOOL *)expire;
+ (void)cacheItems:(NSArray *)items page:(NSInteger)page hasNext:(BOOL)hasNext;

@end
