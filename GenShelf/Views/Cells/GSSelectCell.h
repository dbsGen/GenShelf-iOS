//
//  GSSelectCell.h
//  GenShelf
//
//  Created by Gen on 16-2-17.
//  Copyright (c) 2016年 AirRaidClub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSSelectView.h"

@class GSSelectCell;

@protocol GSSelectCellDelegate <NSObject>

- (void)selectCellChanged:(GSSelectCell *)cell;

@end

@interface GSSelectCell : UITableViewCell <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, readonly) UILabel *contentLabel;

@property (nonatomic, strong) NSArray *options;
@property (nonatomic, assign) NSInteger opetionSelected;
@property (nonatomic, weak) id<GSSelectCellDelegate> delegate;


- (GSSelectView *)makePickView;

@end
