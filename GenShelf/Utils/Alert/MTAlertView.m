//
//  MTAlertView.m
//  SOP2p
//
//  Created by zrz on 12-6-22.
//  Copyright (c) 2012年 Sctab. All rights reserved.
//

#import "MTAlertView.h"
#import <QuartzCore/QuartzCore.h>

@implementation MTAlertView {
    UILabel     *_label;
    UIImageView *_imageView;
}

@synthesize delegate = _delegate;

- (CGRect)autoImage:(UIImage*)image maxRect:(CGRect)rect
{
    CGRect addRect;
    CGSize tSize = image.size;
    if (tSize.height < rect.size.height && tSize.width < rect.size.width) {
        addRect.origin.y = rect.origin.y + (rect.size.height - tSize.height) / 2;
        addRect.origin.x = rect.origin.x + (rect.size.width - tSize.width) / 2;
        addRect.size.width = tSize.width;
        addRect.size.height = tSize.height;
    }else{
        if (tSize.height * rect.size.width / tSize.width > rect.size.height) {
            addRect.size.height = rect.size.height;
            addRect.size.width = tSize.width * rect.size.height / tSize.height;
            addRect.origin.x = rect.origin.x + (rect.size.width - addRect.size.width) / 2;
            addRect.origin.y = rect.origin.y;
        }else {
            addRect.origin.x = rect.origin.x;
            addRect.size.width = rect.size.width;
            addRect.size.height = tSize.height * rect.size.width / tSize.width;
            addRect.origin.y = rect.origin.y + (rect.size.height - addRect.size.height) / 2;
        }
    }
    return addRect;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:0.0f 
                                                 alpha:0.9f];
    }
    return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    if (self.backgroundColor != backgroundColor) {
        [super setBackgroundColor:backgroundColor];
        self.layer.shadowColor = backgroundColor.CGColor;
        self.layer.shadowOpacity = 1.0f;
        self.layer.cornerRadius = 5.0f;
    }
}

- (id)initWithContent:(NSString *)content image:(UIImage *)image buttons:(NSString *)label, ...
{
    self = [self init];
    if (self) {
        //width 200
        CGFloat top = 0;
        
        int count = 0;
        NSString *str[10];
        if ((str[0] = label)) {
            va_list list;
            va_start(list, label);
            count = 1;
            while ((str[count] = va_arg(list, id))) {
                count++;
            }
            va_end(list);
        }
        
        if (count) {
            top += 45;
            CGFloat buttonW = 184.0f / count;
            for (int n = 0 ; n < count; n++) {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                button.frame = CGRectMake(10 + buttonW * n, 6, buttonW-4, 27);
                [button setTitle:str[n]
                        forState:UIControlStateNormal];
                [button addTarget:self
                           action:@selector(buttonClicked:)
                 forControlEvents:UIControlEventTouchUpInside];
                button.tag = n;
                [self addSubview:button];
            }
        }
        
        if (content) {
            CGSize size = [content sizeWithFont:[UIFont systemFontOfSize:12]
                              constrainedToSize:CGSizeMake(180.0f, MAXFLOAT)];
            _label = [[UILabel alloc] initWithFrame:(CGRect){10.0f, top, 180.0f, size.height}];
            _label.numberOfLines = 0;
            _label.textColor = [UIColor whiteColor];
            _label.font = [UIFont systemFontOfSize:12];
            _label.backgroundColor = [UIColor clearColor];
            _label.textAlignment = NSTextAlignmentCenter;
            _label.text = content;
            [self addSubview:_label];
            top += size.height + 30.0f;
        }
        if (image) {
            CGRect rect = [self autoImage:image
                                  maxRect:CGRectMake(10.0f, top, 180, 180)];
            _imageView = [[UIImageView alloc] initWithFrame:
                          CGRectMake(10, top, rect.size.width,
                                     rect.size.height)];
            [self addSubview:_imageView];
            top += rect.size.height + 30;
        }
        CGRect sb = [UIScreen mainScreen].bounds;
        self.frame = CGRectMake(sb.size.width-200,
                                sb.size.height-top,
                                200, top);
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
                 
- (void)buttonClicked:(UIButton*)button
{
    if ([_delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [_delegate alertView:self clickedButtonAtIndex:button.tag];
    }
    [self miss];
}

- (void)show
{
//    void(^imageBlock)(UIImage *image) = ^(UIImage *image){
//        
//    };
//    [[MTImageCenter defaultCenter] getImageFromLayer:self.layer
//                                          whithBlock:imageBlock];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [self showInView:window];
}

- (void)showInView:(UIView*)view
{
    
    CGPoint p = self.center;
    CGRect sb = [UIScreen mainScreen].bounds;
    self.center = CGPointMake(sb.size.width + self.bounds.size.width / 2,
                              p.y);
    [view addSubview:self];
    [UIView transitionWithView:self
                      duration:0.25
                       options:UIViewAnimationOptionCurveEaseOut
                    animations:^{
                        self.center = CGPointMake(sb.size.width - self.bounds.size.width / 2,
                                                  p.y);
                    } completion:^(BOOL finished) {
                        
                    }];
}

- (void)miss
{
    CGPoint p = self.center;
    CGRect sb = [UIScreen mainScreen].bounds;
    [UIView transitionWithView:self
                      duration:0.25
                       options:UIViewAnimationOptionCurveEaseOut
                    animations:^{
                        self.center = CGPointMake(sb.size.width + self.bounds.size.width / 2,
                                                  p.y);
                    } completion:nil];
    [self performSelector:@selector(removeFromSuperview)
               withObject:nil
               afterDelay:0.25];
}

@end
