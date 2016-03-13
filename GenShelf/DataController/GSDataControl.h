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
#import "GSTask.h"

typedef ASIHTTPRequest *(^GSRequestBlock)(NSURL *url);
typedef void *(^GSRequestUpdateBlock)(NSUInteger count);

@interface GSDataControl : NSObject {
    @protected
    NSString *_name;
    CGFloat _requestDelay;
    NSMutableArray *_progressingBooks;
}

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSOperationQueue *operationQueue;
@property (nonatomic, readonly) GSTaskQueue *taskQueue;
@property (nonatomic, readonly) NSArray *progressingBooks;
@property (nonatomic, assign) CGFloat   requestDelay;

- (ASIHTTPRequest *)mainRequest;
- (ASIHTTPRequest *)searchRequest:(NSString *)keyword;

// Need override
+ (NSURL *)mainUrl;
+ (NSURL *)searchUrl:(NSString*)keyword;

- (NSArray<GSBookItem *> *)parseMain:(NSString *)html;
- (GSTask *)processBook:(GSBookItem *)book;
- (GSTask *)downloadBook:(GSBookItem *)book;
- (void)pauseBook:(GSBookItem *)book;
- (NSInteger)deleteBook:(GSBookItem *)book;

@end
