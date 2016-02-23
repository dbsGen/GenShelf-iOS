//
//  MTNetCacheElement.m
//  NetWorkTest
//
//  Created by zrz on 12-3-2.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "MTNetCacheElement.h"
#import "MTMd5.h"

#define kDate       @"date"
#define kUrlString  @"urlString"
#define kPath       @"path"
#define kSize       @"size"

@implementation MTNetCacheElement

@synthesize date = _date, urlString = _urlString, data = _data, path = _path;
@synthesize size = _size, doing = _doing, image = _image;

- (void)dealloc
{
    [_image         release];
    [_date          release];
    [_urlString     release];
    [_data          release];
    [_path          release];
    [super          dealloc];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_date      forKey:kDate];
    [aCoder encodeObject:_urlString forKey:kUrlString];
    [aCoder encodeObject:_path      forKey:kPath];
    [aCoder encodeInt64:_size       forKey:kSize];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (self) {
        self.date = [aDecoder decodeObjectForKey:kDate];
        self.urlString = [aDecoder decodeObjectForKey:kUrlString];
        self.path = [aDecoder decodeObjectForKey:kPath];
        self.size = [aDecoder decodeInt64ForKey:kSize];
    }
    return self;
}

- (void)saveDataOnQueue:(dispatch_queue_t)queue dirPath:(NSString*)path
                 success:(MTCacheElementSuccessBlock)successBlock
                   faild:(MTCacheElementFaildBlock)faildBlock
{
    if ((!_data && !_image) || !path) {
        NSLog(@"no data to save!");
        faildBlock(self);
        return;
    }
    
    dispatch_block_t db = ^(void){
        while (_doing) {
            sleep(0.5);
        }
        _doing = YES;
        
        NSData *data;
        if (_data) {
            data = _data;
        }else data = UIImagePNGRepresentation(_image);
        NSString *name = MD5String([self.urlString dataUsingEncoding:NSUTF8StringEncoding]);
        self.path = name;
        
        BOOL success = [data writeToFile:[path stringByAppendingPathComponent:name]
               atomically:YES];
        
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            _doing = NO;
            if (success) {
                successBlock(self);
            }else faildBlock(self);
        });
    };
    dispatch_async(queue, db);
}

- (void)loadDataOnQueue:(dispatch_queue_t)queue dirPath:(NSString*)path 
                success:(MTCacheElementSuccessBlock)successBlock 
                  faild:(MTCacheElementFaildBlock)faildBlock
{
    if (!path || !_path) {
        NSLog(@"I must have a directory to load the data");
        faildBlock(self);
        return;
    }
    
    dispatch_block_t db = ^(void) {
        while (_doing) {
            sleep(0.5);
        }
        _doing = YES;
        
        NSData *data = nil;
        
        if (self.image) {
            data = UIImagePNGRepresentation(self.image);
        }else data = [NSData dataWithContentsOfFile:[path stringByAppendingPathComponent:_path]];
        
        BOOL success = data != nil;
        if (data) {
            self.data = data;
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            _doing = NO;
            if (success) {
                successBlock(self);
            }else faildBlock(self);
        });
    };
    
    dispatch_async(queue, db);
}

- (void)loadImageOnQueue:(dispatch_queue_t)queue dirPath:(NSString*)path
                 success:(MTCacheElementSuccessBlock)successBlock
                   faild:(MTCacheElementFaildBlock)faildBlock
{
    if (!path || !_path) {
        NSLog(@"I must have a directory to load the data");
        faildBlock(self);
        return;
    }
    
    dispatch_block_t db = ^(void) {
        while (_doing) {
            sleep(0.5);
        }
        _doing = YES;
        
        NSData *data = nil;
        if (self.data) {
            data = self.data;
        }else data = [NSData dataWithContentsOfFile:[path stringByAppendingPathComponent:_path]];
        
        BOOL success = data != nil;
        if (data) {
            self.image = [UIImage imageWithData:data];
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            _doing = NO;
            if (success) {
                successBlock(self);
            }else faildBlock(self);
        });
    };
    
    dispatch_async(queue, db);
}

- (void)removeDataOnQueue:(dispatch_queue_t)queue dirPath:(NSString *)path 
                  success:(MTCacheElementSuccessBlock)successBlock 
                    faild:(MTCacheElementFaildBlock)faildBlock
{
    if (!path || !_path) {
        NSLog(@"I must have a directory to remove the data");
        faildBlock(self);
        return;
    }
    
    dispatch_block_t db = ^(void){
        while (_doing) {
            sleep(0.5);
        }
        _doing = YES;
        
        NSString *fullPath = [path stringByAppendingPathComponent:self.path];
        BOOL success;
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:fullPath]) {
            NSError *error = nil;
            success = [fileManager removeItemAtPath:fullPath 
                                              error:&error];
            if (error) {
                NSLog(@"%@", error);
            }
        }else {
            success = YES;
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            _doing = NO;
            if (success) {
                successBlock(self);
            }else faildBlock(self);
        });
    };
    
    dispatch_async(queue, db);
}

@end
