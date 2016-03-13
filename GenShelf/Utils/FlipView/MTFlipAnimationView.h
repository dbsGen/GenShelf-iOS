//
//  FZDetailFlipView.h
//  Photocus
//
//  Created by zrz on 12-5-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MTBlockOperation.h"

@interface MTFlipAnimationView : UIView

@property (nonatomic, readonly) UIImageView *imageView;
@property (nonatomic, strong)   NSString    *indentify;
@property (nonatomic, assign)   NSInteger   index;
@property (nonatomic, readonly, assign) CGFloat animationPercent;
@property (nonatomic, assign)   CGSize      imageSize;

//this method will be called when this view be sent to cache.
- (void)clean;

/**
 * 
 *
 */
- (void)setAnimationPercent:(CGFloat)percent;
- (void)setBorderPercent:(CGFloat)percent;
- (NSOperationQueue*)mainQueue;

- (void)renderedImage:(UIImage*)image;

- (void)startRender:(MTBlockOperationBlock)block;

@end
