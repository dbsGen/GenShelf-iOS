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
#import "GSBottomLoadingCell.h"

@interface GSHomeViewController () <UITableViewDelegate, UITableViewDataSource, SRRefreshDelegate>

@property (nonatomic, strong) SRRefreshView *refreshView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, assign) NSInteger index;

@end

@implementation GSHomeViewController {
    BOOL _loaded;
    BOOL _loading;
    BOOL _hasNext;
    NSMutableArray<GSBookItem *> *_datas;
    GSBottomLoadingCell *_bottomCell;
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
    BOOL expire = NO;
    _datas = [NSMutableArray arrayWithArray:[GSBookItem cachedItems:&_index hasNext:&_hasNext
                                                             expire:&expire]];
    [_refreshView update:20 + self.navigationController.navigationBar.bounds.size.height];
    
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.view addSubview:_tableView];
    
    if (_datas.count == 0 || expire) {
        [self requestDatas];
        _refreshView.loading = YES;
        _tableView.contentInset = UIEdgeInsetsMake(_refreshView.upInset, 0, 0, 0);
    }
    
    _bottomCell = [[GSBottomLoadingCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:@"BottomCell"];
    [self updateLoadingStatus];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [_refreshView removeFromSuperview];
    _tableView = NULL;
    _refreshView = NULL;
    _bottomCell = NULL;
}

- (void)dealloc
{
    [_refreshView removeFromSuperview];
}

- (void)openMenu {
    [self.sideMenuController openMenu];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < _datas.count) {
        return 180;
    }else {
        return 64;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datas.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < _datas.count) {
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
    }else {
        [self requestMore];
        return _bottomCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < _datas.count) {
        GSBookItem *item = [_datas objectAtIndex:indexPath.row];
        GSPreviewViewController *preview = [[GSPreviewViewController alloc] init];
        preview.item = item;
        [self.navigationController pushViewController:preview
                                             animated:YES];
    }
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

- (void)updateLoadingStatus {
    if (_loading) {
        _bottomCell.status = GSBottomCellStatusLoading;
    }else {
        if (_hasNext) {
            _bottomCell.status = GSBottomCellStatusHasMore;
        }else  {
            _bottomCell.status = GSBottomCellStatusNoMore;
        }
    }
}

- (void)requestDatas {
    if (_loading) return;
    _loading = YES;
    ASIHTTPRequest *request = [[GSGlobals dataControl] mainRequest:0];
    __weak ASIHTTPRequest *_request = request;
    [self updateLoadingStatus];
    [request setCompletionBlock:^{
        NSArray<GSBookItem *> *arr = [[GSGlobals dataControl] parseMain:_request.responseString hasNext:&_hasNext];
        _datas = [NSMutableArray<GSBookItem *> arrayWithArray:arr];
        [_tableView reloadData];
        _loaded = YES;
        [_refreshView endRefresh];
        _index = 0;
        [GSBookItem cacheItems:_datas page:_index hasNext:_hasNext];
        _loading = NO;
        [self updateLoadingStatus];
    }];
    [request setFailedBlock:^{
        [_refreshView endRefresh];
        [MBLMessageBanner showMessageBannerInViewController:self
                                                      title:@"Error"
                                                   subtitle:@"不能获得"
                                                       type:MBLMessageBannerTypeError
                                                 atPosition:MBLMessageBannerPositionTop];
        _loading = NO;
        [self updateLoadingStatus];
    }];
    [_queue addOperation:request];
}

- (void)requestMore {
    if (_loading)
        return;
    NSInteger index = _index + 1;
    ASIHTTPRequest *request = [[GSGlobals dataControl] mainRequest:index];
    __weak ASIHTTPRequest *_request = request;
    _loading = YES;
    [self updateLoadingStatus];
    [request setCompletionBlock:^{
        NSArray<GSBookItem *> *arr = [[GSGlobals dataControl] parseMain:_request.responseString hasNext:&_hasNext];
        NSMutableArray<NSIndexPath *> *indexes = [NSMutableArray array];
        [arr enumerateObjectsUsingBlock:^(GSBookItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![_datas containsObject:obj]) {
                [indexes addObject:[NSIndexPath indexPathForRow:_datas.count
                                                      inSection:0]];
                [_datas addObject:obj];
            }
        }];
        [_tableView insertRowsAtIndexPaths:indexes
                          withRowAnimation:UITableViewRowAnimationAutomatic];
        _index = index;
        [GSBookItem cacheItems:_datas page:_index hasNext:_hasNext];
        _loading = NO;
        [self updateLoadingStatus];
    }];
    [request setFailedBlock:^{
        [MBLMessageBanner showMessageBannerInViewController:self
                                                      title:@"Error"
                                                   subtitle:@"不能获得"
                                                       type:MBLMessageBannerTypeError
                                                 atPosition:MBLMessageBannerPositionTop];
        _loading = NO;
        [self updateLoadingStatus];
    }];
    [_queue addOperation:request];
}

@end
