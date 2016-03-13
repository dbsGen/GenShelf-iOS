//
//  GSProgressView.h
//  GenShelf
//
//  Created by Gen on 16/3/12.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSProgressView : UIView

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) CGFloat percent;

- (void)setPercent:(CGFloat)percent animated:(BOOL)animated;

@end
