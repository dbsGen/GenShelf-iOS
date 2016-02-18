//
//  GSSwitchCell.m
//  GenShelf
//
//  Created by Gen on 16/2/18.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSSwitchCell.h"

@implementation GSSwitchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect bounds = self.contentView.bounds;
        _switchItem = [[UISwitch alloc] init];
        CGRect frame = _switchItem.frame;
        _switchItem.frame = CGRectMake(bounds.size.width - frame.size.width - 10,
                                       (bounds.size.height - frame.size.height)/2,
                                       frame.size.width,
                                       frame.size.height);
        _switchItem.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_switchItem];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

@end
