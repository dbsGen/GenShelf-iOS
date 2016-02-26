//
//  MTBlockOperation.m
//  flipview
//
//  Created by zrz on 12-7-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MTBlockOperation.h"

@implementation MTBlockOperation

@synthesize block = _block, size = _size;
@synthesize completeBlock = _completeBlock;

- (void)main
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 _size.width,
                                                 _size.height,
                                                 8,
                                                 _size.width * 4,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast |
                                                 kCGBitmapByteOrder32Big);
    CGContextTranslateCTM(context, 0.0f, _size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    if ([self isCancelled]) {
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        return;
    }
    if (_block) {
        _block(context);
    }
    CGImageRef image = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    if ([self isCancelled]) {
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        return;
    }
    [self performSelectorOnMainThread:@selector(performMain:)
                           withObject:[UIImage imageWithCGImage:image]
                        waitUntilDone:YES];
    CGImageRelease(image);
}

- (void)performMain:(UIImage*)image
{
    if (_completeBlock) {
        _completeBlock(image);
    }
}

@end
