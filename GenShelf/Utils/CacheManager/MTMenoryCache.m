//
//  MTMenoryCache.m
//  NetWorkTest
//
//  Created by zrz on 12-3-2.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "MTMenoryCache.h"

NS_INLINE UInt64 sizeOfImage(UIImage *image)
{
    CGImageRef cgImage = image.CGImage;
    return CGImageGetBytesPerRow(cgImage) * CGImageGetHeight(cgImage);
}

@implementation MTMenoryCache

@synthesize maxSize = _maxSize;

- (id)init
{
    self = [super init];
    if (self) {
        _datas = [[NSMutableDictionary alloc] init];
        _index = [[NSMutableArray alloc] init];
        _maxSize = 8000000;
        _size = 0;
    }
    return self;
}

- (void)dealloc
{
    [_datas     release];
    [_index     release];
    [super      dealloc];
}

- (MTNetCacheElement*)fileForUrl:(NSString *)url
{
    MTNetCacheElement *obj = [_datas objectForKey:url];
    if (obj) {
        [_index removeObject:obj.urlString];
        [_index addObject:obj.urlString];
    }
    return obj;
}

- (void)addFile:(MTNetCacheElement *)file
{
    NSString *urlString = file.urlString;
    MTNetCacheElement *obj = [_datas objectForKey:urlString];
    if (obj) {
        _size -= obj.data.length;
    }else {
        //保存索引
        [_index addObject:file.urlString];
    }
    _size += file.data.length;
    [_datas setObject:file forKey:urlString];
    
    //检查是否超出缓存大小
    while (_size > _maxSize) {
        if ([_index count] > 1) {
            NSString *url = [_index objectAtIndex:0];
            [self deleteFileForUrl:url];
        }else {
            NSLog(@"it is a empty array ,yet!");
            return;
        }
    }
}

- (void)deleteFileForUrl:(NSString*)url
{
    MTNetCacheElement *obj = [_datas objectForKey:url];
    _size -= obj.data.length;
    obj.data = nil;
    [_index removeObject:obj.urlString];
    [_datas removeObjectForKey:url];
}


- (void)deleteAll
{
    [_datas enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        MTNetCacheElement *tObj = obj;
        tObj.data = nil;
    }];
    [_datas removeAllObjects];
    [_index removeAllObjects];
    _size = 0;
}

- (UInt64)size
{
    return _size;
}

@end
