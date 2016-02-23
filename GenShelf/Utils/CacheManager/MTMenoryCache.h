//
//  MTMenoryCache.h
//  NetWorkTest
//
//  Created by zrz on 12-3-2.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTNetCacheElement.h"

@interface MTMenoryCache : NSObject
{
    NSMutableDictionary *_datas;
    NSMutableArray      *_index;
    UInt64              _maxSize,
                        _size;
}

//the max size in the memory ,default is 8000000(1MB).
@property (nonatomic, assign)   UInt64  maxSize;

- (UInt64)size;

- (MTNetCacheElement*)fileForUrl:(NSString*)url;

- (void)addFile:(MTNetCacheElement*)file;

- (void)deleteFileForUrl:(NSString*)url;

- (void)deleteAll;

@end
