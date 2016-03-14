//
//  GSBottomLoadingCell.m
//  GenShelf
//
//  Created by Gen on 16/3/14.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSBottomLoadingCell.h"

@implementation GSBottomLoadingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect bounds = self.bounds;
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(bounds.size.width * 0.5, 0, bounds.size.width*0.5, bounds.size.height)];
        _titleLabel.text = @"Loading...";
        [self addSubview:_titleLabel];
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGRect frame = _indicatorView.frame;
        _indicatorView.frame = CGRectMake(bounds.size.width*0.5-frame.size.width,
                                          (bounds.size.height - frame.size.height) / 2,
                                          frame.size.width,
                                          frame.size.height);
        [_indicatorView startAnimating];
        [self addSubview:_indicatorView];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _titleLabel.frame = CGRectMake(frame.size.width * 0.5 - 30, 0, frame.size.width*0.5, frame.size.height);
    CGRect _frame = _indicatorView.frame;
    _indicatorView.frame = CGRectMake(frame.size.width*0.5-_frame.size.width - 44,
                                      (frame.size.height - _frame.size.height) / 2,
                                      _frame.size.width,
                                      _frame.size.height);
}

- (void)setStatus:(GSBottomCellStatus)status {
    if (_status != status) {
        _status = status;
        if (_status == GSBottomCellStatusLoading) {
            _titleLabel.text = @"Loading...";
            [_indicatorView startAnimating];
            self.selectionStyle = UITableViewCellSelectionStyleNone;
        }else if (_status == GSBottomCellStatusNoMore) {
            [_indicatorView stopAnimating];
            _titleLabel.text = @"No more";
            self.selectionStyle = UITableViewCellSelectionStyleNone;
        }else if (_status == GSBottomCellStatusHasMore) {
            [_indicatorView stopAnimating];
            _titleLabel.text = @"Load more";
            self.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
    }
}

@end
