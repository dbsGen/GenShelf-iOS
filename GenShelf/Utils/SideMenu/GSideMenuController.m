//
//  GSideMenuViewController.m
//  GenShelf
//
//  Created by Gen on 16/2/19.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSideMenuController.h"
#import "GSideCoverView.h"
#import "GTween.h"

static NSMutableArray<GSideMenuController*> *_menuControllers;

@interface GSideMenuController ()<UITableViewDelegate, UITableViewDataSource> {
    UITableView *_tableView;
    UIView *_currentView;
    UIView *_contentView;
    GSideCoverView  *_coverView;
}

- (void)updateView;

@end

@implementation GSideMenuController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _selectedIndex = 0;
        _currentView = NULL;
        
        if (!_menuControllers) {
            _menuControllers = [[NSMutableArray alloc] init];
        }
        [_menuControllers addObject:self];
    }
    return self;
}

- (void)dealloc {
    [_menuControllers removeObject:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                              style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    _contentView = [[UIView alloc] initWithFrame:self.view.bounds];
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.layer.shadowColor = [[UIColor blackColor] CGColor];
    _coverView = [[GSideCoverView alloc] initWithFrame:self.view.bounds];
    _coverView.userInteractionEnabled = YES;
    __weak GSideMenuController *that = self;
    _coverView.moveBlock = ^(CGPoint point) {
        [that touchMove:point.x];
    };
    _coverView.endBlock = ^(CGPoint p) {
        [that touchEnd];
    };
    [_contentView addSubview:_coverView];
    [_coverView setHidden:YES];
    [self.view addSubview:_contentView];
    
    [self updateView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    _tableView = NULL;
    _contentView = NULL;
    _currentView = NULL;
    _coverView = NULL;
}

- (void)setControllers:(NSArray *)controllers {
    if (_controllers != controllers) {
        _controllers = controllers;
        if ([self isViewLoaded]) {
            [self updateView];
            [_tableView reloadData];
        }
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (_selectedIndex != selectedIndex) {
        _selectedIndex = selectedIndex;
        [self updateView];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_controllers) {
        return _controllers.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"NormalCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
    }
    NSInteger row = indexPath.row;
    cell.textLabel.text = [[_controllers objectAtIndex:row] title];
    do {
        if (_images && row < _images.count) {
            if ([[_images objectAtIndex:row] isKindOfClass:[UIImage class]]) {
                cell.imageView.image = [_images objectAtIndex:row];
                break;
            }
        }
        cell.imageView.image = NULL;
    } while (false);
    return cell;
}

- (void)updateView {
    if (_selectedIndex >= _controllers.count) _selectedIndex = _controllers.count - 1;
    if (_currentView) {
        if (_controllers && _currentView != [[_controllers objectAtIndex:_selectedIndex] view]) {
            [_currentView removeFromSuperview];
            _currentView = [[_controllers objectAtIndex:_selectedIndex] view];
            [_contentView addSubview:_currentView];
        }
    }else {
        _currentView = [[_controllers objectAtIndex:_selectedIndex] view];
        [_contentView addSubview:_currentView];
    }
}

#define MENU_WIDTH  220
#define MENU_SHADOW_RADIUS 12
#define MENU_SHADOW_OPACITY 0.3

- (void)openMenu {
    [_coverView setHidden:NO];
    [_contentView bringSubviewToFront:_coverView];
    
    [GTween cancel:_contentView];
    GTween *tween = [GTween tween:_contentView
                         duration:0.4
                             ease:[GEaseCubicOut class]];
    CGRect bounds = self.view.bounds;
    [tween addProperty:[GTweenCGRectProperty property:@"frame"
                                                 from:_contentView.frame
                                                   to:CGRectMake(MENU_WIDTH, 0,
                                                                 bounds.size.width,
                                                                 bounds.size.height)]];
    [tween start];
    
    _contentView.layer.shadowRadius = MENU_SHADOW_RADIUS;
    _contentView.layer.shadowOpacity = MENU_SHADOW_OPACITY;
}

- (void)closeMenu {
    [_coverView setHidden:YES];
    
    [GTween cancel:_contentView];
    GTween *tween = [GTween tween:_contentView
                         duration:0.4
                             ease:[GEaseCubicOut class]];
    CGRect bounds = self.view.bounds;
    [tween addProperty:[GTweenCGRectProperty property:@"frame"
                                                 from:_contentView.frame
                                                   to:CGRectMake(0, 0,
                                                                 bounds.size.width,
                                                                 bounds.size.height)]];
    [tween start];
    [tween.onComplete addBlock:^{
        _contentView.layer.shadowRadius = 0;
        _contentView.layer.shadowOpacity = 0;
    }];
}

- (void)touchMove:(CGFloat)offset {
    CGRect frame = _contentView.frame;
    frame.origin.x = MIN(MAX(0, frame.origin.x + offset), MENU_WIDTH);
    _contentView.frame = frame;
}

- (void)touchEnd {
    CGRect frame = _contentView.frame;
    if (frame.origin.x > MENU_WIDTH/2) {
        [self openMenu];
    }else {
        [self closeMenu];
    }
}

@end

@implementation UIViewController (GSideMenuController)

- (GSideMenuController *)sideMenuController {
    if (_menuControllers) {
        for (GSideMenuController *ctr in _menuControllers) {
            if ([ctr.controllers containsObject:self]) {
                return ctr;
            }
        }
    }
    return NULL;
}

@end
