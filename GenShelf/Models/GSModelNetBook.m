//
//  GSModelNetBook.m
//  GenShelf
//
//  Created by Gen on 16/2/25.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSModelNetBook.h"
#import "GSModelNetPage.h"
#import "GCoreDataManager.h"
#import "GSModelHomeData.h"
#import "GSGlobals.h"

const NSTimeInterval GSTimeADay = 3600*3;

@interface GSModelNetBook ()

@property (nonatomic, assign) NSInteger count;

@end

@implementation GSModelNetBook

@synthesize percent = _percent, loading = _loading, delegate = _delegate;

- (id)init {
    self = [super init];
    if (self) {
        _loading = NO;
    }
    return self;
}

- (void)setPercent:(CGFloat)percent {
    if (percent != _percent) {
        _percent = percent;
        if ([_delegate respondsToSelector:@selector(bookItem:progress:)]) {
            [_delegate bookItem:self progress:_percent];
        }
    }
}

- (NSInteger)count {
    return self.readyCount.integerValue;
}

- (void)setCount:(NSInteger)count {
    count = MIN(count, self.pages.count);
    if (self.count != count) {
        self.readyCount = [NSNumber numberWithInteger:count];
        if (!self.pages.count) {
            self.percent = 0;
        }else
            self.percent = (float)count / self.pages.count;
    }
}

- (GSBookStatus)bookStatus {
    return [self.status integerValue];
}

- (void)checkStatues {
    int count = 0;
    for (GSModelNetPage *page in self.pages) {
        if (page.pageStatus == GSPageStatusComplete) {
            count ++;
        }
    }
    _percent = (float)count / self.pages.count;
    if (count == self.pages.count) {
        self.bookStatus = GSBookStatusPagesComplete;
    }else if (self.bookStatus == GSBookStatusPagesComplete){
        self.bookStatus = GSBookStatusComplete;
    }
}

- (void)loadPages:(NSOrderedSet<GSModelNetPage *> *)pages {
    NSInteger count = self.pages.count;
    for (GSModelNetPage *item in pages) {
        item.index = [NSNumber numberWithInteger:count++];
        item.book = self;
        item.source = self.source;
    }
    [self save];
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_ITEM_UPDATE
                                                        object:self
                                                      userInfo:@{@"add": pages}];
}



- (void)setStatus:(GSBookStatus)status loading:(BOOL)loading {
    BOOL changed = NO;
    if (self.bookStatus != status) {
        self.bookStatus = status;
        changed = YES;
    }
    if (_loading != loading) {
        _loading = loading;
        changed = YES;
    }
    if (changed) {
        if ([_delegate respondsToSelector:@selector(bookItem:status:loading:)]) {
            [_delegate bookItem:self status:self.bookStatus loading:_loading];
        }
    }
}

- (void)setBookStatus:(GSBookStatus)status {
    if (self.bookStatus != status) {
        self.status = [NSNumber numberWithInteger:status];
        if ([_delegate respondsToSelector:@selector(bookItem:status:loading:)]) {
            [_delegate bookItem:self status:status loading:_loading];
        }
    }
}

- (void)setLoading:(BOOL)loading {
    if (_loading != loading) {
        _loading = loading;
        if ([_delegate respondsToSelector:@selector(bookItem:status:loading:)]) {
            [_delegate bookItem:self status:self.bookStatus loading:_loading];
        }
    }
}


- (void)startLoading {
    self.loading = YES;
}

- (void)complete {
    [self setStatus:GSBookStatusComplete loading:NO];
    [self save];
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_ITEM_OVER
                                                        object:self
                                                      userInfo:nil];
}

- (void)failed {
    self.loading = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_ITEM_FAILED
                                                        object:self
                                                      userInfo:nil];
}

- (void)cancel {
    self.loading = false;
}

- (void)reset {
    [self removePages:self.pages];
    self.bookStatus = GSBookStatusProgressing;
    [self save];
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_ITEM_UPDATE
                                                        object:self
                                                      userInfo:nil];
}

- (void)pagesLoading {
    [self setStatus:GSBookStatusComplete loading:YES];
}

- (void)pagesComplete {
    [self setStatus:GSBookStatusPagesComplete loading:NO];
    [self save];
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_ITEM_PAGES
                                                        object:self
                                                      userInfo:nil];
}

- (void)pageProgress {
    if (!self.loading && self.bookStatus != GSBookStatusPagesComplete) {
        self.loading = YES;
    }
    self.count += 1;
    [self save];
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_ITEM_PROGRESS
                                                        object:self
                                                      userInfo:nil];
}

- (void)remove {
    self.mark = [NSNumber numberWithBool:NO];
    for (GSModelNetPage *page in self.pages) {
        [page remove];
    }
    [self setStatus:GSBookStatusNotStart loading:NO];
    [self save];
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_ITEM_REMOVE
                                                        object:self
                                                      userInfo:nil];
}

- (void)download {
    self.loading = YES;
    self.mark = [NSNumber numberWithBool:YES];
    self.downloadDate = [NSDate date];
    [self save];
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_ITEM_DOWNLOAD
                                                        object:self
                                                      userInfo:nil];
}

#pragma mark - End Progress

+ (NSOrderedSet<GSModelNetBook*> *)cachedItems:(NSInteger*)page hasNext:(BOOL*)hasNext expire:(BOOL *)expire {
    NSArray *all = [GSModelHomeData fetch:[NSPredicate predicateWithFormat:@"source == %@", [GSGlobals selectedDataControl]]];
    if (all.count > 0) {
        GSModelHomeData *data = all.firstObject;
        if (page)
            *page = data.page.integerValue;
        if (hasNext)
            *hasNext = data.hasNext.boolValue;
        if (expire) {
            *expire = [[data.date dateByAddingTimeInterval:GSTimeADay] compare:[NSDate date]] == NSOrderedAscending;
        }
        return data.books;
    }
    return nil;
}

+ (void)cacheItems:(NSOrderedSet<GSModelNetBook*> *)items page:(NSInteger)page hasNext:(BOOL)hasNext {
    NSArray *all = [GSModelHomeData fetch:[NSPredicate predicateWithFormat:@"source == %@", [GSGlobals selectedDataControl]]];
    for (GSModelHomeData *data in all) {
        [data remove];
    }
    GSModelHomeData *hd = [GSModelHomeData create];
    hd.source = [GSGlobals selectedDataControl];
    hd.page = [NSNumber numberWithInteger:page];
    hd.hasNext = [NSNumber numberWithBool:hasNext];
    hd.date = [NSDate date];
    hd.books = items;
    [[GCoreDataManager shareManager] save];
}

+ (void)cleanCachedItems {
    NSArray *all = [GSModelHomeData fetch:[NSPredicate predicateWithFormat:@"source == %@", [GSGlobals selectedDataControl]]];
    for (GSModelHomeData *data in all) {
        [data remove];
    }
}

- (void)pageComplete:(GSModelNetPage *)page {
    for (GSModelNetPage *pt in self.pages) {
        if (pt.pageStatus != GSPageStatusComplete) {
            return;
        }
    }
    [self pagesComplete];
}

- (void)awakeFromFetch {
    if (self.source == nil) {
        self.source = @"Lofi";
    }
    self.percent = (float)self.count / self.pages.count;
}

@end
