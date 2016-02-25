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

const NSTimeInterval GSTimeADay = 3600*24;

@implementation GSBookItem {
    NSMutableArray<GSPageItem *> *_page_items;
    GSModelNetBook *_model;
}

- (id)init {
    self = [super init];
    if (self) {
        _status = GSBookItemStatusNotStart;
        _page_items = [[NSMutableArray alloc] init];
        _loading = false;
    }
    return self;
}

- (id)initWithModel:(GSModelNetBook *)book {
    self = [self init];
    if (self) {
        _model = book;
        _status = book.status.integerValue;
        _title = book.title;
        _pageUrl = book.pageUrl;
        _imageUrl = book.imageUrl;
        _otherData = book.otherData;
        _loading = false;
        for (GSModelNetPage *model in book.pages) {
            [_page_items addObject:[[GSPageItem alloc] initWithModel:model]];
        }
    }
    return self;
}

- (GSModelNetBook *)model {
    if (!_model) {
        _model = [GSModelNetBook fetchOrCreate:[NSPredicate predicateWithFormat:@"pageUrl == %@", _pageUrl]
                                   constructor:^(id object) {
                                       GSModelNetBook *book = object;
                                       book.title = _title;
                                       book.pageUrl = _pageUrl;
                                       book.imageUrl = _imageUrl;
                                       book.otherData = _otherData;
                                       book.status = [NSNumber numberWithInteger:_status];
                                   }];
    }
    return _model;
}

- (void)updateData {
    GSModelNetBook *b = [self model];
    b.status = [NSNumber numberWithInteger:_status];
    b.otherData = _otherData;
    NSMutableArray *arr = [NSMutableArray array];
    for (GSPageItem *pitem in self.pages) {
        [arr addObject:pitem.model];
    }
    [b setPages:[NSOrderedSet orderedSetWithArray:arr]];
}

- (NSArray<GSPageItem *>*)pages {
    return _page_items;
}

- (void)loadPages:(NSArray<GSPageItem *> *)pages {
    for (GSPageItem *item in pages) {
        item.index = _page_items.count;
        [_page_items addObject:item];
    }
    [self updateData];
    [[GCoreDataManager shareManager] save];
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_ITEM_UPDATE
                                                        object:self
                                                      userInfo:@{@"add": pages}];
}

- (void)startLoading {
    _status = GSBookItemStatusProgressing;
    _loading = TRUE;
}

- (void)complete {
    _status = GSBookItemStatusComplete;
    [self updateData];
    [[GCoreDataManager shareManager] save];
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_ITEM_OVER
                                                        object:self
                                                      userInfo:nil];
    _loading = false;
}

- (void)failed {
    _status = GSBookItemStatusProgressing;
    _loading = false;
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_ITEM_FAILED
                                                        object:self
                                                      userInfo:nil];
}

+ (NSArray *)cachedItems:(NSInteger *)page hasNext:(BOOL *)hasNext expire:(BOOL *)expire {
    NSArray *all = [GSModelHomeData all];
    if (all.count > 0) {
        NSMutableArray *res = [NSMutableArray array];
        GSModelHomeData *data = all.firstObject;
        for (GSModelNetBook *book in data.books) {
            [res addObject:[[GSBookItem alloc] initWithModel:book]];
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

@end
