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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect bounds = self.contentView.bounds;
        _inputView = [[UITextField alloc] initWithFrame:CGRectMake(bounds.size.width/2, 10,
                                                                   bounds.size.width/2-10,
                                                                   bounds.size.height-20)];
        [_inputView setTextAlignment:NSTextAlignmentRight];
        [_inputView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [self.contentView addSubview:_inputView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

@end
