//
//  GSShelfViewController.m
//  GenShelf
//
//  Created by Gen on 16/2/19.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSShelfViewController.h"
#import "GSideMenuController.h"

@interface GSShelfViewController ()

@end

@implementation GSShelfViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"书架";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"]
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(openMenu)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 30)];
    [button setTitle:@"OpenMenu"
            forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(openMenu)
     forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor redColor];
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openMenu {
    [self.sideMenuController openMenu];
}

@end
