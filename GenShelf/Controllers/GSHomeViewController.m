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
#import "GSBookCell.h"
#import "MBLMessageBanner.h"
#import "GSPreviewViewController.h"

@interface GSHomeViewController () <UITableViewDelegate, UITableViewDataSource, SRRefreshDelegate>

@property (nonatomic, strong) SRRefreshView *refreshView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation GSHomeViewController {
    BOOL _loaded;
    BOOL _loading;
    NSMutableArray<GSBookItem *> *_datas;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"主页";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"]
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(openMenu)];
        _queue = [[NSOperationQueue alloc] init];
        _loaded = false;
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
    
    if (!_loaded) {
        [self requestDatas];
        _refreshView.loading = YES;
        _tableView.contentInset = UIEdgeInsetsMake(_refreshView.upInset, 0, 0, 0);
    }
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 180;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"NormalCell";
    GSBookCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[GSBookCell alloc] initWithStyle:UITableViewCellStyleDefault
                                 reuseIdentifier:identifier];
    }
    GSBookItem *item = [_datas objectAtIndex:indexPath.row];
    cell.imageUrl = item.imageUrl;
    cell.titleLabel.text = item.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GSBookItem *item = [_datas objectAtIndex:indexPath.row];
    [[GSGlobals dataControl] processBook:item];
    GSPreviewViewController *preview = [[GSPreviewViewController alloc] init];
    preview.item = item;
    [self.navigationController pushViewController:preview
                                         animated:YES];
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
    [self requestDatas];
}

#pragma mark - io

- (void)requestDatas {
    if (_loading) return;
    ASIHTTPRequest *request = [[GSGlobals dataControl] mainRequest];
    __weak ASIHTTPRequest *_request = request;
    [request setCompletionBlock:^{
        NSArray<GSBookItem *> *arr = [[GSGlobals dataControl] parseMain:_request.responseString];
        _datas = [NSMutableArray<GSBookItem *> arrayWithArray:arr];
        [_tableView reloadData];
        _loaded = YES;
        [_refreshView endRefresh];
    }];
    [request setFailedBlock:^{
        [_refreshView endRefresh];
        [MBLMessageBanner showMessageBannerInViewController:self
                                                      title:@"Error"
                                                   subtitle:@"不能获得"
                                                       type:MBLMessageBannerTypeError
                                                 atPosition:MBLMessageBannerPositionTop];
    }];
    [_queue addOperation:request];
}

@end
