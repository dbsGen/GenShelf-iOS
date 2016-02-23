//
//  MTLocationCache.h
//  NetWorkTest
//
//  Created by zrz on 12-3-2.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTNetCacheElement.h"

@interface MTLocationCache : NSObject {
    NSMutableDictionary *_datas;
    NSString            *_filePath,
                        *_tempPath;
    NSCondition         *_lock;
    BOOL                _saveKey;
    dispatch_queue_t    _cacheQueue;
}

@property (assign)   dispatch_queue_t    cacheQueue;

- (id)initWithPath:(NSString*)path;

- (void)setDirPath:(NSString *)path;

- (void)doPerFile:(void (^)(id key, id obj, BOOL *stop))block;

- (MTNetCacheElement*)fileForUrl:(NSString*)url;
- (MTNetCacheElement*)fileForName:(NSString*)name;
- (void)cleanDirectoryWithOut:(NSString*)fileName;

- (void)addFile:(MTNetCacheElement *)file;
- (void)addFile:(MTNetCacheElement *)file withData:(NSData*)data;
- (void)deleteFileForUrl:(NSString*)url;
- (void)save;
- (void)deleteAll;
- (void)deleteBeforeDate:(NSDate*)date;
- (UInt64)size;

@end
