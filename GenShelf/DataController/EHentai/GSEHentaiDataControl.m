//
//  GSLofiDataControl.m
//  GenShelf
//
//  Created by Gen on 16/2/20.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSEHentaiDataControl.h"
#import "GDataXMLNode.h"
#import "GSGlobals.h"
#import "NSObject+GTools.h"
#import "GSDataDefines.h"
#import "GSEHentaiBookTask.h"
#import "GSEHentaiDownloadTask.h"
#import "GSEHentaiHomeTask.h"
#import "GSEHentaiSearchTask.h"

@implementation GSEHentaiDataControl

- (id)init {
    self = [super init];
    if (self) {
        _name = @"EHentai";
        _requestDelay = 2;
        _pageTaskQueue = [[GSTaskQueue alloc] init];
    }
    return self;
}

- (GSRequestTask *)mainRequest:(NSInteger)pageIndex  {
    GSEHentaiHomeTask *task = [self.taskQueue createTask:HomeRequestIdentifier
                                              creator:^GSTask *{
                                                  return [[GSEHentaiHomeTask alloc] initWithIndex:pageIndex queue:self.operationQueue];
                                              }];
    return task;
}

- (GSRequestTask *)searchRequest:(NSString *)keyword pageIndex:(NSInteger)pageIndex {
    GSEHentaiSearchTask *task = [self.taskQueue createTask:SearchRequestIdentifier
                                                creator:^GSTask *{
                                                    return [[GSEHentaiSearchTask alloc] initWithKey:keyword
                                                                                           index:pageIndex
                                                                                           queue:self.operationQueue];
                                                }];
    return task;
}

- (GSTask *)processBook:(GSBookItem *)book {
    if (book.status < GSBookItemStatusComplete) {
        GSEHentaiBookTask *task = [self.taskQueue createTask:BookProcessIdentifier(book)
                                                  creator:^GSTask *{
                                                      return [[GSEHentaiBookTask alloc] initWithItem:book
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
        GSEHentaiDownloadTask *task = [self.taskQueue createTask:identifier
                                                      creator:^GSTask *{
                                                          GSEHentaiDownloadTask *task = [[GSEHentaiDownloadTask alloc] initWithItem:book
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
    [self insertProperty:[GSDataProperty propertyWithName:kGSEHentaiAdultKey
                                             defaultValue:[NSNumber numberWithBool:NO]
                                                     type:GSDataPropertyTypeBOOL]];
}

@end
