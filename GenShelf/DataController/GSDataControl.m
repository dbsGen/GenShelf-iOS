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

- (void)loadProgressBooks {
    NSArray<GSModelNetBook *> *books = [GSModelNetBook fetch:[NSPredicate predicateWithFormat:@"mark == YES AND status != %d", GSBookItemStatusPagesComplete]
                                                       sorts:@[[NSSortDescriptor sortDescriptorWithKey:@"downloadDate"
                                                          ascending:NO]]];
    for (GSModelNetBook *book in books) {
        [_progressingBooks addObject:[GSBookItem itemWithModel:book]];
    }
}

- (ASIHTTPRequest *)mainRequest:(NSInteger)pageIndex {
    ASIHTTPRequest *request = [GSGlobals requestForURL:[[self class] mainUrl:pageIndex]];
    return request;
}

- (ASIHTTPRequest *)searchRequest:(NSString *)keyword pageIndex:(NSInteger)pageIndex {
    ASIHTTPRequest *request = [GSGlobals requestForURL:[[self class] searchUrl:keyword pageIndex:pageIndex]];
    return request;
}

- (NSArray *)progressingBooks {
    return _progressingBooks;
}

+ (NSURL *)mainUrl:(NSInteger)pageIndex {
    return NULL;
}

+ (NSURL *)searchUrl:(NSString *)keyword pageIndex:(NSInteger)pageIndex {
    return NULL;
}

- (NSArray<GSBookItem *> *)parseMain:(NSString *)html hasNext:(BOOL *)hasNext {
    return [NSArray array];
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
    if ([_progressingBooks containsObject:book]) {
        NSInteger index = [_progressingBooks indexOfObject:book];
        [self pauseBook:book];
        [[GSPictureManager defaultManager] deleteBook:book];
        [_progressingBooks removeObject:book];
        return index;
    }
    return -1;
}

@end
