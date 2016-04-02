//
//  GSLofiDownloadTask.m
//  GenShelf
//
//  Created by Gen on 16/2/28.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSEHentaiDownloadTask.h"
#import "GSGlobals.h"
#import "GDataXMLNode.h"
#import "GSDataDefines.h"
#import "GSPictureManager.h"

@interface GSEHentaiPageTask : GSTask <ASIHTTPRequestDelegate> {
    GSModelNetPage *_item;
    NSOperationQueue *_queue;
}

@property (nonatomic, strong) GSModelNetBook *bookItem;
@property (nonatomic, strong) ASIHTTPRequest *request;

- (id)initWithItem:(GSModelNetPage *)item queue:(NSOperationQueue *)queue;

@end

@implementation GSEHentaiPageTask

- (id)initWithItem:(GSModelNetPage *)item queue:(NSOperationQueue *)queue {
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
    NSURL *url = [NSURL URLWithString:_item.pageUrl];
    _request = [GSGlobals requestForURL:url];
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
            GDataXMLElement *node = (GDataXMLElement*)[doc firstNodeForXPath:@"//div[@id='i3']/a/img[@id='img']"
                                                                       error:&error];
            CheckError
            if (!node) {
                node = (GDataXMLElement*)[doc firstNodeForXPath:@"//img[@style]"
                                                          error:&error];
            }
            if (node) {
                NSString *src = [node attributeForName:@"src"].stringValue;
                
                _item.imageUrl = src;
                [_item requestImage];
                _request = [GSGlobals requestForURL:[NSURL URLWithString:src]];
                _request.delegate = self;
                _request.tag = 2;
                [_queue addOperation:_request];
            }else {
                [self failed:[NSError errorWithDomain:@"No item found"
                                                 code:133
                                             userInfo:nil]];
            }
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

@implementation GSEHentaiDownloadTask

- (id)initWithItem:(GSModelNetBook *)item queue:(NSOperationQueue *)queue {
    self = [super init];
    if (self) {
        _item = item;
        _queue = queue;
        self.timeDelay = 1;
    }
    return self;
}

- (void)run {
    if (_item.bookStatus == GSBookStatusComplete) {
        [_item startLoading];
        _taskCount = 0;
        [_item.pages enumerateObjectsUsingBlock:^(GSModelNetPage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.pageStatus != GSPageStatusComplete) {
                [_downloadQueue createTask:PageDownloadIdentifier(obj)
                                   creator:^GSTask *{
                                       GSEHentaiPageTask *task = [[GSEHentaiPageTask alloc] initWithItem:obj
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
    [_item.pages enumerateObjectsUsingBlock:^(GSModelNetPage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.pageStatus != GSPageStatusComplete) {
            GSTask *task = [_downloadQueue task:PageDownloadIdentifier(obj)];
            if (task) {
                [task cancel];
            }
        }
    }];
    _taskCount = 0;
}

@end
