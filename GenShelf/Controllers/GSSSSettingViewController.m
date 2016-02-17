//
//  GSSDSettingViewController.m
//  GenShelf
//
//  Created by Gen on 16/2/17.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSSSSettingViewController.h"

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
    static NSString *cellName = @"SDTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = @"本地端口";
            break;
            
            
        default:
            cell.textLabel.text = [NSString stringWithFormat:@"No. %ld", (long)indexPath.row];
            break;
    }
    return cell;
}

@end
