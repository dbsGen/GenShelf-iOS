//
//  GSLoadingCell.m
//  GenShelf
//
//  Created by Gen on 16/2/19.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSLoadingCell.h"

@implementation GSLoadingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect bounds = self.contentView.bounds;
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.center = CGPointMake(bounds.size.width - _indicatorView.bounds.size.width/2 - 10,
                                            bounds.size.height/2);
        _indicatorView.hidesWhenStopped = YES;
        _indicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_indicatorView];
        
        _resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(bounds.size.width/2, 10,
                                                                 bounds.size.width/2-10,
                                                                 bounds.size.height-20)];
        _resultLabel.textAlignment = NSTextAlignmentRight;
        _resultLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        _resultLabel.textColor = [UIColor redColor];
        [self addSubview:_resultLabel];
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    return self;
}

- (void)setStatus:(GSLoadingCellStatus)status {
    _status = status;
    switch (_status) {
        case GSLoadingCellStatusLoading:
            self.accessoryType = UITableViewCellAccessoryNone;
            [_indicatorView startAnimating];
            _resultLabel.text = nil;
            break;
        case GSLoadingCellStatusSuccess:
            self.accessoryType = UITableViewCellAccessoryCheckmark;
            [_indicatorView stopAnimating];
            _resultLabel.text = nil;
            break;
        case GSLoadingCellStatusFailed:
            self.accessoryType = UITableViewCellAccessoryNone;
            [_indicatorView stopAnimating];
            _resultLabel.text = @"失败";
        default:
            break;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        [self performSelector:@selector(restore:)
                   withObject:[NSNumber numberWithBool:animated]
                   afterDelay:0];
    }
}

- (void)restore:(NSNumber*)animated {
    [self setSelected:NO animated:[animated boolValue]];
}

@end
