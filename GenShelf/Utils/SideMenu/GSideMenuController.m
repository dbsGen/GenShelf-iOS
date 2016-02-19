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


#define MENU_WIDTH  220
#define MENU_SHADOW_RADIUS 12
#define MENU_SHADOW_OPACITY 0.3

static NSMutableArray<GSideMenuController*> *_menuControllers;

@implementation GSideMenuItem

+ (id)itemWithController:(UIViewController *)controller {
    GSideMenuItem *item = [[GSideMenuItem alloc] init];
    item.controller = controller;
    item.title = controller.title;
    return item;
}

+ (id)itemWithController:(UIViewController *)controller image:(UIImage *)image {
    GSideMenuItem *item = [[GSideMenuItem alloc] init];
    item.controller = controller;
    item.title = controller.title;
    item.image = image;
    return item;
}

+ (id)itemWithTitle:(NSString *)title block:(GSideMenuItemBlock)block {
    GSideMenuItem *item = [[GSideMenuItem alloc] init];
    item.title = title;
    item.block = block;
    return item;
}

+ (id)itemWithTitle:(NSString *)title image:(UIImage *)image block:(GSideMenuItemBlock)block {
    GSideMenuItem *item = [[GSideMenuItem alloc] init];
    item.title = title;
    item.image = image;
    item.block = block;
    return item;
}

@end

@interface GSideMenuController ()<UITableViewDelegate, UITableViewDataSource> {
    UITableView *_tableView;
    UIView *_currentView;
    UIView *_contentView;
    GSideCoverView  *_coverView;
    BOOL _isOpen;
}

- (void)updateView;

@end

@implementation GSideMenuController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _selectedIndex = 0;
        _currentView = NULL;
        _isOpen = NO;
        
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
    
    CGRect bounds = self.view.bounds;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MENU_WIDTH,
                                                               bounds.size.height)
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

- (void)setItems:(NSArray<GSideMenuItem *> *)items {
    if (_items != items) {
        _items = items;
        if ([self isViewLoaded]) {
            [self updateView];
            [_tableView reloadData];
        }
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (_selectedIndex != selectedIndex) {
        GSideMenuItem *item = [_items objectAtIndex:selectedIndex];
        if (item.controller) {
            NSUInteger uidx = _selectedIndex;
            _selectedIndex = selectedIndex;
            [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:uidx
                                                                    inSection:0],
                                                 [NSIndexPath indexPathForRow:_selectedIndex
                                                                    inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
            [self updateView];
        }else if (item.block){
            item.block();
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_items) {
        return _items.count;
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
    GSideMenuItem *item = [_items objectAtIndex:row];
    cell.textLabel.text = item.title;
    cell.imageView.image = item.image;
    if (row == _selectedIndex) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath.row;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell)
        [cell setSelected:NO animated:YES];
}

- (void)updateView {
    if (_selectedIndex >= _items.count) _selectedIndex = _items.count - 1;
    if (_currentView) {
        [_currentView removeFromSuperview];
        GSideMenuItem *item = [_items objectAtIndex:_selectedIndex];
        if (item.controller) {
            _currentView = [item.controller view];
            [_contentView addSubview:_currentView];
        }
    }else {
        GSideMenuItem *item = [_items objectAtIndex:_selectedIndex];
        if (item.controller) {
            _currentView = [item.controller view];
            [_contentView addSubview:_currentView];
        }
    }
}

- (void)openMenu {
    _isOpen = YES;
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
    _isOpen = NO;
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
    [tween.onUpdate addBlock:^{
        [self updateTableScale];
    }];
}

- (void)touchMove:(CGFloat)offset {
    CGRect frame = _contentView.frame;
    frame.origin.x = MIN(MAX(0, frame.origin.x + offset), MENU_WIDTH);
    [self updateTableScale];
    _contentView.frame = frame;
}

- (void)updateTableScale {
    float p = _contentView.frame.origin.x / MENU_WIDTH;
    p = p * 0.3 + 0.7;
    _tableView.layer.transform = CATransform3DMakeScale(p, p, p);
}

- (void)touchEnd {
    CGRect frame = _contentView.frame;
    if (_isOpen) {
        if (frame.origin.x < MENU_WIDTH*3.0/4.0) {
            [self closeMenu];
        }else {
            [self openMenu];
        }
    }else {
        if (frame.origin.x > MENU_WIDTH/4) {
            [self openMenu];
        }else {
            [self closeMenu];
        }
    }
}

@end

@implementation UIViewController (GSideMenuController)

- (GSideMenuController *)sideMenuController {
    if (_menuControllers) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"controller == %@", self];
        for (GSideMenuController *ctr in _menuControllers) {
            if ([ctr.items filteredArrayUsingPredicate:predicate].count > 0) {
                return ctr;
            }
        }
    }
    return NULL;
}

@end
