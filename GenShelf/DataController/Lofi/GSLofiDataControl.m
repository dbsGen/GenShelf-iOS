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
        _pageTaskQueue = [[GSTaskQueue alloc] initWithSource:_name];
    }
    return self;
}

- (GSRequestTask *)mainRequest:(NSInteger)pageIndex  {
    GSLofiHomeTask *task = [self.taskQueue createTask:HomeRequestIdentifier
                                              creator:^GSTask *{
                                                  return [[GSLofiHomeTask alloc] initWithIndex:pageIndex
                                                                                         queue:self.operationQueue];
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

- (GSTask *)processBook:(GSModelNetBook *)book {
    [super processBook:book];
    if (book.bookStatus < GSBookStatusComplete) {
        GSLofiBookTask *task = [self.taskQueue createTask:BookProcessIdentifier(book)
                                                  creator:^GSTask *{
                                                      return [[GSLofiBookTask alloc] initWithItem:book
                                                                                            queue:self.operationQueue];
                                                  }];
        return task;
    }
    return nil;
}

- (GSTask *)downloadBook:(GSModelNetBook *)book {
    [super downloadBook:book];
    NSString *identifier = BookDownloadIdentifier(book);
    if (book.bookStatus == GSBookStatusPagesComplete) {
        return nil;
    }else {
        if (book.bookStatus != GSBookStatusComplete) {
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
                                                          GSLofiDownloadTask *task = [[GSLofiDownloadTask alloc] initWithItem:book
                                                                                             queue:self.operationQueue];
                                                          task.downloadQueue = _pageTaskQueue;
                                                          return task;
                                                      }];
        [book download];
        return task;
    }
}

#undef URL_HOST

- (void)makeProperties {
    [self insertProperty:[GSDataProperty boolPropertyWithName:kGSLofiAdultKey
                                                 defaultValue:NO]];
    [self insertProperty:[GSDataProperty optionsPropertyWithName:kGSLofiSizeKey
                                                    defaultValue:1
                                                         options:@[@"780x", @"980x"]]];
}

@end
