//
//  GSDataController.h
//  GenShelf
//
//  Created by Gen on 16/2/20.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "GSBookItem.h"
#import "GSPageItem.h"

typedef ASIHTTPRequest *(^GSRequestBlock)(NSURL *url);
typedef void *(^GSRequestUpdateBlock)(NSUInteger count);

@interface GSDataControl : NSObject {
    @protected
    NSString *_name;
}

@property (nonatomic, readonly) NSString *name;

- (ASIHTTPRequest *)mainRequest;
- (ASIHTTPRequest *)searchRequest:(NSString *)keyword;

// Need override
+ (NSURL *)mainUrl;
+ (NSURL *)searchUrl:(NSString*)keyword;

- (NSArray<GSBookItem *> *)parseMain:(NSString *)html;
- (void)processBook:(GSBookItem *)book;

@end
