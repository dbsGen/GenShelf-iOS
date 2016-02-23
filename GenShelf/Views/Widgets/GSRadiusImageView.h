//
//  UIRadisImageView.h
//  GenShelf
//
//  Created by Gen on 16/2/23.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSRadiusImageView : UIView

@property (nonatomic, readonly) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) CGFloat radius;

@end
