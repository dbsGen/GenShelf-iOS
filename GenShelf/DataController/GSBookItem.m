//
//  GSNetBook.m
//  GenShelf
//
//  Created by Gen on 16/2/20.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSBookItem.h"

@implementation GSBookItem {
    NSMutableArray<GSPageItem *> *_page_items;
}

- (id)init {
    self = [super init];
    if (self) {
        _status = GSBookItemStatusNotStart;
        _page_items = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray<GSPageItem *>*)pages {
    return _page_items;
}

- (void)loadPages:(NSArray<GSPageItem *> *)pages {
    for (GSPageItem *item in pages) {
        item.index = _page_items.count;
        [_page_items addObject:item];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_ITEM_UPDATE
                                                        object:self
                                                      userInfo:@{@"add": pages}];
}

@end
