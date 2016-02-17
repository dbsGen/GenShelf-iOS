//
//  GSSelectCell.h
//  GenShelf
//
//  Created by Gen on 16-2-17.
//  Copyright (c) 2016年 AirRaidClub. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSSelectCell : UITableViewCell

@property (nonatomic, readonly) UILabel *contentLabel;

@property (nonatomic, strong) NSArray *options;
@property (nonatomic, assign) NSInteger opetionSelected;

@end
