//
//  GSProgressView.m
//  GenShelf
//
//  Created by Gen on 16/3/12.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSProgressView.h"

@implementation GSProgressView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.color = [UIColor blueColor];
        self.percent = 0;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGRect bounds = self.bounds;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint points[4] = {CGPointMake(0, 0),
        CGPointMake(bounds.size.width * _percent, 0),
        CGPointMake(bounds.size.width * _percent, bounds.size.height),
        CGPointMake(0, bounds.size.height)};
    CGContextAddLines(context, points, 4);
    CGContextSetFillColorWithColor(context, _color.CGColor);
    CGContextDrawPath(context, kCGPathFill);
}

- (void)setFrame:(CGRect)frame {
    if (!CGRectEqualToRect(frame, self.frame)) {
        [super setFrame:frame];
        [self setNeedsDisplay];
    }
}

- (void)setColor:(UIColor *)color {
    if (color != _color) {
        _color = color;
        [self setNeedsDisplay];
    }
}

- (void)setPercent:(CGFloat)percent {
    if (_percent != percent) {
        _percent = percent;
        [self setNeedsDisplay];
    }
}

@end
