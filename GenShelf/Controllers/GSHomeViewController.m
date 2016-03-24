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
#import "RKDropdownAlert.h"
#import "GSPreviewViewController.h"
#import "GSBottomLoadingCell.h"

@interface GSHomeViewController () <UITableViewDelegate, UITableViewDataSource, SRRefreshDelegate, GSTaskDelegate>

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
    CGFloat _oldPosx;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = local(Library);
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
    
    _bottomCell = [[GSBottomLoadingCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:@"BottomCell"];
    [self updateLoadingStatus];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(onPan:)];
    [self.view addGestureRecognizer:pan];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    BOOL expire = NO;
    _datas = [NSMutableArray arrayWithArray:[GSBookItem cachedItems:&_index
                                                            hasNext:&_hasNext
                                                             expire:&expire]];
    [_tableView reloadData];
    
    if (_datas.count == 0 || expire) {
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
    GSRequestTask *task = [[GSGlobals dataControl] mainRequest:0];
    task.delegate = self;
    task.tag = 1;
    [self updateLoadingStatus];
}

- (void)requestMore {
    if (_loading)
        return;
    NSInteger index = _index + 1;
    GSRequestTask *task = [[GSGlobals dataControl] mainRequest:index];
    task.delegate = self;
    task.tag = 2;
    _loading = YES;
    [self updateLoadingStatus];
}


- (void)onTaskComplete:(GSRequestTask *)task {
    if (task.tag == 1) {
        _datas = [NSMutableArray<GSBookItem *> arrayWithArray:task.books];
        [_tableView reloadData];
        _loaded = YES;
        [_refreshView endRefresh];
        _index = task.index;
        _hasNext = task.hasMore;
        [GSBookItem cacheItems:_datas page:_index hasNext:_hasNext];
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
        [GSBookItem cacheItems:_datas page:_index hasNext:_hasNext];
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


- (void)onPan:(UIPanGestureRecognizer*)pan {
    switch (pan.state) {
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self.sideMenuController touchEnd];
            break;
        case UIGestureRecognizerStateBegan:
            _oldPosx = [pan translationInView:pan.view].x;
            break;
        default: {
            CGFloat newPosx = [pan translationInView:pan.view].x;
            [self.sideMenuController touchMove:newPosx-_oldPosx];
            _oldPosx = newPosx;
        }
            break;
    }
}

@end
