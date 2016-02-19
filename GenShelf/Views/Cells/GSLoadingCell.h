//
//  GSLoadingCell.h
//  GenShelf
//
//  Created by Gen on 16/2/19.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    GSLoadingCellStatusLoading,
    GSLoadingCellStatusFailed,
    GSLoadingCellStatusSuccess,
} GSLoadingCellStatus;

@interface GSLoadingCell : UITableViewCell

@property (nonatomic, readonly) UIActivityIndicatorView *indicatorView;
@property (nonatomic, readonly) UILabel *resultLabel;

@property (nonatomic) GSLoadingCellStatus status;

@end
