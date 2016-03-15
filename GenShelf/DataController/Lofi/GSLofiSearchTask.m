//
//  GSSearchTask.m
//  GenShelf
//
//  Created by Gen on 16/3/15.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSLofiSearchTask.h"
#import "GSGlobals.h"
#import "GSLofiDefines.h"
#import "GDataXMLNode.h"
#import "GSDataDefines.h"

@interface GSLofiSearchTask () <ASIHTTPRequestDelegate>

@end

@implementation GSLofiSearchTask {
    ASIHTTPRequest *_request;
}

@synthesize searchKey = _searchKey;

- (id)initWithKey:(NSString *)key index:(NSUInteger)index queue:(NSOperationQueue *)queue {
    self = [super init];
    if (self) {
        _searchKey = key;
        _index = index;
        _queue = queue;
    }
    return self;
}

- (void)cancel {
    [super cancel];
    if (_request) {
        [_request cancel];
        _request = nil;
    }
}

- (void)run {
    NSString *str = [URL_HOST stringByAppendingString:filterString(YES)];
    str = [NSString stringWithFormat:@"%@&page=%d&f_search=%@", str, (int)_index, [_searchKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    _request = [GSGlobals requestForURL:[NSURL URLWithString:str]];
    _request.delegate = self;
    [_queue addOperation:_request];
}

#pragma mark - request

- (void)requestFinished:(ASIHTTPRequest *)request {
    if (_request == request) {
        
        
        NSError *error = nil;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithHTMLString:request.responseString
                                                                       error:&error];
        CheckError
        NSArray *divs = [doc nodesForXPath:@"//div[@class='ig']" error:&error];
        CheckError
        
        NSMutableArray<GSBookItem *> *res = [NSMutableArray<GSBookItem*> array];
        for (GDataXMLNode *node in divs) {
            GDataXMLElement *imageNode = (GDataXMLElement*)[node firstNodeForXPath:@"node()//td[@class='ii']/a"
                                                                             error:&error];
            CheckErrorC
            NSString *pageUrl = [imageNode attributeForName:@"href"].stringValue;
            GSBookItem *item = [GSBookItem itemWithUrl:pageUrl];
            
            GDataXMLElement *sImageNode = (GDataXMLElement*)[imageNode firstNodeForXPath:@"img"
                                                                                   error:&error];
            CheckErrorC
            item.imageUrl = [sImageNode attributeForName:@"src"].stringValue;
            
            GDataXMLElement *titleNode = (GDataXMLElement*)[node firstNodeForXPath:@"node()//table[@class='it']//a[@class='b']"
                                                                             error:&error];
            CheckErrorC
            item.title = titleNode.stringValue;
            [res addObject:item];
        }
        NSArray *links = [doc nodesForXPath:@"//div[@id='ia']/a"
                                      error:&error];
        CheckError
        _hasMore = NO;
        for (GDataXMLElement *lNode in links) {
            NSString *str = [lNode.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([str hasPrefix:@"Next"] || [str hasPrefix:@"next"]) {
                _hasMore = YES;
                break;
            }
        }
        
        _books = res;
        _request = nil;
        [self complete];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    if (_request == request) {
        _request = nil;
        [self failed:request.error];
    }
}

@end
