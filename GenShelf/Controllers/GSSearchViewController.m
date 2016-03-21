//
//  GSSearchViewController.m
//  GenShelf
//
//  Created by Gen on 16/2/19.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSSearchViewController.h"
#import "GSideMenuController.h"
#import "SRRefreshView.h"
#import "GSBookItem.h"
#import "GSGlobals.h"
#import "GSBottomLoadingCell.h"
#import "GSBookCell.h"
#import "GSPreviewViewController.h"
#import "RKDropdownAlert.h"

#define MIN_LENGTH 3

@interface GSSearchViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, SRRefreshDelegate> {
    NSMutableArray<GSBookItem *> *_datas;
    NSInteger   _index;
    BOOL    _hasNext;
    BOOL    _loading;
    GSBottomLoadingCell *_bottomCell;
    NSString *_searchKey;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SRRefreshView *refreshView;
@property (nonatomic, strong) UISearchBar   *searchBar;

@end

@implementation GSSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _datas = [NSMutableArray array];
        self.title = local(Search);
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
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.frame = CGRectMake(0, self.navigationController.navigationBar.bounds.size.height + 20, bounds.size.width, 40);
    _searchBar.placeholder = local(Input key words here);
    
    _tableView = [[UITableView alloc] initWithFrame:bounds
                                              style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _refreshView = [[SRRefreshView alloc] init];
    _refreshView.slimeMissWhenGoingBack = YES;
    _refreshView.delegate = self;
    [_tableView addSubview:_refreshView];
    [_refreshView update:20 + self.navigationController.navigationBar.bounds.size.height + _searchBar.bounds.size.height];
    
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight;
    _tableView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0);
    [self.view addSubview:_tableView];
    
    _searchBar.delegate = self;
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_searchBar];
    
    _bottomCell = [[GSBottomLoadingCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:@"BottomCell"];
    [self updateLoadingStatus];
}

- (void)updateLoadingStatus {
    if (_searchKey.length < MIN_LENGTH) {
        _bottomCell.status = GSBottomCellStatusWhite;
    }else if (_loading) {
        _bottomCell.status = GSBottomCellStatusLoading;
    }else {
        if (_hasNext) {
            _bottomCell.status = GSBottomCellStatusHasMore;
        }else  {
            _bottomCell.status = GSBottomCellStatusNoMore;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - search

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    _searchKey = searchBar.text;
    [_searchBar endEditing:YES];
    [self requestDatas];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    _searchKey = nil;
    [_searchBar endEditing:YES];
    _datas = [NSMutableArray array];
    [_tableView reloadData];
    [self updateLoadingStatus];
}

#pragma mark - tableView

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
        if (_hasNext)
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
    [_refreshView update:20 + self.navigationController.navigationBar.bounds.size.height + _searchBar.bounds.size.height];
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_searchBar endEditing:YES];
    [_refreshView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshView scrollViewDidEndDraging];
}

#pragma mark - io


- (void)slimeRefreshStartRefresh:(SRRefreshView*)refreshView {
    [self requestDatas];
}

- (void)requestDatas {
    if (!_searchKey || _searchKey.length < MIN_LENGTH) {
        [_refreshView endRefresh];
        [RKDropdownAlert title:local(Key word is too short)
               backgroundColor:[UIColor orangeColor]
                     textColor:[UIColor whiteColor]];
        return;
    }
    if (_loading) return;
    _loading = YES;
    GSRequestTask *task = [[GSGlobals dataControl] searchRequest:_searchKey
                                                       pageIndex:0];
    task.delegate = self;
    task.tag = 1;
    [self updateLoadingStatus];
}

- (void)requestMore {
    if (!_searchKey || _searchKey.length < MIN_LENGTH) {
        [_refreshView endRefresh];
        [RKDropdownAlert title:local(Key word is too short)
               backgroundColor:[UIColor orangeColor]
                     textColor:[UIColor whiteColor]];
        return;
    }
    if (_loading)
        return;
    NSInteger index = _index + 1;
    GSRequestTask *task = [[GSGlobals dataControl] searchRequest:_searchKey
                                                       pageIndex:index];
    task.delegate = self;
    task.tag = 2;
    _loading = YES;
    [self updateLoadingStatus];
}

- (void)onTaskComplete:(GSRequestTask *)task {
    if (task.tag == 1) {
        _datas = [NSMutableArray<GSBookItem *> arrayWithArray:task.books];
        [_tableView reloadData];
        [_refreshView endRefresh];
        _index = task.index;
        _hasNext = task.hasMore;
    }else if (task.tag == 2) {
        NSArray<GSBookItem *> *arr = task.books;
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
        _index = task.index;
        _hasNext = task.hasMore;
    }
    _loading = NO;
    [self updateLoadingStatus];
}
- (void)onTaskFailed:(GSTask *)task error:(NSError*)error {
    [_refreshView endRefresh];
    if (task.tag == 1) {
        [RKDropdownAlert title:local(Network error)
                       message:error.localizedDescription
               backgroundColor:[UIColor redColor]
                     textColor:[UIColor whiteColor]];
    }else {
        [RKDropdownAlert title:local(Network error)
                       message:error.localizedDescription
               backgroundColor:[UIColor redColor]
                     textColor:[UIColor whiteColor]];
    }
    _loading = NO;
    [self updateLoadingStatus];
}

@end
