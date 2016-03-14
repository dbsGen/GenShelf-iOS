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

#define URL_HOST @"http://lofi.e-hentai.org/"
#define FILTER_STR @"?f_doujinshi=0&f_manga=0&f_artistcg=0&f_gamecg=0&f_western=0&f_non-h=1&f_imageset=0&f_cosplay=0&f_asianporn=0&f_misc=0&f_apply=Apply+Filter"

@implementation GSLofiDataControl

- (id)init {
    self = [super init];
    if (self) {
        _name = @"Lofi";
        _requestDelay = 2;
    }
    return self;
}

+ (NSURL *)mainUrl:(NSInteger)pageIndex {
    NSString *str = [[URL_HOST stringByAppendingString:FILTER_STR] stringByAppendingString:[NSString stringWithFormat:@"&page=%d", (int)pageIndex]];
    return [NSURL URLWithString:str];
}

+ (NSURL *)searchUrl:(NSString *)keyword pageIndex:(NSInteger)pageIndex {
    NSString *str = [URL_HOST stringByAppendingString:FILTER_STR];
    str = [NSString stringWithFormat:@"%@&page=%d&f_search=%@", str, (int)pageIndex, keyword];
    return [NSURL URLWithString:str];
}

- (GSHomeTask *)mainRequest:(NSInteger)pageIndex  {
    GSLofiHomeTask *task = [self.taskQueue createTask:HomeRequestIdentifier
                                              creator:^GSTask *{
                                                  return [[GSLofiHomeTask alloc] initWithIndex:pageIndex queue:self.operationQueue];
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
