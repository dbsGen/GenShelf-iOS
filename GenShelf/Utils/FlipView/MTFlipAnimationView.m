//
//  FZDetailFlipView.m
//  Photocus
//
//  Created by zrz on 12-5-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MTFlipAnimationView.h"

static NSOperationQueue *__queue;

@implementation MTFlipAnimationView
{
    MTBlockOperation *_operation;
}

@synthesize indentify = _indentify, imageView = _imageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _indentify = @"defaulte";
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageSize = frame.size;
        self.userInteractionEnabled = NO;
        [self addSubview:_imageView];
    }
    return self;
}


- (void)clean{
    [_operation cancel];
    _operation.completeBlock = nil;
    _operation.block = nil;
    _operation = nil;
}

- (void)setAnimationPercent:(CGFloat)percent{
    _animationPercent = percent;
}

- (NSOperationQueue*)mainQueue
{
    if (!__queue) {
        __queue = [[NSOperationQueue alloc] init];
        __queue.maxConcurrentOperationCount = 1;
        [__queue setSuspended:NO];
    }
    return __queue;
}

- (void)startRender:(MTBlockOperationBlock)block
{
    MTBlockOperation *operation = [[MTBlockOperation alloc] init];
    operation.block = block;
    [operation setCompleteBlock:^(UIImage *image) {
        [self renderedImage:image];
    }];
    operation.size = _imageSize;
    [self.mainQueue addOperation:operation];
    _operation = operation;
}

- (void)renderedImage:(UIImage*)image
{
    _imageView.image = image;
}

@end
