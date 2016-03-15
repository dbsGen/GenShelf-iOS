//
//  GSDataController.m
//  GenShelf
//
//  Created by Gen on 16/2/20.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSDataControl.h"
#import "GSGlobals.h"
#import "GCoreDataManager.h"
#import "GSDataDefines.h"
#import "GSPictureManager.h"

@implementation GSDataControl

@synthesize name = _name, requestDelay = _requestDelay;

- (id)init {
    self = [super init];
    if (self) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
        _taskQueue = [[GSTaskQueue alloc] init];
        _progressingBooks = [[NSMutableArray alloc] init];
        [self loadProgressBooks];
    }
    return self;
}

- (void)updateProgressingBooks {
    for (NSInteger n = 0, t = _progressingBooks.count; n < t; n++) {
        GSBookItem *book = [_progressingBooks objectAtIndex:n];
        if (book.status == GSBookItemStatusPagesComplete || !book.mark) {
            [_progressingBooks removeObjectAtIndex:n];
            n --;
            t --;
        }
    }
}

- (NSInteger)removeProgressingBook:(GSBookItem *)book {
    NSInteger index = [_progressingBooks indexOfObject:book];
    if (index >= 0) {
        [_progressingBooks removeObjectAtIndex:index];
    }
    return index;
}

- (void)loadProgressBooks {
    NSArray<GSModelNetBook *> *books = [GSModelNetBook fetch:[NSPredicate predicateWithFormat:@"mark == YES AND status != %d", GSBookItemStatusPagesComplete]
                                                       sorts:@[[NSSortDescriptor sortDescriptorWithKey:@"downloadDate"
                                                          ascending:NO]]];
    for (GSModelNetBook *book in books) {
        [_progressingBooks addObject:[GSBookItem itemWithModel:book]];
    }
}

- (GSRequestTask *)mainRequest:(NSInteger)pageIndex {return nil;}
- (GSRequestTask *)searchRequest:(NSString *)keyword pageIndex:(NSInteger)pageIndex {return nil;}

- (NSArray *)progressingBooks {
    return _progressingBooks;
}
- (GSTask *)processBook:(GSBookItem *)book {return nil;}
- (GSTask *)downloadBook:(GSBookItem *)book {
    if (book.status != GSBookItemStatusPagesComplete &&
        [_progressingBooks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pageUrl == %@", book.pageUrl]].count == 0) {
        [_progressingBooks addObject:book];
    }
    return nil;
}

- (void)pauseBook:(GSBookItem *)book {}

- (NSInteger)deleteBook:(GSBookItem *)book {
    [[GSPictureManager defaultManager] deleteBook:book];
    if ([_progressingBooks containsObject:book]) {
        NSInteger index = [_progressingBooks indexOfObject:book];
        [self pauseBook:book];
        [_progressingBooks removeObject:book];
        return index;
    }
    return -1;
}

@end
