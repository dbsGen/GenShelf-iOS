//
//  GSProgressCell.m
//  GenShelf
//
//  Created by Gen on 16/3/11.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSProgressCell.h"

@interface GSProgressCell () <GSBookItemDelegate>

@end

@implementation GSProgressCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect bounds = self.bounds;
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 6, bounds.size.width - 160, 30)];
        _nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_nameLabel];
        
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 200, 30)];
        _detailLabel.textColor = [UIColor grayColor];
        _detailLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_detailLabel];
        
        _resumeButton = [[UIButton alloc] initWithFrame:CGRectMake(bounds.size.width - 100, 10, 40, 40)];
        [_resumeButton setImage:[UIImage imageNamed:@"play"]
                       forState:UIControlStateNormal];
        _resumeButton.hidden = YES;
        _resumeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [_resumeButton addTarget:self
                          action:@selector(resumeClicked)
                forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_resumeButton];
        
        _pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(bounds.size.width - 100, 10, 40, 40)];
        [_pauseButton setImage:[UIImage imageNamed:@"pause"]
                       forState:UIControlStateNormal];
        _pauseButton.hidden = YES;
        _pauseButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [_pauseButton addTarget:self
                          action:@selector(pauseClicked)
                forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_pauseButton];
        
        _deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(bounds.size.width - 50, 10, 40, 40)];
        [_deleteButton setImage:[UIImage imageNamed:@"delete"]
                      forState:UIControlStateNormal];
        _deleteButton.hidden = YES;
        _deleteButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [_deleteButton addTarget:self
                          action:@selector(deleteClicked)
                forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteButton];
        
        _progressView = [[GSProgressView alloc] initWithFrame:CGRectMake(10, bounds.size.height - 4, bounds.size.width - 20, 4)];
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_progressView];
    }
    return self;
}

- (void)dealloc {
    if (_data) {
        _data.delegate = nil;
    }
}

- (void)setData:(GSBookItem *)data {
    if (_data != data) {
        if (_data) {
            _data.delegate = nil;
        }
        _data = data;
        if (_data) {
            _data.delegate = self;
        }
        _nameLabel.text = _data.title;
        [self updatePercent];
        [self updateStatus];
        
    }
}

- (void)onPercentUpdate:(NSNotification*)notification {
    if (notification.object == _data) {
        [self updatePercent];
    }
}

- (void)updatePercent {
    [_progressView setPercent:_data.percent animated:NO];
}

- (void)updateStatus {
    switch (_data.status) {
        case GSBookItemStatusNotStart:
            if (_data.loading) {
                _detailLabel.text = local(Loading list);
            }else {
                _detailLabel.text = local(Not start);
            }
            break;
        case GSBookItemStatusComplete:
        case GSBookItemStatusProgressing:
            if (_data.loading) {
                _detailLabel.text = local(Progressing);
            }else {
                _detailLabel.text = local(Paused);
            }
            break;
        case GSBookItemStatusPagesComplete:
            _detailLabel.text = local(Complete);
            break;
            
        default:
            break;
    }
    [self updateLoading];
}

- (void)updateLoading {
    if (_data.status == GSBookItemStatusPagesComplete) {
        _resumeButton.hidden = YES;
        _pauseButton.hidden = YES;
        _deleteButton.hidden = NO;
    }else {
        if (_data.loading) {
            _resumeButton.hidden = YES;
            _pauseButton.hidden = NO;
            _deleteButton.hidden = NO;
        }else {
            _resumeButton.hidden = NO;
            _pauseButton.hidden = YES;
            _deleteButton.hidden = NO;
        }
    }
}

- (void)resumeClicked {
    if ([_delegate respondsToSelector:@selector(progressCellResume:)]) {
        [_delegate progressCellResume:self];
    }
}

- (void)pauseClicked {
    if ([_delegate respondsToSelector:@selector(progressCellPause:)]) {
        [_delegate progressCellPause:self];
    }
}

- (void)deleteClicked {
    if ([_delegate respondsToSelector:@selector(progressCellDelete:)]) {
        [_delegate progressCellDelete:self];
    }
}

#pragma mark - item delegate

- (void)bookItem:(GSBookItem *)item progress:(CGFloat)percent {
    [_progressView setPercent:percent animated:YES];
}

- (void)bookItem:(GSBookItem *)item status:(GSBookItemStatus)status loading:(BOOL)loading {
    [self updateStatus];
}

@end
