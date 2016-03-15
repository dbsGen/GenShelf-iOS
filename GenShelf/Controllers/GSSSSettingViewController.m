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
#import "GSSwitchCell.h"
#import "GSLoadingCell.h"
#import "GSGlobals.h"
#import "ShadowsocksRunner.h"
#import "GTween.h"
#import "ASIHTTPRequest.h"
#import "GSScannerViewController.h"
#import "MBLMessageBanner.h"

@interface GSSSSettingViewController () {
    GSSwitchCell *_toggleProxyCell;
    GSInputCell *_currentPortCell;
    UITableViewCell *_scanQRCodeCell;
    GSInputCell *_serverIpCell;
    GSInputCell *_serverPortCell;
    GSInputCell *_passwordCell;
    GSSelectCell *_encryptionTypeCell;
    GSLoadingCell *_testCell;
}

@end

@implementation GSSSSettingViewController

@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"设置";
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                    target:self
                                                                                    action:@selector(saveClicked)];
        self.navigationItem.rightBarButtonItem = saveButton;
    }
    return self;
}

- (void)viewDidLoad {
    _toggleProxyCell = [[GSSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:@"ToggleProxy"];
    _toggleProxyCell.textLabel.text = @"开启代理";
    [_toggleProxyCell.switchItem addTarget:self
                                action:@selector(toggleProxy:)
                      forControlEvents:UIControlEventValueChanged];
    
    _currentPortCell = [[GSInputCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"CurrentPort"];
    _currentPortCell.textLabel.text = @"本地端口";
    _currentPortCell.inputView.placeholder = @"Port";
    
    _scanQRCodeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:@"ScanQRCode"];
    _scanQRCodeCell.textLabel.text = @"扫描二维码";
    _scanQRCodeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    _serverIpCell = [[GSInputCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:@"ServerIP"];
    _serverIpCell.textLabel.text = @"服务器地址";
    _serverIpCell.inputView.placeholder = @"IP";
    
    _serverPortCell = [[GSInputCell alloc] initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:@"ServerPort"];
    _serverPortCell.textLabel.text = @"服务器端口";
    _serverPortCell.inputView.placeholder = @"Port";
    
    _passwordCell = [[GSInputCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:@"Password"];
    _passwordCell.textLabel.text = @"密码";
    _passwordCell.inputView.placeholder = @"Password";
    
    _encryptionTypeCell = [[GSSelectCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:@"EncrytionType"];
    _encryptionTypeCell.textLabel.text = @"加密类型";
    
    _testCell = [[GSLoadingCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:@"TestCell"];
    _testCell.textLabel.text = @"测试";
    [self updateSettings];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                  style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    _tableView = NULL;
    _currentPortCell = NULL;
    _serverIpCell = NULL;
    _serverPortCell = NULL;
    _passwordCell = NULL;
    _encryptionTypeCell = NULL;
    _toggleProxyCell = NULL;
    _testCell = NULL;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)updateSettings {
    _toggleProxyCell.switchItem.on = [GSGlobals isProxyOn];
    _currentPortCell.inputView.text = [GSGlobals currentPort];
    _serverIpCell.inputView.text = [GSGlobals serverIP];
    _serverPortCell.inputView.text = [GSGlobals serverPort];
    _passwordCell.inputView.text = [GSGlobals password];
    _encryptionTypeCell.options = [GSGlobals encryptionTypes];
    _encryptionTypeCell.opetionSelected = [_encryptionTypeCell.options indexOfObject:[GSGlobals encryptionType]];
}

- (void)saveClicked {
    [GSGlobals setServerIP:_serverIpCell.inputView.text];
    [GSGlobals setServerPort:_serverPortCell.inputView.text];
    [GSGlobals setPassword:_passwordCell.inputView.text];
    [GSGlobals setEncryptionType:_encryptionTypeCell.contentLabel.text];
    if (![_currentPortCell.inputView.text isEqualToString:[GSGlobals currentPort]]) {
        [GSGlobals setCurrentPort:_currentPortCell.inputView.text];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [GSGlobals resetShadowsocks];
    }else {
        [[NSUserDefaults standardUserDefaults] synchronize];
        [GSGlobals reloadShadowsocksConfig];
    }
}

- (void)toggleProxy:(UISwitch*)sender {
    [GSGlobals turnProxy:sender.isOn];
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
        case 1:
            return 1;
        case 2:
            return 5;
        case 3:
            return 1;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return _toggleProxyCell;
            
        case 1:
        {
            return _currentPortCell;
        }
            break;
        case 2: {
            switch (indexPath.row) {
                case 0: {
                    return _scanQRCodeCell;
                }
                case 1: {
                    return _serverIpCell;
                }
                case 2: {
                    return _serverPortCell;
                }
                case 3: {
                    return _passwordCell;
                }
                case 4: {
                    return _encryptionTypeCell;
                }
                    
                default:
                    break;
            }
        }
        case 3:
            return _testCell;
            
        default:
            break;
    }
    return NULL;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = indexPath.row;
    NSUInteger section = indexPath.section;
    if (section == 2) {
        if (row == 0) {
            GSScannerViewController *con = [[GSScannerViewController alloc] init];
            con.block = ^(NSString *res) {
                [MBLMessageBanner showMessageBannerInViewController:self
                                                              title:@"是否使用这个服务器?"
                                                           subtitle:res
                                                              image:nil
                                                               type:MBLMessageBannerTypeMessage
                                                           duration:5
                                             userDissmissedCallback:nil
                                                        buttonTitle:@"使用"
                                          userPressedButtonCallback:^(MBLMessageBannerView *banner) {
                                              [ShadowsocksRunner openSSURL:[NSURL URLWithString:res]];
                                              [self updateSettings];
                                          }
                                                         atPosition:MBLMessageBannerPositionBottom
                                               canBeDismissedByUser:YES
                                                           delegate:nil];
            };
            [self.navigationController pushViewController:con animated:YES];
        }else if (row == 4) {
            GSSelectView *pickerView = [_encryptionTypeCell makePickView];
            [self.view addSubview:pickerView];
            [pickerView show];
            [self.view endEditing:YES];
        }
    }else if (section == 3) {
        NSURL *testUrl = [NSURL URLWithString:@"http://lofi.e-hentai.org/"];
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:testUrl];
        if ([GSGlobals isProxyOn]) {
            request.proxyHost = @"127.0.0.1";
            request.proxyPort = [[GSGlobals currentPort] intValue];
            request.proxyType = (__bridge NSString *)(kCFProxyTypeSOCKS);
        }
        __weak ASIHTTPRequest *_request = request;
        [request setCompletionBlock:^{
            _testCell.status = GSLoadingCellStatusSuccess;
            NSLog(@"Request complete : %@", _request.responseString);
        }];
        [request setFailedBlock:^{
            _testCell.status = GSLoadingCellStatusFailed;
            NSLog(@"Request failed. %@", _request.error);
        }];
        [request startAsynchronous];
        _testCell.status = GSLoadingCellStatusLoading;
    }
}

@end
