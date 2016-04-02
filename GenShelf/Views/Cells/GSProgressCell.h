//
//  GSProgressCell.h
//  GenShelf
//
//  Created by Gen on 16/3/11.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSModelNetBook.h"
#import "GSProgressView.h"

@class GSProgressCell;

@protocol GSProgressCellDelegate <NSObject>

@optional
- (void)progressCellResume:(GSProgressCell *)cell;
- (void)progressCellPause:(GSProgressCell *)cell;
- (void)progressCellDelete:(GSProgressCell *)cell;

@end

@interface GSProgressCell : UITableViewCell

@property (nonatomic, strong) GSModelNetBook *data;

@property (nonatomic, readonly) UILabel *nameLabel;
@property (nonatomic, readonly) UILabel *detailLabel;
@property (nonatomic, readonly) GSProgressView *progressView;
@property (nonatomic, readonly) UIButton *resumeButton;
@property (nonatomic, readonly) UIButton *pauseButton;
@property (nonatomic, readonly) UIButton *deleteButton;
@property (nonatomic, weak) id<GSProgressCellDelegate> delegate;

@end
