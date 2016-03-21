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

@interface GSVBookViewController () <MTDragFlipViewDelegate, UITableViewDelegate, UITableViewDataSource> {
    NSInteger   _oldIndex;
}

@property (nonatomic, strong) MTDragFlipView *flipView;
@property (nonatomic, strong) GSPageViewerView *pageViewer;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation GSVBookViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(pageComplete:)
                                                     name:PAGE_ITEM_SET_IMAGE
                                                   object:nil];
        _oldIndex = 0;
    }
    return self;
}

- (void)dealloc {
    _flipView.delegate = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pageViewer = [[GSPageViewerView alloc] initWithFrame:self.view.bounds];
    __weak GSVBookViewController *this = self;
    _pageViewer.onUpdate = ^(GSPageViewerView *view) {
        if (this.flipView) {
            GSPageFlipView *v = (GSPageFlipView*)[this.flipView getDragingView:this.flipView.pageIndex];
            if (v) {
                [v clean];
                CGRect frame = view.imageView.frame;
                frame.size.width/=2;
                frame.size.height/=2;
                frame.origin.x/=2;
                frame.origin.y/=2;
                frame.origin.y = -((frame.size.height - v.imageSize.height)+frame.origin.y);
                
//                [v renderImage:view.image
//                         frame:frame];
                [v renderImage:view.image
                         scale:view.scale
                   translation:view.translation];
            }
        }
    };
    _pageViewer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _flipView = [[MTDragFlipView alloc] initWithFrame:self.view.bounds];
    _flipView.delegate = self;
    _flipView.backgroundColor = [UIColor grayColor];
    _flipView.bottomLabel.text = local(No next);
    _flipView.topLabel.text = local(No prev);
    _flipView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_flipView reloadData];
    [self.view addSubview:_flipView];
    
    CGRect bounds = self.view.bounds;
    _tableView = [[UITableView alloc] initWithFrame:bounds
                                              style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 30, 40, 40)];
    [button setImage:[UIImage imageNamed:@"back"]
            forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(backClicked)
     forControlEvents:UIControlEventTouchUpInside];
    button.layer.shadowColor = [UIColor whiteColor].CGColor;
    button.layer.shadowOpacity = 1;
    button.layer.shadowRadius = 2;
    button.layer.shadowOffset = CGSizeMake(0, 0);
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIView*)flipView:(MTDragFlipView*)flipView subViewAtIndex:(NSInteger)index {
    GSPageFlipView *view = (GSPageFlipView*)[flipView getDragingView:index];
    _pageViewer.scale = view ? view.scale : 1;
    _pageViewer.translation = view ? view.translation : CGPointMake(0, 0);
    _pageViewer.imagePath = [_item.pages objectAtIndex:index].imagePath;
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:MAX(0, index - 4)
                                                          inSection:0]
                      atScrollPosition:UITableViewScrollPositionTop
                              animated:YES];
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_oldIndex
                                                            inSection:0],
                                         [NSIndexPath indexPathForRow:index
                                                            inSection:0]]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
    _oldIndex = index;
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

//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
//}
//
//- (BOOL)shouldAutorotate {
//    return YES;
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return UIInterfaceOrientationPortrait;
//}

- (void)backClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pageComplete:(NSNotification *)notification {
    NSArray *pages = [_item.pages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"model == %@", [notification.object model]]];
    if (pages.count) {
        GSPageItem *currentPage = [pages firstObject];
        GSPageItem *page = [_item.pages objectAtIndex:_flipView.pageIndex];
        if ([currentPage.pageUrl isEqualToString:page.pageUrl]) {
            _pageViewer.imagePath = page.imagePath;
        }
        
        NSInteger index = [_item.pages indexOfObject:currentPage];
        GSPageFlipView *view = (GSPageFlipView*)[_flipView imageViewWithIndex:index];
        if (view) {
            [view renderPath:[notification.object imagePath]
                       scale:1 translation:CGPointMake(0, 0)];
        }
    }
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
    cell.textLabel.text = [NSString stringWithFormat:local(Page N), (int)indexPath.row];
    if (indexPath.row == _flipView.pageIndex) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor grayColor];
    }else {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_flipView scrollToPage:indexPath.row animated:YES];
}

@end
