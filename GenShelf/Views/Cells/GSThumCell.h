//
//  GSThumCell.h
//  GenShelf
//
//  Created by Gen on 16/2/23.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSRadiusImageView.h"

@interface GSThumCell : UICollectionViewCell

@property (nonatomic, readonly) GSRadiusImageView *imageView;
@property (nonatomic, strong) NSString *imageUrl;

@end
