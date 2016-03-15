//
//  GSProgressViewController.m
//  GenShelf
//
//  Created by Gen on 16/3/11.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSProgressViewController.h"
#import "GSGlobals.h"
#import "GSProgressCell.h"

@interface GSProgressViewController () <UITableViewDelegate, UITableViewDataSource, GSProgressCellDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation GSProgressViewController {
    NSArray<GSBookItem *> *_datas;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"进程";
        [[GSGlobals dataControl] updateProgressingBooks];
        _datas = [GSGlobals dataControl].progressingBooks;
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(closeMenu)];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(bookComplete:)
                                                     name:BOOK_ITEM_PAGES
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                              style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)closeMenu {
    if (_onClose) {
        _onClose();
    }
}

- (void)bookComplete:(NSNotification *)notification {
    NSInteger index = [[GSGlobals dataControl] removeProgressingBook:notification.object];
    if (index >= 0) {
        [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - tableview

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"ProgressCell";
    GSProgressCell *cell = (GSProgressCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[GSProgressCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:identifier];
        cell.delegate = self;
    }
    cell.data = [_datas objectAtIndex:indexPath.row];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)progressCellResume:(GSProgressCell *)cell {
    [[GSGlobals dataControl] downloadBook:cell.data];
}

- (void)progressCellPause:(GSProgressCell *)cell {
    [[GSGlobals dataControl] pauseBook:cell.data];
}

- (void)progressCellDelete:(GSProgressCell *)cell {
    NSInteger index = [[GSGlobals dataControl] deleteBook:cell.data];
    [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
