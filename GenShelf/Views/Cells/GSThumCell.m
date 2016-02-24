//
//  GSThumCell.m
//  GenShelf
//
//  Created by Gen on 16/2/23.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSThumCell.h"
#import "ASIHTTPRequest.h"
#import "MTNetCacheManager.h"
#import "GSGlobals.h"

@implementation GSThumCell {
    ASIHTTPRequest *_currentRequest;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[GSRadiusImageView alloc] initWithFrame:self.bounds];
        _imageView.image = [UIImage imageNamed:@"no_image"];
        [self addSubview:_imageView];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _imageView.frame = self.bounds;
}

- (void)setImageUrl:(NSString *)imageUrl {
    if (_imageUrl != imageUrl) {
        if (_currentRequest) {
            [_currentRequest cancel];
            _currentRequest = NULL;
        }
        _imageView.image = [UIImage imageNamed:@"no_image"];
        _imageUrl = imageUrl;
        if (_imageUrl) {
            [[MTNetCacheManager defaultManager] getImageWithUrl:imageUrl
                                                          block:^(id result) {
                                                              if (result) {
                                                                  _imageView.image = result;
                                                              }else {
                                                                  _currentRequest = [GSGlobals requestForURL:[NSURL URLWithString:_imageUrl]];
                                                                  _currentRequest.delegate = self;
                                                                  [_currentRequest startAsynchronous];
                                                              }
                                                          }];
        }
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    [[MTNetCacheManager defaultManager] setData:request.responseData
                                        withUrl:_imageUrl];
    _currentRequest = NULL;
    _imageView.image = [UIImage imageWithData:request.responseData];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"Load failed, %@", request.error);
}

@end
