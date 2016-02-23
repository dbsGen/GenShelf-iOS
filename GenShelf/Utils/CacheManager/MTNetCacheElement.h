//
//  MTNetCacheElement.h
//  NetWorkTest
//
//  Created by zrz on 12-3-2.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTNetCacheElement;

typedef void (^MTCacheElementSuccessBlock)(MTNetCacheElement* element);
typedef void (^MTCacheElementFaildBlock)(MTNetCacheElement* element);

@interface MTNetCacheElement : NSObject 
<NSCoding>{
    NSDate      *_date;
    NSString    *_urlString,
                *_path;
    UIImage     *_image;
    NSData      *_data;
    size_t      _size;
    BOOL        _doing;
}

@property (retain)   NSDate      *date;
@property (retain)   NSString    *urlString,
                                 *path;
@property (retain)   NSData      *data;
@property (retain)   UIImage     *image;
@property (assign)   size_t      size;
@property (readonly) BOOL        doing;

- (void)saveDataOnQueue:(dispatch_queue_t)queue
                 dirPath:(NSString*)path 
                 success:(MTCacheElementSuccessBlock)successBlock
                   faild:(MTCacheElementFaildBlock)faildBlock;

- (void)loadDataOnQueue:(dispatch_queue_t)queue 
                dirPath:(NSString*)path 
                success:(MTCacheElementSuccessBlock)successBlock
                  faild:(MTCacheElementFaildBlock)faildBlock;

- (void)loadImageOnQueue:(dispatch_queue_t)queue dirPath:(NSString*)path
                 success:(MTCacheElementSuccessBlock)successBlock
                   faild:(MTCacheElementFaildBlock)faildBlock;

- (void)removeDataOnQueue:(dispatch_queue_t)queue 
                  dirPath:(NSString*)path 
                  success:(MTCacheElementSuccessBlock)successBlock
                    faild:(MTCacheElementFaildBlock)faildBlock;

@end
