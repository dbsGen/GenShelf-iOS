//
//  GSShelfViewController.m
//  GenShelf
//
//  Created by Gen on 16/2/19.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSShelfViewController.h"
#import "GSideMenuController.h"
#import "GSBookItem.h"
#import "GSBookCell.h"
#import "GCoreDataManager.h"
#import "GSModelNetBook.h"
#import "GSVBookViewController.h"
#import "GSGlobals.h"

@interface GSShelfViewController ()<UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray<GSBookItem *> * _datas;
    UIBarButtonItem *_editItem, *_doneItem;
    CGFloat _oldPosx;
}

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation GSShelfViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = local(Shelf);
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"]
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(openMenu)];
        _editItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                  target:self
                                                                  action:@selector(editBooks)];
        _doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                  target:self
                                                                  action:@selector(editDone)];
        self.navigationItem.rightBarButtonItem = _editItem;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(removeData:)
                                                     name:BOOK_ITEM_REMOVE
                                                   object:nil];
    }
    return self;
}

- (void)removeData:(NSNotification *)notification {
    if ([_datas containsObject:notification.object]) {
        NSInteger index = [_datas indexOfObject:notification.object];
        [_datas removeObjectAtIndex:index];
        [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index
                                                                inSection:0]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSArray *arr = [GSModelNetBook fetch:[NSPredicate predicateWithFormat:@"mark==YES"]
                                   sorts:@[[NSSortDescriptor sortDescriptorWithKey:@"downloadDate"
                                                                         ascending:NO]]];
    _datas = [NSMutableArray<GSBookItem *> arrayWithArray:[GSBookItem items:arr]];
    [_tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                              style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_tableView];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(onPan:)];
    [self.view addGestureRecognizer:pan];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)openMenu {
    [self.sideMenuController openMenu];
}

- (void)editBooks {
    [_tableView setEditing:YES animated:YES];
    self.navigationItem.rightBarButtonItem = _doneItem;
}

- (void)editDone {
    [_tableView setEditing:NO animated:YES];
    self.navigationItem.rightBarButtonItem = _editItem;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 180;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GSBookItem *item = [_datas objectAtIndex:indexPath.row];
    GSVBookViewController *book = [[GSVBookViewController alloc] init];
    book.item = item;
    [self.navigationController pushViewController:book animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:
        {
            GSBookItem *book = [_datas objectAtIndex:indexPath.row];
            [_datas removeObjectAtIndex:indexPath.row];
            [[GSGlobals dataControl] deleteBook:book];
            [_tableView deleteRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        }
            break;
            
        default:
            break;
    }
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
