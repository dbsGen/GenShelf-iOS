//
//  GSBottomLoadingCell.h
//  GenShelf
//
//  Created by Gen on 16/3/14.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    GSBottomCellStatusLoading,
    GSBottomCellStatusHasMore,
    GSBottomCellStatusNoMore,
} GSBottomCellStatus;

@interface GSBottomLoadingCell : UITableViewCell

@property (nonatomic, readonly) UIActivityIndicatorView *indicatorView;
@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, assign) GSBottomCellStatus status;

@end
