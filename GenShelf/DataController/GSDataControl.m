//
//  GSDataController.m
//  GenShelf
//
//  Created by Gen on 16/2/20.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSDataControl.h"
#import "GSGlobals.h"

@implementation GSDataControl

@synthesize name = _name, requestDelay = _requestDelay;

- (id)init {
    self = [super init];
    if (self) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

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
    return [NSArray array];
}
- (void)processBook:(GSBookItem *)book {}

@end
