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
#import "GSSelectCell.h"

@interface GSSettingsViewController () <UITableViewDelegate, UITableViewDataSource, GSSelectCellDelegate> {
    GSSwitchCell *_adultCell;
    NSUInteger _dataControlIndex;
    CGFloat _oldPosx;
}

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation GSSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = local(Settings);
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"]
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self.sideMenuController
                                                                                action:@selector(openMenu)];
        _dataControlIndex = [[GSGlobals dataControlNames] indexOfObject:[GSGlobals selectedDataControl]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _adultCell = [[GSSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:@"AdultCell"];
    _adultCell.textLabel.text = local(Adult);
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
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(onPan:)];
    [self.view addGestureRecognizer:pan];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    _tableView = nil;
    _adultCell = nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return local(Proxy);
        case 1:
            return local(Source);
        case 2:
            return local(Source Settings);
            
        default:
            break;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return [GSGlobals dataControlNames].count;
        case 2:
            return [GSGlobals dataControl].properties.count;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            static NSString *identifier = @"NormalCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:identifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = local(Shadowsocks settings);
                    break;
                    
                default:
                    break;
            }
            return cell;
        }
        case 1: {
            static NSString *identifier = @"CheckCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:identifier];
            }
            NSInteger row = indexPath.row;
            cell.textLabel.text = [[GSGlobals dataControlNames] objectAtIndex:row];
            cell.accessoryType = _dataControlIndex == row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            return cell;
        }
        case 2: {
            NSUInteger row = indexPath.row;
            GSDataProperty *setting = [[GSGlobals dataControl].properties objectAtIndex:row];
            switch (setting.type) {
                case GSDataPropertyTypeBOOL: {
                    static NSString *identifier = @"SwitchCell";
                    GSSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
                    if (!cell) {
                        cell = [[GSSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:identifier];
                        [cell.switchItem addTarget:self
                                            action:@selector(onSettingSwitch:)
                                  forControlEvents:UIControlEventValueChanged];
                    }
                    cell.textLabel.text = NSLocalizedString(setting.name, @"");
                    cell.switchItem.on = [[[GSGlobals dataControl] getProperty:setting.name] boolValue];
                    cell.switchItem.tag = row;
                    return cell;
                }
                    
                    break;
                case GSDataPropertyTypeOptions: {
                    static NSString *identifier = @"OptionsCell";
                    GSSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
                    if (!cell) {
                        cell = [[GSSelectCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:identifier];
                        cell.delegate = self;
                    }
                    NSInteger selectIndex = [[[GSGlobals dataControl] getProperty:setting.name] integerValue];
                    cell.opetionSelected = selectIndex;
                    cell.options = setting.custmorData;
                    cell.textLabel.text = NSLocalizedString(setting.name, @"");
                    cell.tag = indexPath.row;
                    return cell;
                }
                    break;
                    
                default: {
                    static NSString *identifier = @"UnkownCell";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
                    if (!cell) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                      reuseIdentifier:identifier];
                    }
                    cell.textLabel.text = local(Unkown);
                    return cell;
                }
                    break;
            }
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
            
            switch (indexPath.row) {
                case 0:
                    [self.navigationController pushViewController:[[GSSSSettingViewController alloc] init]
                                                         animated:YES];
                    break;
            }
        }
            break;
        case 1:
        {
            NSUInteger old = _dataControlIndex;
            _dataControlIndex = indexPath.row;
            [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:old inSection:1], [NSIndexPath indexPathForRow:_dataControlIndex inSection:1]]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            
            NSString *name = [[GSGlobals dataControlNames] objectAtIndex:_dataControlIndex];
            [GSGlobals setSelectedDataControl:name];
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:2]
                     withRowAnimation:UITableViewRowAnimationAutomatic];
        }
            break;
        case 2:
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if ([cell isKindOfClass:[GSSelectCell class]]) {
                GSSelectCell *selectCell = (GSSelectCell*)cell;
                GSSelectView *pickerView = [selectCell makePickView];
                [self.view addSubview:pickerView];
                [pickerView show];
                [self.view endEditing:YES];
            }
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

#pragma mark - setting

- (void)toggleAdult:(UISwitch *)sw {
    [GSGlobals setAdult:sw.on];
}

- (void)onSettingSwitch:(UISwitch *)sw {
    GSDataProperty *setting = [[GSGlobals dataControl].properties objectAtIndex:sw.tag];
    [[GSGlobals dataControl] setProperty:[NSNumber numberWithBool:sw.on]
                                withName:setting.name];
}

- (void)selectCellChanged:(GSSelectCell *)cell {
    GSDataProperty *setting = [[GSGlobals dataControl].properties objectAtIndex:cell.tag];
    [[GSGlobals dataControl] setProperty:[NSNumber numberWithInteger:cell.opetionSelected]
                                withName:setting.name];
}

@end
