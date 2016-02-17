//
//  GSSelectCell.m
//  GenShelf
//
//  Created by Gen on 16-2-17.
//  Copyright (c) 2016年 AirRaidClub. All rights reserved.
//

#import "GSSelectCell.h"

@interface GSSelectCell ()

- (void)updateValue;

@end

@implementation GSSelectCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, 360, 60)];
    if (self) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 10, 200, 40)];
        [_contentLabel setTextAlignment:NSTextAlignmentRight];
        [_contentLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [self addSubview:_contentLabel];
        _opetionSelected = 0;
    }
    return self;
}

- (void)setOptions:(NSArray *)options {
    if (_options != options) {
        _options = options;
        [self updateValue];
    }
}

- (void)setOpetionSelected:(NSInteger)opetionSelected {
    if (_opetionSelected != opetionSelected) {
        _opetionSelected = opetionSelected;
        [self updateValue];
    }
}

- (void)updateValue {
    if (_options && _options.count > _opetionSelected) {
        _contentLabel.text = [_options objectAtIndex:_opetionSelected];
    }
}

@end
