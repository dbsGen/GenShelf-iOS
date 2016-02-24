//
//  GShadowView.m
//  GenShelf
//
//  Created by Gen on 16/2/20.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GShadowView.h"
#import <stdio.h>

@implementation GShadowView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _colors = [NSArray arrayWithObjects:[UIColor colorWithWhite:0 alpha:0], [UIColor colorWithWhite:0 alpha:0.1], [UIColor colorWithWhite:0 alpha:0.3], nil];
        _status = GShadowViewRL;
    }
    return self;
}

- (void)setStatus:(GShadowViewStatus)status {
    if (_status != status) {
        _status = status;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger count = _colors.count;
    CGColorRef *cgColors = malloc(sizeof(CGColorRef)*count);
    CGFloat *positions = malloc(sizeof(CGFloat)*count);
    CGFloat off_count = 0, add = 1.0/(count-1);
    for (NSUInteger n = 0, t = count; n < t; n ++) {
        cgColors[n] = [_colors objectAtIndex:n].CGColor;
        positions[n] = off_count;
        off_count += add;
    }
    CFArrayRef colorArray = CFArrayCreate(kCFAllocatorDefault, (const void **)cgColors, count, nil);
    
    CGGradientRef gradientRef = CGGradientCreateWithColors(colorSpaceRef, colorArray, positions);
    
    CGPoint startp,endp;
    switch (_status) {
        case GShadowViewLR:
            startp = CGPointMake(0, 0);
            endp = CGPointMake(self.bounds.size.width, 0);
            break;
        case GShadowViewRL:
            startp = CGPointMake(self.bounds.size.width, 0);
            endp = CGPointMake(0, 0);
            break;
        case GShadowViewTB:
            startp = CGPointMake(0, 0);
            endp = CGPointMake(0, self.bounds.size.height);
            break;
        case GShadowViewBT:
            startp = CGPointMake(0, self.bounds.size.height);
            endp = CGPointMake(0, 0);
            break;
            
        default:
            break;
    }
    
    CGContextDrawLinearGradient(context, gradientRef, endp, startp, kCGGradientDrawsBeforeStartLocation);
    CGGradientRelease(gradientRef);
    CGColorSpaceRelease(colorSpaceRef);
    free(cgColors);
    free(positions);
}

- (void)setColors:(NSArray<UIColor *> *)colors {
    if (_colors != colors) {
        _colors = colors;
        [self setNeedsDisplay];
    }
}

@end
