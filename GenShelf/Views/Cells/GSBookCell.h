//
//  GSBookCell.h
//  GenShelf
//
//  Created by Gen on 16/2/23.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSRadisImageView.h"

@interface GSBookCell : UITableViewCell

@property (nonatomic, readonly) GSRadisImageView *thumView;
@property (nonatomic, readonly) UILabel *titleLabel;

@property (nonatomic, strong) NSString *imageUrl;

@end
