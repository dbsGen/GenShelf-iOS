//
//  GSPageItem.m
//  GenShelf
//
//  Created by Gen on 16/2/23.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSPageItem.h"
#import "GCoreDataManager.h"

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
                                       GSModelNetPage *book = object;
                                       book.index = [NSNumber numberWithInteger:_index];
                                       book.status = [NSNumber numberWithInteger:_status];
                                       book.pageUrl = _pageUrl;
                                       book.imageUrl = _imageUrl;
                                       book.thumUrl = _thumUrl;
                                   }];
    }
    return _model;
}

@end
