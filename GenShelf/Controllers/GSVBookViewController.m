//
//  GSVBookViewController.m
//  GenShelf
//
//  Created by Gen on 16/3/1.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSVBookViewController.h"
#import "MTDragFlipView.h"
#import "GSPageViewerView.h"
#import "GSPictureManager.h"
#import "GSPageFlipView.h"

@interface GSVBookViewController () <MTDragFlipViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) MTDragFlipView *flipView;
@property (nonatomic, strong) GSPageViewerView *pageViewer;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation GSVBookViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pageViewer = [[GSPageViewerView alloc] initWithFrame:self.view.bounds];
    
    _flipView = [[MTDragFlipView alloc] initWithFrame:self.view.bounds];
    _flipView.delegate = self;
    _flipView.backgroundColor = [UIColor grayColor];
    _flipView.bottomLabel.text = @"到底了";
    _flipView.topLabel.text = @"到顶了";
    [_flipView reloadData];
    [self.view addSubview:_flipView];
    
    CGRect bounds = self.view.bounds;
    _tableView = [[UITableView alloc] initWithFrame:bounds
                                              style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIView*)flipView:(MTDragFlipView*)flipView subViewAtIndex:(NSInteger)index {
    _pageViewer.image = [UIImage imageWithContentsOfFile:[_item.pages objectAtIndex:index].imagePath];
    return _pageViewer;
}

- (UIView *)flipView:(MTDragFlipView *)flipView backgroudView:(NSInteger)index left:(BOOL)isLeft {
    if (isLeft) {
        return _tableView;
    }
    return nil;
}

- (NSInteger)numberOfFlipViewPage:(MTDragFlipView*)flipView {
    return _item.pages.count;
}

- (MTFlipAnimationView*)flipView:(MTDragFlipView*)flipView dragingView:(NSInteger)index {
    static NSString *identifier = @"DefaultIdentifier";
    GSPageFlipView *view = (GSPageFlipView*)[flipView viewByIndentify:identifier atIndex:index];
    if (!view) {
        view = [[GSPageFlipView alloc] initWithFrame:self.view.bounds];
    }
    [view renderPath:[_item.pages objectAtIndex:index].imagePath
               scale:1
         translation:CGPointMake(0, 0)];
    return view;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

#pragma mark - tableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _item.pages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"RowCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:identifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"第%d页", (int)indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_flipView scrollToPage:indexPath.row animated:YES];
}

@end
