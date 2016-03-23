//
//  GSNetBook.m
//  GenShelf
//
//  Created by Gen on 16/2/20.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSBookItem.h"
#import "GCoreDataManager.h"
#import "GSModelHomeData.h"
#import "GSContainer.h"

const NSTimeInterval GSTimeADay = 3600*24;

static GSContainerQueue<GSBookItem*> *__cacheQueue = nil;

@implementation GSBookItem {
    NSMutableArray<GSPageItem *> *_page_items;
    GSModelNetBook *_model;
}

@synthesize percent = _percent;

+ (GSContainerQueue<GSBookItem*> *)cacheQueue {
    @synchronized(self) {
        if (!__cacheQueue) {
            __cacheQueue = [[GSContainerQueue<GSBookItem*> alloc] init];
        }
    }
    return __cacheQueue;
}

- (id)init {
    self = [super init];
    if (self) {
        _status = GSBookItemStatusNotStart;
        _page_items = [[NSMutableArray alloc] init];
        _loading = false;
        
        [[GSBookItem cacheQueue] addObject:self];
    }
    return self;
}

- (void)dealloc {
    [[GSBookItem cacheQueue] removeObject:self];
}

+ (NSArray<GSBookItem *> *)items:(NSArray<GSModelNetBook *> *)books {
    if (books) {
        NSMutableArray *arr = [NSMutableArray array];
        for (GSModelNetBook *b in books) {
            [arr addObject:[self itemWithModel:b]];
        }
        return arr;
    }
    return nil;
}

+ (GSBookItem *)itemWithUrl:(NSString *)pageUrl {
    GSBookItem *obj = [[GSBookItem cacheQueue] object:^BOOL(id object) {
        return [[object pageUrl] isEqualToString:pageUrl];
    }];
    if (obj) {
        return obj;
    }
    obj = [[GSBookItem alloc] init];
    obj.pageUrl = pageUrl;
    return obj;
}

+ (GSBookItem *)itemWithModel:(GSModelNetBook*)book {
    GSBookItem *ret = [self itemWithUrl:book.pageUrl];
    ret->_model = book;
    ret.status = book.status.integerValue;
    ret.title = book.title;
    ret.source = book.source;
    ret.pageUrl = book.pageUrl;
    ret.imageUrl = book.imageUrl;
    ret.otherData = book.otherData;
    ret.downloadDate = book.downloadDate;
    ret.mark = book.mark.boolValue;
    int count = 0;
    NSMutableArray *mArr = [NSMutableArray array];
    for (GSModelNetPage *model in book.pages) {
        GSPageItem *item = [GSPageItem itemWithModel:model];
        item.book = ret;
        [item checkPage];
        [mArr addObject:item];
        if (item.status == GSPageItemStatusComplete) {
            count ++;
        }
    }
    ret->_page_items = mArr;
    ret->_percent = (float)count / ret.pages.count;
    if (count == ret.pages.count && book.status.integerValue == GSBookItemStatusComplete) {
        ret.status = GSBookItemStatusPagesComplete;
        book.status = [NSNumber numberWithInt:GSBookItemStatusPagesComplete];
    }
    return ret;
}

- (GSModelNetBook *)model {
    if (!_model) {
        _model = [GSModelNetBook fetchOrCreate:[NSPredicate predicateWithFormat:@"pageUrl == %@", _pageUrl]
                                   constructor:^(id object) {
                                       GSModelNetBook *book = object;
                                       book.title = _title;
                                       book.source = _source;
                                       book.pageUrl = _pageUrl;
                                       book.imageUrl = _imageUrl;
                                       book.otherData = _otherData;
                                       book.downloadDate = _downloadDate;
                                       book.mark = [NSNumber numberWithBool:_mark];
                                       book.status = [NSNumber numberWithInteger:_status];
                                   }];
    }
    return _model;
}

- (void)updateData {
    GSModelNetBook *b = [self model];
    b.status = [NSNumber numberWithInteger:_status];
    b.otherData = _otherData;
    b.mark = [NSNumber numberWithBool:_mark];
    b.downloadDate = _downloadDate;
    b.source = _source;
    NSMutableArray *arr = [NSMutableArray array];
    for (GSPageItem *pitem in self.pages) {
        [arr addObject:pitem.model];
    }
    [b setPages:[NSOrderedSet orderedSetWithArray:arr]];
}

- (void)updatePercent {
    int count = 0;
    for (NSInteger n = 0, t = self.pages.count; n < t; n++) {
        if ([self.pages objectAtIndex:n].status == GSPageItemStatusComplete) {
            count ++;
        }
    }
    CGFloat n_per = (float)count / self.pages.count;
    if (n_per != _percent) {
        _percent = n_per;
        if ([_delegate respondsToSelector:@selector(bookItem:progress:)]) {
            [_delegate bookItem:self progress:_percent];
        }
    }
    if (count == self.pages.count) {
        [self pagesComplete];
    }
}

