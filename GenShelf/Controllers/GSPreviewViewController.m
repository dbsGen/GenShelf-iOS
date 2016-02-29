//
//  GSPreviewViewController.m
//  GenShelf
//
//  Created by Gen on 16/2/23.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSPreviewViewController.h"
#import "GSThumCell.h"
#import "GShadowView.h"
#import "MTNetCacheManager.h"
#import "GSGlobals.h"
#import "GSRadiusImageView.h"
#import "SRRefreshView.h"

static NSString *identifier = @"CellIdentifier";

@interface GSPreviewViewController () <UICollectionViewDataSource, UICollectionViewDelegate, SRRefreshDelegate> {
    SRRefreshView *_refreshView;
    GSTask *_currentTask;
}

@property (nonatomic, strong) GSRadiusImageView *coverImageView;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

#define kBORDER_WIDTH 18

@implementation GSPreviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onBookUpdate:)
                                                     name:BOOK_ITEM_UPDATE
                                                   object:nil];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下载"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self action:@selector(onDownload)];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BOOK_ITEM_UPDATE
                                                  object:nil];
    [[GSGlobals dataControl].taskQueue releaseTask:_currentTask];
}

- (void)setItem:(GSBookItem *)item {
    if (_item != item) {
        _item = item;
        self.title = item.title;
        GSTask *task = [[GSGlobals dataControl] processBook:_item];
        [[GSGlobals dataControl].taskQueue retainTask:task];
        if (_currentTask) {
            [[GSGlobals dataControl].taskQueue releaseTask:_currentTask];
        }
        _currentTask = task;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect bounds = self.view.bounds;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(kBORDER_WIDTH, kBORDER_WIDTH,
                                           kBORDER_WIDTH, kBORDER_WIDTH);
    layout.minimumLineSpacing = 9;
    layout.itemSize = CGSizeMake(160, 160);
    
    _refreshView = [[SRRefreshView alloc] init];
    _refreshView.slimeMissWhenGoingBack = YES;
    _refreshView.delegate = self;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:bounds collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _collectionView.alwaysBounceVertical = YES;
    [_collectionView registerClass:[GSThumCell class]
        forCellWithReuseIdentifier:identifier];
    [_collectionView addSubview:_refreshView];
    [self.view addSubview:_collectionView];
    
    _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [_refreshView update:20 + self.navigationController.navigationBar.bounds.size.height];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    _coverImageView = nil;
    _collectionView = nil;
}

- (void)onBookUpdate:(NSNotification*)data {
    if (data.object == _item && [data.userInfo objectForKey:@"add"]) {
        NSMutableArray *arr = [NSMutableArray array];
        NSUInteger count = _item.pages.count, total = [[data.userInfo objectForKey:@"add"] count];
        
        for (int n = 0; n < total; n++) {
            [arr addObject:[NSIndexPath indexPathForRow:count-n-1 inSection:0]];
        }
        [_collectionView insertItemsAtIndexPaths:arr];
    }
}

- (void)onDownload {
    [[GSGlobals dataControl] downloadBook:_item];
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
    [_currentTask restart];
    [_item reset];
    [_collectionView reloadData];
    
    [_refreshView performSelector:@selector(endRefresh)
                       withObject:nil
                       afterDelay:2];
//    [self requestDatas];
}

#pragma mark - collection view

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _item.pages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GSThumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.imageUrl = [_item.pages objectAtIndex:indexPath.row].thumUrl;
    return cell;
}

@end
