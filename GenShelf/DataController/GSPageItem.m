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

@implementation GSPageItem {
    GSModelNetPage *_model;
}

- (id)initWithModel:(GSModelNetPage*)page {
    self = [self init];
    if (self) {
        _status = page.status.integerValue;
        _index = page.index.integerValue;
        _pageUrl = page.pageUrl;
        _imageUrl = page.imageUrl;
        _thumUrl = page.thumUrl;
    }
    return self;
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
                                   }];
    }
    return _model;
}

- (NSString *)imagePath {
    if (_status == GSPageItemStatusComplete) {
        return [[GSPictureManager defaultManager] path:self.book
                                                  page:self];
    }
    return nil;
}

- (void)updateData {
    GSModelNetPage *model = [self model];
    model.index = [NSNumber numberWithInteger:_index];
    model.status = [NSNumber numberWithInteger:_status];
    model.pageUrl = _pageUrl;
    model.imageUrl = _imageUrl;
    model.thumUrl = _thumUrl;
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
}

- (void)reset {
    _status = GSPageItemStatusNotStart;
    [self updateData];
    [[GCoreDataManager shareManager] save];
}

@end
