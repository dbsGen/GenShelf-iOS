//
//  GSSettingsViewController.m
//  GenShelf
//
//  Created by Gen on 16/2/19.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSSettingsViewController.h"
#import "GSSSSettingViewController.h"
#import "GSideMenuController.h"
#import "GSSwitchCell.h"
#import "GSGlobals.h"

@interface GSSettingsViewController () <UITableViewDelegate, UITableViewDataSource> {
    GSSwitchCell *_adultCell;
}

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation GSSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"设置";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"]
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self.sideMenuController
                                                                                action:@selector(openMenu)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _adultCell = [[GSSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:@"AdultCell"];
    _adultCell.textLabel.text = @"绅士";
    _adultCell.switchItem.on = [GSGlobals isAdult];
    [_adultCell.switchItem addTarget:self
                              action:@selector(toggleAdult:)
                    forControlEvents:UIControlEventValueChanged];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                              style:UITableViewStyleGrouped];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    _tableView = nil;
    _adultCell = nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"设置";
        case 1:
            return @"代理";
            
        default:
            break;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 1;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    return _adultCell;
                    
                default:
                    break;
            }
            break;
        case 1: {
            static NSString *identifier = @"NormalCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:identifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Shadowsocks设置";
                    break;
                    
                default:
                    break;
            }
            return cell;
        }
            
        default:
            break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            
        }
            break;
        case 1:
        {
            
            switch (indexPath.row) {
                case 0:
                    [self.navigationController pushViewController:[[GSSSSettingViewController alloc] init]
                                                         animated:YES];
                    break;
            }
        }
            
        default:
            break;
    }
}

#pragma mark - setting

- (void)toggleAdult:(UISwitch *)sw {
    [GSGlobals setAdult:sw.on];
}

@end
