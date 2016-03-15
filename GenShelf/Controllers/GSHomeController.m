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
#import "GSProgressViewController.h"
#import "GSBookItem.h"
#import "RKDropdownAlert.h"
#import "GCoverView.h"

@interface GSHomeController ()

@end

@implementation GSHomeController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.items = @[[GSideMenuItem itemWithController:[[GSShelfViewController alloc] init] image:[UIImage imageNamed:@"squares"]],
                       [GSideMenuItem itemWithController:[[GSHomeViewController alloc] init] image:[UIImage imageNamed:@"home"]],
                       [GSideMenuItem itemWithController:[[GSSearchViewController alloc] init] image:[UIImage imageNamed:@"search"]],
                       [GSideMenuItem itemWithTitle:@"进程" image:[UIImage imageNamed:@"progress"] block:^{
                           GSProgressViewController *con = [[GSProgressViewController alloc] init];
                           UINavigationController *progress = [[UINavigationController alloc] initWithRootViewController:con];
                           GCoverView *cover = [[GCoverView alloc] initWithController:progress];
                           __weak GCoverView *_c = cover;
                           con.onClose = ^ {
                               [_c miss];
                           };
                           [cover showInView:[[UIApplication sharedApplication].delegate window]];
                       }],
                       [GSideMenuItem itemWithController:[[GSSettingsViewController alloc] init] image:[UIImage imageNamed:@"setting"]]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onFailed:)
                                                     name:BOOK_ITEM_FAILED
                                                   object:nil];
    }
    return self;
}

- (void)sideMenuSelect:(NSUInteger)index {
    [self closeMenu];
}

- (void)onFailed:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[GSBookItem class]]) {
        GSBookItem *item = notification.object;
        [RKDropdownAlert title:[NSString stringWithFormat:@"%@ 失败!", item.title]
               backgroundColor:[UIColor redColor]
                     textColor:[UIColor whiteColor]];
    }
}

@end
