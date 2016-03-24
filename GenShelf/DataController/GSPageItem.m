//
//  GSPageItem.m
//  GenShelf
//
//  Created by Gen on 16/2/23.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSPageItem.h"
#import "GCoreDataManager.h"
#import "GSPictureManager.h"
#import "GSContainer.h"

static GSContainerQueue<GSPageItem*> *__cacheQueue = nil;

@implementation GSPageItem {
    GSModelNetPage *_model;
}

+ (GSContainerQueue<GSPageItem*> *)cacheQueue {
    @synchronized(self) {
        if (!__cacheQueue) {
            __cacheQueue = [[GSContainerQueue<GSPageItem*> alloc] init];
        }
    }
    return __cacheQueue;
}

- (id)init {
    self = [super init];
    if (self) {
        [[GSPageItem cacheQueue] addObject:self];
    }
    return self;
}

- (void)dealloc {
    [[GSPageItem cacheQueue] removeObject:self];
}

+ (instancetype)itemWithUrl:(NSString *)pageUrl {
    GSPageItem *ret = [[GSPageItem cacheQueue] object:^BOOL(id object) {
        return [[object pageUrl] isEqualToString:pageUrl];
    }];
    if (ret) {
        return ret;
    }
    ret = [[GSPageItem alloc] init];
    ret.pageUrl = pageUrl;
    return ret;
}

+ (instancetype)itemWithModel:(GSModelNetPage*)page {
    GSPageItem *ret = [self itemWithUrl:page.pageUrl];
    ret->_model = page;
    ret.status = page.status.integerValue;
    ret.index = page.index.integerValue;
    ret.pageUrl = page.pageUrl;
    ret.imageUrl = page.imageUrl;
    ret.thumUrl = page.thumUrl;
    ret.custmorData = page.custmorData;
    ret.source = page.source;
    return ret;
}

- (GSModelNetPage *)model {
    if (!_model) {
        _model = [GSModelNetPage fetchOrCreate:[NSPredicate predicateWithFormat:@"pageUrl == %@", _pageUrl]
                                   constructor:^(id object) {
                                       GSModelNetPage *page = object;
                                       page.index = [NSNumber numberWithInteger:_index];
                                       page.status = [NSNumber numberWithInteger:_status];
                                       page.pageUrl = _pageUrl;
                                       page.imageUrl = _imageUrl;
                                       page.thumUrl = _thumUrl;
                                       page.custmorData = _custmorData;
                                       page.source = _source;
                                   }];
    }
    return _model;
}
- (NSString *)source {
    if (!_source) {
        return @"Lofi";
    }
    return _source;
}

- (NSString *)imagePath {
    if (_status == GSPageItemStatusComplete) {
        return [self _imagePath];
    }
    return nil;
}

- (NSString *)_imagePath {
    return [[GSPictureManager defaultManager] path:self.book
                                              page:self];
}

- (void)checkPage {
    if (![[NSFileManager defaultManager] fileExistsAtPath:self._imagePath]) {
        _status = GSPageItemStatusNotStart;
    }else {
        _status = GSPageItemStatusComplete;
    }
    [self updateData];
}

- (void)updateData {
    GSModelNetPage *model = [self model];
    model.index = [NSNumber numberWithInteger:_index];
    model.status = [NSNumber numberWithInteger:_status];
    model.pageUrl = _pageUrl;
    model.imageUrl = _imageUrl;
    model.thumUrl = _thumUrl;
    model.custmorData = _custmorData;
    model.source = _source;
}

- (void)requestImage {
    _status = GSPageItemStatusProgressing;
    [self updateData];
    [[GCoreDataManager shareManager] save];
    [[NSNotificationCenter defaultCenter] postNotificationName:PAGE_ITEM_REQUEST_IMAGE
                                                        object:self
                                                      userInfo:@{@"src": self.imageUrl}];
}

- (void)complete {
    _status = GSPageItemStatusComplete;
    [self updateData];
    [[GCoreDataManager shareManager] save];
    [[NSNotificationCenter defaultCenter] postNotificationName:PAGE_ITEM_SET_IMAGE
                                                        object:self
                                                      userInfo:@{@"src": self.imageUrl}];
    [_book pageProgress];
}

- (void)reset {
    _status = GSPageItemStatusNotStart;
    [self updateData];
    [[GCoreDataManager shareManager] save];
}

@end
