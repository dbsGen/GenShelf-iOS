//
//  GSDataController.m
//  GenShelf
//
//  Created by Gen on 16/2/20.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSDataControl.h"
#import "GSGlobals.h"
#import "GDataXMLNode.h"

@implementation GSDataControl

@synthesize name = _name;

- (ASIHTTPRequest *)mainRequest {
    ASIHTTPRequest *request = [GSGlobals requestForURL:[[self class] mainUrl]];
    return request;
}

- (ASIHTTPRequest *)searchRequest:(NSString *)keyword {
    ASIHTTPRequest *request = [GSGlobals requestForURL:[[self class] searchUrl:keyword]];
    return request;
}

+ (NSURL *)mainUrl {
    return NULL;
}

+ (NSURL *)searchUrl:(NSString *)keyword {
    return NULL;
}

- (NSArray<GSBookItem *> *)parseMain:(NSString *)html {
    NSError *error = nil;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithHTMLString:html
                                                                   error:&error];
    if (error) {
        NSLog(@"Parse html error : %@", error);
        return [NSArray array];
    }
    [doc.rootElement nodesForXPath:<#(NSString *)#> error:<#(NSError *__autoreleasing *)#>]
    return [NSArray array];
}

@end
