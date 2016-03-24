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
#define BOOK_ITEM_PAGES     @"book_item_pages"
#define BOOK_ITEM_DOWNLOAD  @"book_item_download"
#define BOOK_ITEM_PROGRESS  @"book_item_progress"
#define BOOK_ITEM_REMOVE    @"book_item_remove"

typedef enum : NSUInteger {
    GSBookItemStatusNotStart    = 0,
    GSBookItemStatusProgressing,
    GSBookItemStatusComplete,
    GSBookItemStatusPagesComplete,
} GSBookItemStatus;

@protocol GSBookItemDelegate <NSObject>

@optional
- (void)bookItem:(GSBookItem *)item progress:(CGFloat)percent;
- (void)bookItem:(GSBookItem *)item status:(GSBookItemStatus)status loading:(BOOL)loading;

@end

@interface GSBookItem : NSObject {
    CGFloat _percent;
}

+ (NSArray<GSBookItem *> *)items:(NSArray<GSModelNetBook *> *)books;
+ (GSBookItem *)itemWithUrl:(NSString *)pageUrl;
+ (GSBookItem *)itemWithModel:(GSModelNetBook*)book;
- (GSModelNetBook *)model;

@property (nonatomic, retain) NSString *source;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *pageUrl;
@property (nonatomic, retain) NSString *imageUrl;
@property (nonatomic, retain) NSString *otherData;
@property (nonatomic, retain) NSDate *downloadDate;
@property (nonatomic, assign) BOOL mark;

@property (nonatomic, assign) GSBookItemStatus status;
@property (nonatomic, readonly) NSArray<GSPageItem *> *pages;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, readonly) CGFloat percent;

@property (nonatomic, weak) id<GSBookItemDelegate> delegate;

- (void)loadPages:(NSArray<GSPageItem *> *)pages;

- (void)startLoading;
- (void)complete;
- (void)failed;
- (void)cancel;
- (void)reset;
- (void)pagesLoading;
- (void)pagesComplete;
- (void)download;
- (void)pageProgress;
- (void)remove;

+ (NSArray *)cachedItems:(NSInteger*)page hasNext:(BOOL*)hasNext expire:(BOOL *)expire;
+ (void)cacheItems:(NSArray *)items page:(NSInteger)page hasNext:(BOOL)hasNext;
+ (void)cleanCachedItems;

- (void)pageComplete:(GSPageItem *)page;

@end
