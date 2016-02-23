//
//  MTNetCacheManager.m
//  NetWorkTest
//
//  Created by zrz on 12-3-2.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "MTNetCacheManager.h"
#import "MTMenoryCache.h"
#import "MTLocationCache.h"
#import "MTMd5.h"

#define kDateFormat     @"yyyyMMddHHmmssSSS"
#define kTempFileDir    @"temp"
#define kTempExtend     @"tmp"
#define kConfigFile     @"info.conf"

#define kAutoClear      @"MTNetCacheAutoClean"
#define kAutoClearTime  @"MTNetCacheAutoCleanTime"

@implementation MTNetCacheManager

static id __defaultManager;

@synthesize autoClean = _autoClean, autoCleanTime = _autoCleanTime;
@synthesize cachePath = _tempPath;

+ (MTNetCacheManager*)defaultManager
{
    @synchronized(self) {
        if (!__defaultManager) {
            __defaultManager = [[self alloc] init];
        }
    }
    return __defaultManager;
}

- (NSString*)cachePath
{
    if (!_tempPath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *path = [paths lastObject];
        _tempPath = [[path stringByAppendingPathComponent:kTempFileDir] copy];
    }
    return _tempPath;
}

static int __count = 0;

- (id)initWithPath:(NSString*)cachePath
{
    self = [super init];
    if (self) {
        _tempPath = [cachePath retain];
        NSString *tempPath = [self cachePath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:tempPath]) {
            NSError *error = nil;
            [fileManager createDirectoryAtPath:tempPath
                   withIntermediateDirectories:YES 
                                    attributes:nil
                                         error:&error];
            if (error) {
                NSLog(@"net cacher 初始化失败!创建缓存目录失败! \nerror : %@", error);
                return nil;
            }
        }
        _memoryCache = [[MTMenoryCache alloc] init];     
        _locationCache = [[MTLocationCache alloc] initWithPath:tempPath];
        _cacheQueue = dispatch_queue_create([[NSString stringWithFormat:@"cacheManager_%d", __count] UTF8String], nil);
        _locationCache.cacheQueue = _cacheQueue;
        
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:
                             [[self cachePath] stringByAppendingPathComponent:kConfigFile]];
        BOOL isAutoClean = [[dic objectForKey:kAutoClear] boolValue];
        _autoClean = isAutoClean;
        if (isAutoClean) {
            _autoCleanTime = [[dic objectForKey:kAutoClearTime] doubleValue];
            NSDate *date = [[NSDate date] dateByAddingTimeInterval:- _autoCleanTime];
            [self removeLocationCacheBefore:date];
        }else {
            _autoCleanTime = 0;
        }
    }
    return self;
}

- (id)init
{
    return [self initWithPath:nil];
}

- (void)dealloc
{
    dispatch_release(_cacheQueue);
    [_memoryCache   release];
    [_locationCache release];
    [super          dealloc];
}

- (UInt64)maxSize
{
    return _memoryCache.maxSize;
}

- (void)setMaxSize:(UInt64)_maxSize
{
    _memoryCache.maxSize = _maxSize;
}

- (void)setImage:(UIImage*)image withUrl:(NSString*)url
{
    MTNetCacheElement *obj = [_locationCache fileForUrl:url];
    if (!obj) {
        obj = [[[MTNetCacheElement alloc] init] autorelease];
        obj.image = image;
        obj.date = [NSDate date];
        obj.urlString = url;
        [obj saveDataOnQueue:_cacheQueue
                     dirPath:[self cachePath]
                     success:^(MTNetCacheElement *obj) {
                         [_locationCache addFile:obj];
                         [_memoryCache addFile:obj];
                     } faild:^(MTNetCacheElement *obj) {
                         NSLog(@"%@", @"save faild");
                     }];
    }
}

- (void)setData:(NSData *)data withUrl:(NSString *)url
{
    MTNetCacheElement *obj = [_locationCache fileForUrl:url];
    if (!obj) {
        obj = [[[MTNetCacheElement alloc] init] autorelease];
        obj.data = data;
        obj.date = [NSDate date];
        obj.urlString = url;
        [obj saveDataOnQueue:_cacheQueue
                     dirPath:[self cachePath]
                     success:^(MTNetCacheElement *obj) {
                         [_locationCache addFile:obj];
                         [_memoryCache addFile:obj];
                     } faild:^(MTNetCacheElement *obj) {
                         NSLog(@"%@", @"save faild");
                     }];
    }
}

