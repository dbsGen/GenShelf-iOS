//
//  GSHomeTask.h
//  GenShelf
//
//  Created by Gen on 16/3/15.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSTask.h"
#import "GSModelNetBook.h"

@interface GSRequestTask : GSTask {
@protected
    BOOL        _hasMore;
    NSUInteger  _index;
    NSArray<GSModelNetBook*> *_books;
}

@property (nonatomic, readonly) NSUInteger index;
@property (nonatomic, readonly) NSArray<GSModelNetBook*> *books;
@property (nonatomic, readonly) BOOL hasMore;

@end
