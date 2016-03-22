//
//  GSPageFlipView.h
//  GenShelf
//
//  Created by Gen on 16/3/1.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "MTFlipAnimationView.h"

@interface GSPageFlipView : MTFlipAnimationView

@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, readonly) CGPoint translation;
@property (nonatomic, assign) BOOL fullMode;

- (void)renderPath:(NSString *)path scale:(CGFloat)scale translation:(CGPoint)trans;
- (void)renderImage:(UIImage *)image scale:(CGFloat)scale translation:(CGPoint)trans;
- (void)renderImage:(UIImage *)image frame:(CGRect)frame;

@end