- (NSArray<GSPageItem *>*)pages {
    return _page_items;
}

- (void)loadPages:(NSArray<GSPageItem *> *)pages {
    for (GSPageItem *item in pages) {
        item.index = _page_items.count;
        item.book = self;
        item.source = _source;
        [item checkPage];
        [_page_items addObject:item];
    }
    [self updateData];
    [[GCoreDataManager shareManager] save];
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_ITEM_UPDATE
                                                        object:self
                                                      userInfo:@{@"add": pages}];
}

- (void)startLoading {
    self.loading = YES;
}

- (void)complete {
    [self setStatus:GSBookItemStatusComplete loading:NO];
    [self updateData];
    [[GCoreDataManager shareManager] save];
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

- (void)setStatus:(GSBookItemStatus)status loading:(BOOL)loading {
    BOOL changed = NO;
    if (_status != status) {
        _status = status;
        changed = YES;
    }
    if (_loading != loading) {
        _loading = loading;
        changed = YES;
    }
    if (changed) {
        if ([_delegate respondsToSelector:@selector(bookItem:status:loading:)]) {
            [_delegate bookItem:self status:_status loading:_loading];
        }
    }
}

- (void)setStatus:(GSBookItemStatus)status {
    if (_status != status) {
        _status = status;
        if ([_delegate respondsToSelector:@selector(bookItem:status:loading:)]) {
            [_delegate bookItem:self status:_status loading:_loading];
        }
    }
}

- (void)setLoading:(BOOL)loading {
    if (_loading != loading) {
        _loading = loading;
        if ([_delegate respondsToSelector:@selector(bookItem:status:loading:)]) {
            [_delegate bookItem:self status:_status loading:_loading];
        }
    }
}

- (void)reset {
    [_page_items removeAllObjects];
    self.status = GSBookItemStatusProgressing;
    [self updateData];
    [[GCoreDataManager shareManager] save];
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_ITEM_UPDATE
                                                        object:self
                                                      userInfo:nil];
}

- (void)pagesLoading {
    [self setStatus:GSBookItemStatusComplete loading:YES];
}

- (void)pagesComplete {
    [self setStatus:GSBookItemStatusPagesComplete loading:NO];
    [self updateData];
    [[GCoreDataManager shareManager] save];
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_ITEM_PAGES
                                                        object:self
                                                      userInfo:nil];
}

- (void)pageProgress {
    if (!self.loading && self.status != GSBookItemStatusPagesComplete) {
        self.loading = YES;
    }
    [self updatePercent];
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_ITEM_PROGRESS
                                                        object:self
                                                      userInfo:nil];
}

- (void)remove {
    _mark = NO;
    [self setStatus:GSBookItemStatusNotStart loading:NO];
    [self updateData];
    [[GCoreDataManager shareManager] save];
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_ITEM_REMOVE
                                                        object:self
                                                      userInfo:nil];
}

- (void)download {
    self.loading = YES;
    _mark = YES;
    _downloadDate = [NSDate date];
    [self updateData];
    [[GCoreDataManager shareManager] save];
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_ITEM_DOWNLOAD
                                                        object:self
                                                      userInfo:nil];
}

+ (NSArray *)cachedItems:(NSInteger *)page hasNext:(BOOL *)hasNext expire:(BOOL *)expire {
    NSArray *all = [GSModelHomeData all];
    if (all.count > 0) {
        NSMutableArray *res = [NSMutableArray array];
        GSModelHomeData *data = all.firstObject;
        for (GSModelNetBook *book in data.books) {
            [res addObject:[GSBookItem itemWithModel:book]];
        }
        if (page)
            *page = data.page.integerValue;
        if (hasNext)
            *hasNext = data.hasNext.boolValue;
        if (expire) {
            *expire = [[data.date dateByAddingTimeInterval:GSTimeADay] compare:[NSDate date]] == NSOrderedAscending;
        }
        return res;
    }
    return nil;
}

+ (void)cacheItems:(NSArray *)items page:(NSInteger)page hasNext:(BOOL)hasNext {
    NSArray *all = [GSModelHomeData all];
    for (GSModelHomeData *data in all) {
        [data remove];
    }
    GSModelHomeData *hd = [GSModelHomeData create];
    hd.page = [NSNumber numberWithInteger:page];
    hd.hasNext = [NSNumber numberWithBool:hasNext];
    hd.date = [NSDate date];
    for (GSBookItem *bi in items) {
        [bi updateData];
        [hd addBooksObject:bi.model];
    }
    [[GCoreDataManager shareManager] save];
}

- (void)pageComplete:(GSPageItem *)page {
    for (GSPageItem *pt in _page_items) {
        if (pt.status != GSPageItemStatusComplete) {
            return;
        }
    }
    [self pagesComplete];
}

@end
