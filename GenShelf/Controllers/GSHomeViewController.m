//
//  GSHomeViewController.m
//  GenShelf
//
//  Created by Gen on 16/2/19.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSHomeViewController.h"
#import "GSideMenuController.h"
#import "GSGlobals.h"
#import "SRRefreshView.h"

@interface GSHomeViewController () <UITableViewDelegate, UITableViewDataSource, SRRefreshDelegate>

@property (nonatomic, strong) SRRefreshView *refreshView;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation GSHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"主页";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"]
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(openMenu)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect bounds = self.view.bounds;
    _tableView = [[UITableView alloc] initWithFrame:bounds
                                              style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _refreshView = [[SRRefreshView alloc] init];
    _refreshView.slimeMissWhenGoingBack = YES;
    _refreshView.delegate = self;
    [_tableView addSubview:_refreshView];
    [_refreshView update:20 + self.navigationController.navigationBar.bounds.size.height];
    
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.view addSubview:_tableView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [_refreshView removeFromSuperview];
    _tableView = NULL;
    _refreshView = NULL;
}

- (void)dealloc
{
    [_refreshView removeFromSuperview];
}

- (void)openMenu {
    [self.sideMenuController openMenu];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"NormalCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:identifier];
    }
    return cell;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [_refreshView update:20 + self.navigationController.navigationBar.bounds.size.height];
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshView scrollViewDidEndDraging];
}

#pragma mark - slimeRefresh delegate

- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [_refreshView performSelector:@selector(endRefresh)
                       withObject:nil afterDelay:3
                          inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
}

@end
