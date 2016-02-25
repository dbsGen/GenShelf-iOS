//
//  GSideMenuViewController.h
//  GenShelf
//
//  Created by Gen on 16/2/19.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^GSideMenuItemBlock)();

@interface GSideMenuItem : NSObject

@property (nonatomic, strong) UIViewController *controller;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) GSideMenuItemBlock block;

+ (id)itemWithController:(UIViewController *)controller;
+ (id)itemWithController:(UIViewController *)controller image:(UIImage *)image;
+ (id)itemWithTitle:(NSString *)title block:(GSideMenuItemBlock)block;
+ (id)itemWithTitle:(NSString *)title image:(UIImage *)image block:(GSideMenuItemBlock)block;

@end

@interface GSideMenuController : UIViewController

@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) NSArray<GSideMenuItem*> *items;

@property (nonatomic) NSUInteger selectedIndex;

- (void)openMenu;
- (void)closeMenu;

- (void)touchMove:(CGFloat)offset;
- (void)touchEnd;

- (void)sideMenuSelect:(NSUInteger)index;

@end


@interface UIViewController (GSideMenuController)

- (GSideMenuController *)sideMenuController;

@end