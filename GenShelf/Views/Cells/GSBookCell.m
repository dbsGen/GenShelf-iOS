//
//  GSBookCell.m
//  GenShelf
//
//  Created by Gen on 16/2/23.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSBookCell.h"
#import "MTNetCacheManager.h"
#import "GSGlobals.h"

@interface GSBookCell () <ASIHTTPRequestDelegate>

@end

@implementation GSBookCell {
    ASIHTTPRequest *_currentRequest;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _thumView = [[GSRadiusImageView alloc] initWithFrame:CGRectMake(10, 10, 120, 120)];
        _thumView.radius = 5;
        _thumView.image = [UIImage imageNamed:@"no_image"];
        [self.contentView addSubview:_thumView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 10, self.contentView.bounds.size.width - 150, self.contentView.bounds.size.height - 20)];
        _titleLabel.numberOfLines = 0;
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_titleLabel];
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
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

- (void)setImageUrl:(NSString *)imageUrl {
    if (_imageUrl != imageUrl) {
        if (_currentRequest) {
            [_currentRequest cancel];
            _currentRequest = NULL;
        }
        _thumView.image = [UIImage imageNamed:@"no_image"];
        _imageUrl = imageUrl;
        if (_imageUrl) {
            [[MTNetCacheManager defaultManager] getImageWithUrl:imageUrl
                                                          block:^(id result) {
                                                              if (result) {
                                                                  _thumView.image = result;
                                                              }else {
                                                                  _currentRequest = [GSGlobals requestForURL:[NSURL URLWithString:_imageUrl]];
                                                                  _currentRequest.delegate = self;
                                                                  [_currentRequest startAsynchronous];
                                                              }
                                                          }];
        }
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    [[MTNetCacheManager defaultManager] setData:request.responseData
                                        withUrl:_imageUrl];
    _currentRequest = NULL;
    _thumView.image = [UIImage imageWithData:request.responseData];
}

@end
