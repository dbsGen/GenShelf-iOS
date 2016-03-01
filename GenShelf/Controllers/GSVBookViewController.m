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

@interface GSVBookViewController () <MTDragFlipViewDelegate>

@property (nonatomic, strong) MTDragFlipView *flipView;
@property (nonatomic, strong) GSPageViewerView *pageViewer;

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIView*)flipView:(MTDragFlipView*)flipView subViewAtIndex:(NSInteger)index {
    _pageViewer.image = [UIImage imageWithContentsOfFile:[_item.pages objectAtIndex:index].imagePath];
    return _pageViewer;
}

- (UIView *)flipView:(MTDragFlipView *)flipView backgroudView:(NSInteger)index left:(BOOL)isLeft {
    return nil;
}

- (NSInteger)numberOfFlipViewPage:(MTDragFlipView*)flipView {
    return _item.pages.count;
}

- (MTFlipAnimationView*)flipView:(MTDragFlipView*)flipView dragingView:(NSInteger)index {
    static NSString *identifier = @"DefaultIdentifier";
    GSPageFlipView *view = (GSPageFlipView*)[flipView viewByIndentify:identifier];
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

@end