- (void)getImageWithUrl:(NSString*)url
                      block:(MTNetCacheBlock)block
{
    MTNetCacheElement *obj = [_memoryCache fileForUrl:url];
    if (obj.image)
        block(obj.image);
    else if (obj){
        [obj loadImageOnQueue:_cacheQueue
                      dirPath:[self cachePath]
                      success:^(MTNetCacheElement *obj) {
                          block(obj.image);
                      }
                        faild:^(MTNetCacheElement *obj) {
                            block(nil);
                        }];
    } else {
        obj = [_locationCache fileForUrl:url];
        if (obj) {
            [obj loadImageOnQueue:_cacheQueue
                          dirPath:[self cachePath]
                          success:^(MTNetCacheElement *obj) {
                              block(obj.image);
                              [_memoryCache addFile:obj];
                          }
                            faild:^(MTNetCacheElement *obj) {
                                [_locationCache deleteFileForUrl:obj.urlString];
                                block(nil);
                            }];
        }else {
            block(nil);
        }
    }
}

- (void)getDataWithUrl:(NSString *)url block:(MTNetCacheBlock)block
{
    MTNetCacheElement *obj = [_memoryCache fileForUrl:url];
    if (obj.data)
        block(obj.data);
    else if (obj) {
        [obj loadDataOnQueue:_cacheQueue
                     dirPath:[self cachePath]
                     success:^(MTNetCacheElement *obj) {
                         block(obj.data);
                     }
                       faild:^(MTNetCacheElement *obj) {
                           block(nil);
                       }];
    } else {
        obj = [_locationCache fileForUrl:url];
        if (obj) {
            [obj loadDataOnQueue:_cacheQueue
                          dirPath:[self cachePath]
                          success:^(MTNetCacheElement *obj) {
                              block(obj.data);
                              [_memoryCache addFile:obj];
                          }
                            faild:^(MTNetCacheElement *obj) {
                                [_locationCache deleteFileForUrl:obj.urlString];
                                block(nil);
                            }];
        }else {
            block(nil);
        }
    }
}

- (void)saveLocationCacheInfo
{
    [_locationCache save];
}

- (void)cleanLocationCache
{
    [_locationCache cleanDirectoryWithOut:kConfigFile];
}

- (void)removeLocationCacheBefore:(NSDate*)date
{
    [_locationCache deleteBeforeDate:date];
}

- (void)cleanMemoryCache
{
    [_memoryCache deleteAll];
}

- (void)setAutoClean:(BOOL)autoClean
{
    if (_autoClean == autoClean)
        return;
    _autoClean = autoClean;
    NSString *path = [[self cachePath] stringByAppendingPathComponent:kConfigFile];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    if (!dic) {
        dic = [NSMutableDictionary dictionary];
    }
    [dic setObject:[NSNumber numberWithBool:autoClean]
            forKey:kAutoClear];
    if (autoClean && ![dic objectForKey:kAutoClearTime]) {
        [dic setObject:[NSNumber numberWithDouble:timeUpper(30)]
                forKey:kAutoClearTime];
    }
    [dic writeToFile:path atomically:YES];
}

- (void)setAutoCleanTime:(NSTimeInterval)autoCleanTime
{
    if (_autoCleanTime == autoCleanTime) return;
    _autoCleanTime = autoCleanTime;
    NSString *path = [[self cachePath] stringByAppendingPathComponent:kConfigFile];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    if (!dic) {
        dic = [NSMutableDictionary dictionary];
    }
    [dic setObject:[NSNumber numberWithDouble:autoCleanTime]
            forKey:kAutoClearTime];
    [dic writeToFile:path atomically:YES];
}

- (UInt64)memUsed
{
    return _memoryCache.size;
}

- (UInt64)locationUsed
{
    return _locationCache.size;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ memory used : %llum%llukB , disk used : %llum%llukB", 
            [super description], self.memUsed / (1024*1024), (self.memUsed / 1024) % 1024,
            self.locationUsed / (1024*1024), (self.locationUsed / 1024) % 1024];
}

@end
