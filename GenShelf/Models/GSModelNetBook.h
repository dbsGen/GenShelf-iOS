//
//  GSModelNetBook.h
//  GenShelf
//
//  Created by Gen on 16/2/25.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define BOOK_ITEM_UPDATE    @"book_item_update"
#define BOOK_ITEM_OVER      @"book_item_over"
#define BOOK_ITEM_FAILED    @"book_item_failed"
#define BOOK_ITEM_PAGES     @"book_item_pages"
#define BOOK_ITEM_DOWNLOAD  @"book_item_download"
#define BOOK_ITEM_PROGRESS  @"book_item_progress"
#define BOOK_ITEM_REMOVE    @"book_item_remove"

@class GSModelNetPage;
@class GSModelNetBook;

typedef enum : NSUInteger {
    GSBookStatusNotStart    = 0,
    GSBookStatusProgressing,
    GSBookStatusComplete,
    GSBookStatusPagesComplete,
} GSBookStatus;

@protocol GSBookItemDelegate <NSObject>

@optional
- (void)bookItem:(nullable GSModelNetBook *)item progress:(CGFloat)percent;
- (void)bookItem:(nullable GSModelNetBook *)item status:(GSBookStatus)status loading:(BOOL)loading;

@end

NS_ASSUME_NONNULL_BEGIN

@interface GSModelNetBook : NSManagedObject

@property (nonatomic, weak) id<GSBookItemDelegate> delegate;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) CGFloat percent;
@property (nonatomic, assign) GSBookStatus bookStatus;

- (void)checkStatues;
- (void)loadPages:(NSOrderedSet<GSModelNetPage *> *)pages;

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

+ (NSOrderedSet<GSModelNetBook *> *)cachedItems:(NSInteger*)page hasNext:(BOOL*)hasNext expire:(BOOL *)expire;
+ (void)cacheItems:(NSOrderedSet<GSModelNetBook*> *)items page:(NSInteger)page hasNext:(BOOL)hasNext;
+ (void)cleanCachedItems;

- (void)pageComplete:(GSModelNetPage *)page;

@end

NS_ASSUME_NONNULL_END

#import "GSModelNetBook+CoreDataProperties.h"
