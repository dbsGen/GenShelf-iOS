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
#import "GSShelfViewController.h"

static NSString *identifier = @"CellIdentifier";

@interface GSPreviewViewController () <UICollectionViewDataSource, UICollectionViewDelegate, SRRefreshDelegate> {
    SRRefreshView *_refreshView;
    GSTask *_currentTask;
    UIBarButtonItem *_collectItem, *_collectedItem;
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
        _collectItem = [[UIBarButtonItem alloc] initWithTitle:local(Collect)
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(onDownload)];
        _collectedItem = [[UIBarButtonItem alloc] initWithTitle:local(Collected)
                                                          style:UIBarButtonItemStyleDone
                                                         target:nil
                                                         action:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BOOK_ITEM_UPDATE
                                                  object:nil];
    [_currentTask taskRelease];
    [_refreshView removeFromSuperview];
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

- (void)setItem:(GSBookItem *)item {
    if (_item != item) {
        _item = item;
        self.title = item.title;
        if (_item.status < GSBookItemStatusComplete) {
            GSTask *task = [GSGlobals processBook:_item];
            [task taskRetain];
            if (_currentTask) {
                [_currentTask taskRelease];
            }
            _currentTask = task;
        }
        self.navigationItem.rightBarButtonItem = _item.mark ? _collectedItem : _collectItem;
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
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
    _collectionView = nil;
    _refreshView = nil;
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
    [GSGlobals downloadBook:_item];
    [self.navigationItem setRightBarButtonItem:_collectedItem animated:YES];
    [GSShelfViewController setReloadCache:YES];
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
    [_item reset];
    if (_currentTask) {
        [_currentTask restart];
    }else {
        GSTask *task = [GSGlobals processBook:_item];
        [task taskRetain];
        _currentTask = task;
    }
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
