//
//  GSPreviewViewController.m
//  GenShelf
//
//  Created by Gen on 16/2/23.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSPreviewViewController.h"
#import "MTMatrixListView.h"
#import "GSThumCell.h"

@interface GSPreviewViewController () <MTMatrixListDelegate>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) MTMatrixListView *matrixView;

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
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, 360)];
    _coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, 360)];
    [_headerView addSubview:_coverImageView];
    
    _matrixView = [[MTMatrixListView alloc] initWithFrame:bounds];
    _matrixView.matrixDelegate = self;
    _matrixView.spaceWidth = 180;
    _matrixView.spaceHeight = 180;
    _matrixView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_matrixView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    _headerView = nil;
    _coverImageView = nil;
    _matrixView = nil;
}


- (NSInteger)numberOfSectionsInMatrixView:(MTMatrixListView*)matrixView {
    return 1;
}

- (MTMatrixViewCell*)matrixView:(MTMatrixListView*)matrixView
                cellOfIndexPath:(NSIndexPath*)indexPath {
    static NSString *identifier = @"NormalCell";
    GSThumCell *cell = [matrixView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[GSThumCell alloc] initWithFrame:CGRectMake(0, 0, 160, 160)
                                 reuseIdentifier:identifier];
    }
    cell.imageUrl = [_item.pages objectAtIndex:indexPath.row].thumUrl;
    return cell;
}

- (NSInteger)matrixView:(MTMatrixListView*)matrixView
        numberOfSection:(NSInteger)section {
    return self.item.pages.count;
}

- (UIView *)matrixView:(MTMatrixListView *)matrixView headerOfSection:(NSInteger)section {
    return _headerView;
}

- (void)onBookUpdate:(NSNotification*)data {
    if (data.object == _item && [data.userInfo objectForKey:@"add"]) {
        NSMutableArray *arr = [NSMutableArray array];
        NSUInteger count = _item.pages.count, total = [[data.userInfo objectForKey:@"add"] count];
        
        for (int n = 0; n < total; n++) {
            [arr addObject:[NSIndexPath indexPathForRow:n + count inSection:0]];
        }
        [_matrixView insertCells:arr withAnimation:YES];
    }
}

@end