//
//  MTLocationCache.m
//  NetWorkTest
//
//  Created by zrz on 12-3-2.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "MTLocationCache.h"

#define kFileName   @"data.db"
#define kConfigName @"info.conf"


@implementation MTLocationCache

@synthesize cacheQueue = _cacheQueue;

static NSMutableArray   *__cache;

- (id)initWithPath:(NSString *)path
{
    self = [self init];
    if (self) {
        [self setDirPath:path];
    }
    return self;
}

+ (void)threadHandle
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:[NSTimer timerWithTimeInterval:30
                                              target:self
                                            selector:@selector(saveHandle)
                                            userInfo:nil
                                             repeats:YES]
              forMode:NSDefaultRunLoopMode];
    [pool release];
    [runLoop run];
}

+ (void)saveHandle
{
    for (MTLocationCache *cache in __cache) {
        [cache save];
    }
}

- (void)save
{
    if (_filePath && _saveKey) {
        if (_cacheQueue) {
            dispatch_sync(_cacheQueue, ^{
                NSData* artistData = [NSKeyedArchiver archivedDataWithRootObject:_datas];
                [artistData writeToFile:_filePath
                             atomically:YES];
            });
            _saveKey = NO;
        }else {
            NSLog(@"%@", @"there is no queue!"); 
        }
    }
}

- (id)init
{
    if (self = [super init]) {
        if (!__cache) {
            __cache = [[NSMutableArray alloc] init];
            [NSThread detachNewThreadSelector:@selector(threadHandle)
                                     toTarget:[self class]
                                   withObject:nil];
        }
        [__cache addObject:self];
        
        _lock = [[NSCondition alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_filePath  release];
    [_datas     release];
    [super      dealloc];
}

- (void)addFile:(MTNetCacheElement *)file
{
    [_datas setObject:file
               forKey:file.urlString];
    _saveKey = YES;
}

- (void)setDirPath:(NSString *)path
{
    _tempPath = [path copy];
    _filePath = [[path stringByAppendingPathComponent:kFileName] copy];
    _datas = [[NSMutableDictionary alloc] initWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithFile:_filePath]];
    if (!_datas) {
        _datas = [[NSMutableDictionary alloc] init];
    }
    
}

- (void)doPerFile:(void (^)(id, id, BOOL *))block
{
    [_datas enumerateKeysAndObjectsUsingBlock:block];
}

- (void)deleteFileForUrl:(NSString*)url
{
    [_datas removeObjectForKey:url];
}

- (MTNetCacheElement*)fileForName:(NSString *)name
{
    NSEnumerator *enumerator = [_datas objectEnumerator];
    MTNetCacheElement *obj;
    while ((obj = [enumerator nextObject])) {
        if ([obj.path isEqualToString:name]) {
            obj.date = [NSDate date];
            return obj;
        }
    }
    return nil;
}

- (MTNetCacheElement*)fileForUrl:(NSString*)url
{
    MTNetCacheElement *obj = [_datas objectForKey:url];
    obj.date = [NSDate date];
    return obj;
}

- (void)deleteAll
{
    [_datas removeAllObjects];
    _saveKey = YES;
}

- (void)deleteBeforeDate:(NSDate*)date
{
    [_lock lock];
    NSArray *keys = [_datas allKeys];
    for (NSString *key in keys) {
        MTNetCacheElement *element = [_datas objectForKey:key];
        if (element && [element.date compare:date] == NSOrderedAscending) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:[_tempPath stringByAppendingPathComponent:element.path] 
                                    error:nil];
            [_datas removeObjectForKey:key];
        }
    }
    _saveKey = YES;
    [_lock unlock];
}

- (UInt64)size
{
    NSEnumerator *enumerator = [_datas objectEnumerator];
    MTNetCacheElement *obj;
    UInt64 totle = 0;
    while ((obj = [enumerator nextObject])) {
        totle += obj.size;
    }
    return totle;
}

- (void)cleanDirectoryWithOut:(NSString *)fileName
{
    dispatch_block_t block = ^(void){
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *exitPaths = [fileManager subpathsAtPath:_tempPath];
        for (NSString *subPath in exitPaths) {
            if (![subPath isEqualToString:fileName] &&
                ![subPath isEqualToString:kFileName]) {
                [fileManager removeItemAtPath:[_tempPath stringByAppendingPathComponent:subPath]
                                        error:nil];
            }
        }
    };
    
    dispatch_async(_cacheQueue, block);
    [self deleteAll];
}

@end
