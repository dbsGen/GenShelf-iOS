//
//  MTNetCacheManager.h
//  NetWorkTest
//
//  MTNetCacheManager will init a cache system 
//  now it will do some of works on other thread by GCD.
//
//  Created by zrz on 12-3-2.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import <Foundation/Foundation.h>

#define timeUpper(day) (24 * 3600 * day)

@class MTMenoryCache, MTLocationCache;

typedef void (^MTNetCacheBlock)(id result);

@interface MTNetCacheManager : NSObject
{
    MTMenoryCache   *_memoryCache;
    MTLocationCache *_locationCache;
    NSString        *_tempPath;
    dispatch_queue_t    _cacheQueue; 
}

//内存缓存峰值,默认8000000(1MB)
//max memory size default is 8000000(1MB)
@property (nonatomic, assign)   UInt64  maxSize;    

//是否自动清除缓存信息
//is auto clear the data which is too old.
//the clean will do on the MTNetCacheManager init.
@property (nonatomic, assign)   BOOL    autoClean;  

//自动缓存清除时间 默认30天
//autoCleanTime is to judge if the data is too old?
@property (nonatomic, assign)   NSTimeInterval  autoCleanTime;
//the path
@property (nonatomic, readonly) NSString    *cachePath;


+ (MTNetCacheManager*)defaultManager;

// you can set the other path.
- (id)initWithPath:(NSString*)cachePath;

//use this method to cache the image
- (void)setImage:(UIImage*)image withUrl:(NSString*)url;

//use this method to cache the data
- (void)setData:(NSData*)data withUrl:(NSString*)url;

//this method to load image from disk if its exists.
- (void)getImageWithUrl:(NSString*)url block:(MTNetCacheBlock)block;

- (void)getDataWithUrl:(NSString*)url block:(MTNetCacheBlock)block;


//手动保存磁盘缓存信息,有操作后30秒内会自动缓存一次
//save the info to the disk , you will not must to use this ,
//because it will auto save per 30s(if configed)
- (void)saveLocationCacheInfo;


//清除所有磁盘缓存
//clean all the data in the disk
- (void)cleanLocationCache;


//清除date之前的缓存信息
//clean all the data before the time.
- (void)removeLocationCacheBefore:(NSDate*)date;


//清除内存缓存
//clean all the data in the memory.
- (void)cleanMemoryCache;

//磁盘空间使用
//size in disk used 
- (UInt64)locationUsed;

//内存占用,相同的图片内存使用比磁盘使用要大
//size in memory used 
- (UInt64)memUsed;

@end
