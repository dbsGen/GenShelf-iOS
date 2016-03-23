//
//  GSLofiHomeTask.m
//  GenShelf
//
//  Created by Gen on 16/3/14.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSEHentaiHomeTask.h"
#import "GSEHentaiDefines.h"
#import "GSGlobals.h"
#import "GDataXMLNode.h"
#import "GSDataDefines.h"

@interface GSEHentaiHomeTask () <ASIHTTPRequestDelegate>

@end

@implementation GSEHentaiHomeTask {
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
    _request = [GSGlobals requestForURL:[NSURL URLWithString:[[URL_HOST stringByAppendingString:EHentaiFilterString(NO)] stringByAppendingString:[NSString stringWithFormat:@"&page=%d", (int)_index]]]];
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
    if (_request) {
        _request.delegate = nil;
        [_request cancel];
        _request = nil;
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    if (_request == request) {
        NSError *error = nil;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithHTMLString:request.responseString
                                                                       error:&error];
        CheckError
        NSArray *divs = [doc nodesForXPath:@"//tr[@class='gtr0']|//tr[@class='gtr1']" error:&error];
        CheckError
        
        NSMutableArray<GSBookItem *> *res = [NSMutableArray<GSBookItem*> array];
        for (GDataXMLNode *node in divs) {
            GDataXMLElement *hrefNode = (GDataXMLElement*)[node firstNodeForXPath:@"td[@class='itd']//div[@class='it5']/a"
                                                                            error:&error];
            CheckErrorC
            NSString *pageUrl = [hrefNode attributeForName:@"href"].stringValue;
            GSBookItem *item = [GSBookItem itemWithUrl:pageUrl];
            item.title = hrefNode.stringValue;
            
            GDataXMLElement *imageNode = (GDataXMLElement*)[node firstNodeForXPath:@"td[@class='itd']//div[@class='it2']"
                                                                             error:&error];
            CheckErrorC
            NSString *imageString = imageNode.stringValue;
            if ([imageString hasPrefix:@"init~"]) {
                NSArray *arr = [imageString componentsSeparatedByString:@"~"];
                if (arr.count >= 3) {
                    item.imageUrl = [NSString stringWithFormat:@"http://%@/%@", [arr objectAtIndex:1], [arr objectAtIndex:2]];
                    [res addObject:item];
                    continue;
                }
            }else {
                GDataXMLElement *imgNode = (GDataXMLElement*)[imageNode firstNodeForXPath:@"img"
                                                                                    error:&error];
                CheckErrorC
                if (imgNode) {
                    item.imageUrl = [imgNode attributeForName:@"src"].stringValue;
                    [res addObject:item];
                    continue;
                }
            }
            NSLog(@"Can not get image with %@ white %@", item.title, [imageNode XMLString]);
        }
        GDataXMLElement *last = (GDataXMLElement*)[doc firstNodeForXPath:@"//table[@class='ptb']/tbody/tr/td[last()]"
                                                                   error:&error];
        CheckError
        GDataXMLNode *attNode = [last attributeForName:@"class"];
        if (res.count) {
            _hasMore = !(attNode && [[(GDataXMLElement *)attNode stringValue] isEqualToString:@"ptdd"]);
        }else _hasMore = NO;
        
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
