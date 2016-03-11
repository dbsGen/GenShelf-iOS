//
//  GCoverView.h
//  GenShelf
//
//  Created by Gen on 16/3/11.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GCoverView : UIView

@property (nonatomic, readonly) UIView  *contentView;
@property (nonatomic, strong) UIView    *contentSubview;

- (id)initWithSubview:(UIView *)subview;
- (id)initWithController:(UIViewController *)controller;
- (void)showInView:(UIView *)view;
- (void)miss;

@end
