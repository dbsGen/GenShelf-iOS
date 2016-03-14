//
//  GSLofiBookTask.m
//  GenShelf
//
//  Created by Gen on 16/2/26.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSLofiBookTask.h"
#import "GSGlobals.h"
#import "GDataXMLNode.h"
#include "../GSDataDefines.h"

@class GSLofiBookSubtask;

@interface GSLofiBookTask (GSLofiBookSubtask)

- (void)bookSubtask:(GSLofiBookSubtask *)subtask complete:(NSString *)response;

@end

@interface GSLofiBookSubtask : GSTask  <ASIHTTPRequestDelegate>

@property (nonatomic, assign) ASIHTTPRequest *request;
@property (nonatomic, weak) id parentDelegate;

- (id)initWithUrl:(NSURL*)url queue:(NSOperationQueue *)queue;

@end

@implementation GSLofiBookSubtask {
    NSURL *_url;
    NSOperationQueue *_queue;
}

- (id)initWithUrl:(NSURL *)url queue:(NSOperationQueue *)queue {
    self = [super init];
    if (self) {
        _url = url;
        _queue = queue;
        self.timeDelay = 1;
    }
    return self;
}

- (void)run {
    _request = [GSGlobals requestForURL:_url];
    _request.delegate = self;
    [_queue addOperation:_request];
}

- (void)reset {
    [super reset];
    [_request cancel];
    _request.delegate = nil;
    _request = nil;
}

- (void)cancel {
    [super cancel];
    _request.delegate = nil;
    [_request cancel];
    _request = nil;
}


- (void)requestFinished:(ASIHTTPRequest *)request {
    if (_request == request) {
        _request.delegate = nil;
        _request = nil;
        if ([self.parentDelegate respondsToSelector:@selector(bookSubtask:complete:)]) {
            [self.parentDelegate performSelector:@selector(bookSubtask:complete:)
                                      withObject:self
                                      withObject:request.responseString];
        }
        [self complete];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    if (_request == request) {
        _request.delegate = nil;
        _request = nil;
        [self failed:request.error];
    }
}

- (void)dealloc {
    if (_request) {
        _request.delegate = nil;
    }
}

@end

@interface GSLofiBookTask ()

@end

@implementation GSLofiBookTask

- (id)initWithItem:(GSBookItem *)item queue:(NSOperationQueue *)queue {
    self = [super init];
    if (self) {
        _item = item;
        _queue = queue;
    }
    return self;
}

- (void)run {
    if (_item.status >= GSBookItemStatusComplete) {
        [self complete];
    }else if (_item.loading) {
        [self fatalError:[NSError errorWithDomain:[NSString stringWithFormat:@"Bookitem %@ already in progressing or complete.", _item.title]
                                             code:101
                                         userInfo:nil]];
    }else {
        NSURL *url = [NSURL URLWithString:_item.otherData ? _item.otherData : _item.pageUrl];
        
        if (!_item.otherData && _item.pages.count > 0) {
            [_item reset];
        }
        GSLofiBookSubtask *subtask = [[GSLofiBookSubtask alloc] initWithUrl:url
                                                                      queue:_queue];
        subtask.parentDelegate = self;
        [self addSubtask:subtask];
        [self complete];
    }
}

- (void)bookSubtask:(GSLofiBookSubtask *)subtask complete:(NSString *)response {
    NSString *html = response;
    NSError *error = nil;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithHTMLString:html
                                                                   error:&error];
    CheckError
    NSArray *pNodes = [doc nodesForXPath:@"//div[@id='gh']/div[@class='gi']"
                                   error:&error];
    CheckError
    NSMutableArray<GSPageItem *> *pages = [NSMutableArray<GSPageItem *> array];
    for (GDataXMLNode *pNode in pNodes) {
        GDataXMLElement *a = (GDataXMLElement*)[pNode firstNodeForXPath:@"a"
                                                                  error:&error];
        CheckErrorC
        GSPageItem *page = [GSPageItem itemWithUrl:[a attributeForName:@"href"].stringValue];
        GDataXMLElement *img = (GDataXMLElement*)[a firstNodeForXPath:@"img"
                                                                error:&error];
        CheckErrorC
        page.thumUrl = [img attributeForName:@"src"].stringValue;
        [pages addObject:page];
    }
    
    NSArray *links = [doc nodesForXPath:@"//div[@id='ia']/a"
                                  error:&error];
    CheckError
    for (GDataXMLElement *lNode in links) {
        NSString *str = [lNode.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([str hasPrefix:@"Next"] || [str hasPrefix:@"next"]) {
            NSString *href = [lNode attributeForName:@"href"].stringValue;
            _item.otherData = href;
            [_item loadPages:pages];
            GSLofiBookSubtask *subtask = [[GSLofiBookSubtask alloc] initWithUrl:[NSURL URLWithString:href]
                                                                          queue:_queue];
            subtask.parentDelegate = self;
            [self addSubtask:subtask];
            return;
        }
    }
    
    _item.otherData = nil;
    [_item loadPages:pages];
    [_item complete];
}

- (void)finalFailed:(NSError *)error {
    NSLog(@"Request %@ failed, %@.", _item.title, error);
    [_item failed];
}

- (void)cancel {
    [super cancel];
    [_item cancel];
}

- (void)reset {
    [super reset];
    [_item reset];
}

@end
