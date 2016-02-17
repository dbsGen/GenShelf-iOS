//
//  GSSDSettingViewController.m
//  GenShelf
//
//  Created by Gen on 16/2/17.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSSSSettingViewController.h"
#import "GSInputCell.h"
#import "GSSelectCell.h"

@interface GSSSSettingViewController ()

- (GSSelectCell *)selectCell:(UITableView*)tableView;
- (GSInputCell *)inputCell:(UITableView*)tableView;

@end

@implementation GSSSSettingViewController

@synthesize tableView = _tableView;

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor redColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectInset(self.view.bounds, 20, 20)
                                                  style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    _tableView = NULL;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 3;
            
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            GSInputCell *cell = [self inputCell:tableView];
            cell.textLabel.text = @"本地端口";
            cell.inputView.placeholder = @"IP";
            return cell;
        }
            break;
        case 1: {
            switch (indexPath.row) {
                case 0:
                    break;
                    
                default:
                    break;
            }
        }
            
        default:
            break;
    }
    return NULL;
}

- (GSSelectCell *)selectCell:(UITableView*)tableView {
    
    static NSString *selectCell = @"SDSelectCell";
    GSSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:selectCell];
    if (!cell) {
        cell = [[GSSelectCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:selectCell];
    }
    return cell;
}

- (GSInputCell *)inputCell:(UITableView *)tableView {
    
    static NSString *inputCell = @"SDInputCell";
    GSInputCell *cell = [tableView dequeueReusableCellWithIdentifier:inputCell];
    if (!cell) {
        cell = [[GSInputCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:inputCell];
    }
    return cell;
}

@end
