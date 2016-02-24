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

static NSString *identifier = @"CellIdentifier";

@interface GSPreviewViewController () <UICollectionViewDataSource, UICollectionViewDelegate, ASIHTTPRequestDelegate>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) GSRadiusImageView *coverImageView;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation GSPreviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onBookUpdate:)
                                                     name:BOOK_ITEM_UPDATE
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BOOK_ITEM_UPDATE
                                                  object:nil];
}

- (void)setItem:(GSBookItem *)item {
    _item = item;
    self.title = item.title;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect bounds = self.view.bounds;
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, 280)];
    _coverImageView = [[GSRadiusImageView alloc] initWithFrame:CGRectMake(40, 60, 160, 160)];
    _coverImageView.image = [UIImage imageNamed:@"no_image"];
    [[MTNetCacheManager defaultManager] getImageWithUrl:_item.imageUrl
                                                  block:^(id result) {
                                                      if (result) {
                                                          _coverImageView.image = result;
                                                      }else {
                                                          ASIHTTPRequest *request = [GSGlobals requestForURL:[NSURL URLWithString:_item.imageUrl]];
                                                          request.userInfo = @{@"url": _item.imageUrl};
                                                          request.delegate = self;
                                                          [request startAsynchronous];
                                                      }
                                                  }];
    GShadowView *shadowView = [[GShadowView alloc] initWithFrame:CGRectMake(0, 280, bounds.size.width, 12)];
    shadowView.status = GShadowViewTB;
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_headerView addSubview:shadowView];
    [_headerView addSubview:_coverImageView];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(298, 18, 18, 18);
    layout.minimumLineSpacing = 9;
    layout.itemSize = CGSizeMake(160, 160);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:bounds collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_collectionView registerClass:[GSThumCell class]
        forCellWithReuseIdentifier:identifier];
    [_collectionView addSubview:_headerView];
    [self.view addSubview:_collectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    _headerView = nil;
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

#pragma mark - request

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSData *data = request.responseData;
    [[MTNetCacheManager defaultManager] setData:data
                                        withUrl:[request.userInfo objectForKey:@"url"]];
    _coverImageView.image = [UIImage imageWithData:request.responseData];
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
