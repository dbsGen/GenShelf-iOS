//
//  GSSearchViewController.m
//  GenShelf
//
//  Created by Gen on 16/2/19.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSSearchViewController.h"
#import "GSideMenuController.h"

@interface GSSearchViewController () <UISearchBarDelegate>

@end

@implementation GSSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"搜索";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"]
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self.sideMenuController
                                                                                action:@selector(openMenu)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect bounds = self.view.bounds;
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.bounds.size.height + 20, bounds.size.width, 40)];
    searchBar.delegate = self;
    [self.view addSubview:searchBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - search

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
}

@end
