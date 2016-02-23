//
//  GSHomeController.m
//  GenShelf
//
//  Created by Gen on 16/2/20.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSHomeController.h"
#import "GSShelfViewController.h"
#import "GSHomeViewController.h"
#import "GSSearchViewController.h"
#import "GSSettingsViewController.h"

@interface GSHomeController ()

@end

@implementation GSHomeController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.items = @[[GSideMenuItem itemWithController:[[UINavigationController alloc] initWithRootViewController:[[GSShelfViewController alloc] init]] image:[UIImage imageNamed:@"squares"]],
                       [GSideMenuItem itemWithController:[[UINavigationController alloc] initWithRootViewController:[[GSHomeViewController alloc] init]] image:[UIImage imageNamed:@"home"]],
                       [GSideMenuItem itemWithController:[[GSSearchViewController alloc] init] image:[UIImage imageNamed:@"search"]],
                       [GSideMenuItem itemWithController:[[UINavigationController alloc] initWithRootViewController:[[GSSettingsViewController alloc] init]] image:[UIImage imageNamed:@"setting"]]];
    }
    return self;
}

- (void)sideMenuSelect:(NSUInteger)index {
    [self closeMenu];
}

@end
