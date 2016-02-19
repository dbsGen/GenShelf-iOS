//
//  GSSelectView.m
//  GenShelf
//
//  Created by Gen on 16/2/18.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSSelectView.h"

@interface GSSelectView () {
    UIView *_contentView;
}

- (void)onCancel;

@end

@implementation GSSelectView

- (id)initWithFrame:(CGRect)frame {
    CGRect bounds = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:bounds];
    if (self) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, bounds.size.height, bounds.size.width, 260)];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_contentView];
        
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, bounds.size.width, 216)];
        _pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [_contentView addSubview:_pickerView];
        
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, 44)];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"确定"
                                                                 style:UIBarButtonItemStyleDone
                                                                target:self
                                                                action:@selector(onCancel)];
        
        _toolBar.items = @[item];
        _toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        _toolBar.layer.shadowColor = [[UIColor blackColor] CGColor];
        _toolBar.layer.shadowOffset = CGSizeMake(0, 4);
        _toolBar.layer.shadowRadius = 4;
        _toolBar.layer.shadowOpacity = 0.3;
        [_contentView addSubview:_toolBar];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)show {
    CGRect bounds = self.bounds;
    [UIView animateWithDuration:0.2
                     animations:^{
                         _contentView.frame = CGRectMake(0, bounds.size.height-260,
                                                         bounds.size.width,
                                                         260);
                         self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
                     }];
}

- (void)miss {
    CGRect bounds = self.bounds;
    [UIView animateWithDuration:0.2
                     animations:^{
                         _contentView.frame = CGRectMake(0, bounds.size.height,
                                                         bounds.size.width,
                                                         260);
                         self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

- (void)onCancel {
    [self miss];
}

@end
