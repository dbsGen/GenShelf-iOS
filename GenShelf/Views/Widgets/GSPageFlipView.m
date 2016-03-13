//
//  GSPageFlipView.m
//  GenShelf
//
//  Created by Gen on 16/3/1.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSPageFlipView.h"
#import "GEase.h"

@implementation GSPageFlipView {
    UIImageView     *_topShadow,
                    *_downShadow;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImage *image = [UIImage imageNamed:@"bg_detail_panelshadow"];
        _topShadow = [[UIImageView alloc] initWithImage:image];
        _topShadow.layer.transform = CATransform3DMakeRotation(- M_PI / 2, 0, 0, 1);
        _topShadow.frame = CGRectMake(0, -15, frame.size.width, 15);
        [self addSubview:_topShadow];
        
        _downShadow = [[UIImageView alloc] initWithImage:image];
        _downShadow.layer.transform = CATransform3DMakeRotation(M_PI / 2, 0, 0, 1);
        _downShadow.frame = CGRectMake(0, frame.size.height, frame.size.width, 15);
        [self addSubview:_downShadow];
        
        self.backgroundColor = [UIColor whiteColor];
        self.imageSize = CGSizeMake(frame.size.width/2, frame.size.height/2);
        
        _scale = 1;
    }
    return self;
}

- (void)setAnimationPercent:(CGFloat)percent
{
    [super setAnimationPercent:percent];
    CGRect bounds = self.bounds;
    if (percent > 0) {
//        CGFloat scale = (1-percent)*0.3 + 0.7;
//        self.layer.transform = CATransform3DMakeScale(scale, scale, 1);
        percent = 0;
    }else {
        if (percent == -1) {
            percent = -1.1;
        }
//        self.layer.transform = CATransform3DIdentity;
    }
    self.center = CGPointMake(bounds.size.width/2, bounds.size.height/2+ bounds.size.height * percent);
}

- (void)renderPath:(NSString *)path scale:(CGFloat)scale translation:(CGPoint)trans {
    _scale = scale;
    _translation = trans;
    CGRect bounds = self.bounds;
    bounds.size = self.imageSize;
    void (^block)(CGContextRef context) = ^(CGContextRef context){
        CGContextTranslateCTM(context, 0.0f, bounds.size.height);
        CGContextScaleCTM(context, 1.0f, -1.0f);
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        CGSize originalSize = image.size;
        CGRect frame;
        frame.size.height = bounds.size.height;
        frame.size.width = originalSize.width * frame.size.height / originalSize.height;
        frame.origin.y = 0;
        frame.origin.x = (bounds.size.width - frame.size.width)/2;
        CGSize translation = bounds.size;
        frame = CGRectApplyAffineTransform(frame, CGAffineTransformMakeTranslation(trans.x/2-translation.width/2, -trans.y/2-translation.height/2));
        frame = CGRectApplyAffineTransform(frame, CGAffineTransformMakeScale(scale, scale));
        frame = CGRectApplyAffineTransform(frame, CGAffineTransformMakeTranslation(translation.width/2, translation.height/2));
        CGContextDrawImage(context, frame, image.CGImage);
    };
    [self startRender:block];
}

- (void)renderImage:(UIImage *)image scale:(CGFloat)scale translation:(CGPoint)trans {
    if (!image) {
        return;
    }
    _scale = scale;
    _translation = trans;
    CGRect bounds = self.bounds;
    bounds.size = self.imageSize;
    void (^block)(CGContextRef context) = ^(CGContextRef context){
        CGContextTranslateCTM(context, 0.0f, bounds.size.height);
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGSize originalSize = image.size;
        CGRect frame;
        frame.size.height = bounds.size.height;
        frame.size.width = originalSize.width * frame.size.height / originalSize.height;
        frame.origin.y = 0;
        frame.origin.x = (bounds.size.width - frame.size.width)/2;
        CGSize translation = bounds.size;
        frame = CGRectApplyAffineTransform(frame, CGAffineTransformMakeTranslation(trans.x/2-translation.width/2, -trans.y/2-translation.height/2));
        frame = CGRectApplyAffineTransform(frame, CGAffineTransformMakeScale(scale, scale));
        frame = CGRectApplyAffineTransform(frame, CGAffineTransformMakeTranslation(translation.width/2, translation.height/2));
        CGContextDrawImage(context, frame, image.CGImage);
    };
    [self startRender:block];
}

- (void)renderImage:(UIImage *)image frame:(CGRect)frame {
    CGRect bounds = self.bounds;
    bounds.size = self.imageSize;
    void (^block)(CGContextRef context) = ^(CGContextRef context){
        CGContextTranslateCTM(context, 0.0f, bounds.size.height);
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGContextDrawImage(context, frame, image.CGImage);
    };
    [self startRender:block];
}

@end