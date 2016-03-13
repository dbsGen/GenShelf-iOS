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

@interface GSShelfViewController ()<UITableViewDelegate, UITableViewDataSource> {
    NSArray<GSBookItem *> * _datas;
    UIBarButtonItem *_editItem, *_doneItem;
}

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation GSShelfViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"书架";
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
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSArray *arr = [GSModelNetBook fetch:[NSPredicate predicateWithFormat:@"mark==YES"]
                                   sorts:@[[NSSortDescriptor sortDescriptorWithKey:@"downloadDate"
                                                                         ascending:NO]]];
    _datas = [GSBookItem items:arr];
    [_tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                              style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
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

@end
