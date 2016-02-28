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
            _request = [GSGlobals requestForURL:[NSURL URLWithString:src]];
            _request.delegate = self;
            _request.tag = 2;
            [_queue addOperation:_request];
        }else if (request.tag == 1) {
            
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
        for (GSPageItem *page in _item.pages) {
            GSLofiPageTask *task = [[GSLofiPageTask alloc] initWithItem:page
                                                                  queue:_queue];
            task.bookItem = _item;
            [self addSubtask:task];
        }
        [self complete];
    }else {
        [self failed:[NSError errorWithDomain:@"目标未完成"
                                         code:102
                                     userInfo:nil]];
    }
}

@end
