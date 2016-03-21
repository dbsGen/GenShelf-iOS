//
//  GSLofiDownloadTask.m
//  GenShelf
//
//  Created by Gen on 16/2/28.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSLofiDownloadTask.h"
#import "GSGlobals.h"
#import "GDataXMLNode.h"
#import "GSDataDefines.h"
#import "GSPictureManager.h"

@interface GSLofiPageTask : GSTask <ASIHTTPRequestDelegate> {
    GSPageItem *_item;
    NSOperationQueue *_queue;
}

@property (nonatomic, strong) GSBookItem *bookItem;
@property (nonatomic, strong) ASIHTTPRequest *request;

- (id)initWithItem:(GSPageItem *)item queue:(NSOperationQueue *)queue;

@end

@implementation GSLofiPageTask

- (id)initWithItem:(GSPageItem *)item queue:(NSOperationQueue *)queue {
    self = [super init];
    if (self) {
        _item = item;
        _queue = queue;
        self.retryCount = 3;
        self.timeDelay = 1;
    }
    return self;
}

- (void)run {
    _request = [GSGlobals requestForURL:[NSURL URLWithString:_item.pageUrl]];
    _request.delegate = self;
    _request.tag = 1;
    [_queue addOperation:_request];
}

- (void)cancel {
    [super cancel];
    _request.delegate = nil;
    [_request cancel];
    _request = nil;
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    if (request == _request) {
        [self failed:request.error];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    if (request == _request) {
        if (request.tag == 1) {
            NSError *error = nil;
            GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithHTMLString:_request.responseString
                                                                           error:&error];
            CheckError
            GDataXMLElement *node = (GDataXMLElement*)[doc firstNodeForXPath:@"//div[@id='sd']//img[@id='sm']"
                                                                       error:&error];
            CheckError
            NSString *src = [node attributeForName:@"src"].stringValue;
            
            _item.imageUrl = src;
            [_item requestImage];
            _request = [GSGlobals requestForURL:[NSURL URLWithString:src]];
            _request.delegate = self;
            _request.tag = 2;
            [_queue addOperation:_request];
        }else if (request.tag == 2) {
            [[GSPictureManager defaultManager] insertPicture:_request.responseData
                                                        book:_bookItem
                                                        page:_item];
            [_item complete];
            [self complete];
        }
    }
}

@end

@implementation GSLofiDownloadTask

- (id)initWithItem:(GSBookItem *)item queue:(NSOperationQueue *)queue {
    self = [super init];
    if (self) {
        _item = item;
        _queue = queue;
        self.timeDelay = 1;
    }
    return self;
}

- (void)run {
    if (_item.status == GSBookItemStatusComplete) {
        [_item startLoading];
        _taskCount = 0;
        [_item.pages enumerateObjectsUsingBlock:^(GSPageItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.status != GSPageItemStatusComplete) {
                [_downloadQueue createTask:PageDownloadIdentifier(obj)
                                   creator:^GSTask *{
                                       GSLofiPageTask *task = [[GSLofiPageTask alloc] initWithItem:obj
                                                                                             queue:_queue];
                                       task.bookItem = _item;
                                       task.delegate = self;
                                       _taskCount ++;
                                       return task;
                                   }];
            }
        }];
    }else {
        [self failed:[NSError errorWithDomain:@"目标未完成"
                                         code:102
                                     userInfo:nil]];
    }
}

- (void)cancel {
    [super cancel];
    [self stopTasks];
}

- (void)reset {
    [super reset];
    [self stopTasks];
}

- (void)finalFailed:(NSError *)error {
    [super finalFailed:error];
    NSLog(@"Request %@ failed, %@.", _item.title, error);
    [self stopTasks];
    [_item failed];
}

- (void)onTaskComplete:(GSTask *)task {
    [self overPage];
}

- (void)onTaskFailed:(GSTask *)task error:(NSError *)error {
    [self failed:error];
}

- (void)onTaskCancel:(GSTask *)task {
    [self overPage];
}

- (void)overPage {
    _taskCount--;
    if (_taskCount <= 0) {
        [self stopTasks];
        [self complete];
    }
}

- (void)stopTasks {
    [_item.pages enumerateObjectsUsingBlock:^(GSPageItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.status != GSPageItemStatusComplete) {
            GSTask *task = [_downloadQueue task:PageDownloadIdentifier(obj)];
            if (task) {
                [task cancel];
            }
        }
    }];
    _taskCount = 0;
}

@end
