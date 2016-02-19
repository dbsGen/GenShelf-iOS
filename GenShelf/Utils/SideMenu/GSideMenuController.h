//
//  GSideMenuViewController.h
//  GenShelf
//
//  Created by Gen on 16/2/19.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSideMenuController : UIViewController

@property (nonatomic, strong) NSArray *controllers;
@property (nonatomic, strong) NSArray *images;

@property (nonatomic) NSUInteger selectedIndex;

- (void)openMenu;
- (void)closeMenu;

- (void)touchMove:(CGFloat)offset;
- (void)touchEnd;

@end


@interface UIViewController (GSideMenuController)

- (GSideMenuController *)sideMenuController;

@end