//
//  GSInputCell.m
//  GenShelf
//
//  Created by Gen on 16/2/17.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSInputCell.h"

@implementation GSInputCell

@synthesize inputView = _inputView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, 360, 60)];
    if (self) {
        _inputView = [[UITextField alloc] initWithFrame:CGRectMake(160, 10, 200, 40)];
        [_inputView setTextAlignment:NSTextAlignmentRight];
        [_inputView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [self addSubview:_inputView];
    }
    return self;
}

@end
