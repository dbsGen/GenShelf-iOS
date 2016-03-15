//
//  GSLofiDataControl.m
//  GenShelf
//
//  Created by Gen on 16/2/20.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSLofiDataControl.h"
#import "GDataXMLNode.h"
#import "GSGlobals.h"
#import "NSObject+GTools.h"
#import "GSDataDefines.h"
#import "GSLofiBookTask.h"
#import "GSLofiDownloadTask.h"
#import "GSLofiHomeTask.h"
#import "GSLofiSearchTask.h"

@implementation GSLofiDataControl

- (id)init {
    self = [super init];
    if (self) {
        _name = @"Lofi";
        _requestDelay = 2;
    }
    return self;
}

- (GSRequestTask *)mainRequest:(NSInteger)pageIndex  {
    GSLofiHomeTask *task = [self.taskQueue createTask:HomeRequestIdentifier
                                              creator:^GSTask *{
                                                  return [[GSLofiHomeTask alloc] initWithIndex:pageIndex queue:self.operationQueue];
                                              }];
    return task;
}

- (GSRequestTask *)searchRequest:(NSString *)keyword pageIndex:(NSInteger)pageIndex {
    GSLofiSearchTask *task = [self.taskQueue createTask:SearchRequestIdentifier
                                                creator:^GSTask *{
                                                    return [[GSLofiSearchTask alloc] initWithKey:keyword
                                                                                           index:pageIndex
                                                                                           queue:self.operationQueue];
                                                }];
    return task;
}

- (GSTask *)processBook:(GSBookItem *)book {
    if (book.status < GSBookItemStatusComplete) {
        GSLofiBookTask *task = [self.taskQueue createTask:BookProcessIdentifier(book)
                                                  creator:^GSTask *{
                                                      return [[GSLofiBookTask alloc] initWithItem:book
                                                                                            queue:self.operationQueue];
                                                  }];
        return task;
    }
    return nil;
}

- (GSTask *)downloadBook:(GSBookItem *)book {
    [super downloadBook:book];
    NSString *identifier = BookDownloadIdentifier(book);
    if (book.status == GSBookItemStatusPagesComplete) {
        return nil;
    }else {
        if (book.status != GSBookItemStatusComplete) {
            GSTask *processTask = nil;
            if (![self.taskQueue hasTaskI:book.pageUrl]) {
                processTask = [self processBook:book];
            }else {
                processTask = [self.taskQueue task:book.pageUrl];
            }
            [self.taskQueue retainTask:processTask];
        }
        GSLofiDownloadTask *task = [self.taskQueue createTask:identifier
                                                      creator:^GSTask *{
                                                          return [[GSLofiDownloadTask alloc] initWithItem:book
                                                                                                    queue:self.operationQueue];
                                                      }];
        [book download];
        return task;
    }
}

- (void)pauseBook:(GSBookItem *)book {
    GSTask *task = [self.taskQueue task:BookDownloadIdentifier(book)];
    if (task) {
        [task cancel];
    }
    task = [self.taskQueue task:BookProcessIdentifier(book)];
    if (task) {
        [task cancel];
    }
    [book cancel];
}

#undef URL_HOST

@end
