//
//  GSLofiHomeTask.m
//  GenShelf
//
//  Created by Gen on 16/3/14.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSLofiHomeTask.h"
#import "GSLofiDefines.h"
#import "GSGlobals.h"
#import "GDataXMLNode.h"
#import "GSDataDefines.h"

@interface GSLofiHomeTask () <ASIHTTPRequestDelegate>

@end

@implementation GSLofiHomeTask {
    ASIHTTPRequest *_request;
}

- (id)initWithIndex:(NSUInteger)index
              queue:(NSOperationQueue *)queue {
    self = [super init];
    if (self) {
        _queue = queue;
        _index = index;
    }
    return self;
}

- (void)run {
    _request = [GSGlobals requestForURL:[NSURL URLWithString:[[URL_HOST stringByAppendingString:FILTER_STR] stringByAppendingString:[NSString stringWithFormat:@"&page=%d", (int)_index]]]];
    _request.delegate = self;
    [_queue addOperation:_request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    
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

- (void)requestFailed:(ASIHTTPRequest *)request {
    if (_request == request) {
        _request = nil;
        [self failed:request.error];
    }
}

@end
