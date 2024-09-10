//
//  MKCRTabBarController.m
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2024/8/28.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import "MKCRTabBarController.h"

#import "MKMacroDefines.h"
#import "MKBaseNavigationController.h"

#import "MKAlertView.h"

#import "MKCRCentralManager.h"

#import "MKCRNetworkManager.h"

#import "MKCRNetworkController.h"
#import "MKCRScannerViewController.h"
#import "MKCRSettingsController.h"

@interface MKCRTabBarController ()

/// 当触发
/// 01:表示连接成功后，1分钟内没有通过密码验证（未输入密码，或者连续输入密码错误）认为超时，返回结果， 然后断开连接
/// 02:连续十分钟设备没有数据通信断开，返回结果，断开连接
@property (nonatomic, assign)BOOL disconnectType;

@end

@implementation MKCRTabBarController

- (void)dealloc {
    NSLog(@"MKCRTabBarController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [MKCRNetworkManager sharedDealloc];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (![[self.navigationController viewControllers] containsObject:self]){
        [[MKCRCentralManager shared] disconnect];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubPages];
    [self addNotifications];
}

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotoScanPage)
                                                 name:@"mk_cr_popToRootViewControllerNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dfuUpdateComplete)
                                                 name:@"mk_cr_centralDeallocNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(centralManagerStateChanged)
                                                 name:mk_cr_centralManagerStateChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(disconnectTypeNotification:)
                                                 name:mk_cr_deviceDisconnectTypeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceConnectStateChanged)
                                                 name:mk_cr_peripheralConnectStateChangedNotification
                                               object:nil];
}

#pragma mark - notes
- (void)gotoScanPage {
    @weakify(self);
    [self dismissViewControllerAnimated:YES completion:^{
        @strongify(self);
        if ([self.delegate respondsToSelector:@selector(mk_cr_needResetScanDelegate:)]) {
            [self.delegate mk_cr_needResetScanDelegate:NO];
        }
    }];
}

- (void)dfuUpdateComplete {
    @weakify(self);
    [self dismissViewControllerAnimated:YES completion:^{
        @strongify(self);
        if ([self.delegate respondsToSelector:@selector(mk_cr_needResetScanDelegate:)]) {
            [self.delegate mk_cr_needResetScanDelegate:YES];
        }
    }];
}

- (void)disconnectTypeNotification:(NSNotification *)note {
    NSString *type = note.userInfo[@"type"];
    /// 02:连续十分钟设备没有数据通信断开，返回结果，断开连接
    self.disconnectType = YES;
    if ([type isEqualToString:@"02"]) {
        [self showAlertWithMsg:@"No data communication for 10 minutes, the device is disconnected." title:@""];
        return;
    }
    //异常断开
    NSString *msg = [NSString stringWithFormat:@"Device disconnected for unknown reason.(%@)",type];
    [self showAlertWithMsg:msg title:@"Dismiss"];
}

- (void)centralManagerStateChanged{
    if (self.disconnectType) {
        return;
    }
    if ([MKCRCentralManager shared].centralStatus != mk_cr_centralManagerStatusEnable) {
        [self showAlertWithMsg:@"The current system of bluetooth is not available!" title:@"Dismiss"];
    }
}

- (void)deviceConnectStateChanged {
     if (self.disconnectType) {
        return;
    }
    [self showAlertWithMsg:@"The device is disconnected." title:@"Dismiss"];
    return;
}

#pragma mark - private method
- (void)showAlertWithMsg:(NSString *)msg title:(NSString *)title{
    //让setting页面推出的alert消失
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mk_cr_needDismissAlert" object:nil];
    //让所有MKPickView消失
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mk_customUIModule_dismissPickView" object:nil];
    
    @weakify(self);
    MKAlertViewAction *confirmAction = [[MKAlertViewAction alloc] initWithTitle:@"OK" handler:^{
        @strongify(self);
        [self gotoScanPage];
    }];
    MKAlertView *alertView = [[MKAlertView alloc] init];
    [alertView addAction:confirmAction];
    [alertView showAlertWithTitle:title message:msg notificationName:@"mk_cr_needDismissAlert"];
}

- (void)loadSubPages {
    MKCRNetworkController *networkPage = [[MKCRNetworkController alloc] init];
    networkPage.tabBarItem.title = @"Network";
    networkPage.tabBarItem.image = LOADICON(@"MKDeltrtackMQTT", @"MKCRTabBarController", @"cr_networl_tabBarUnselected.png");
    networkPage.tabBarItem.selectedImage = LOADICON(@"MKDeltrtackMQTT", @"MKCRTabBarController", @"cr_networl_tabBarSelected.png");
    MKBaseNavigationController *networkNav = [[MKBaseNavigationController alloc] initWithRootViewController:networkPage];

    MKCRScannerViewController *scannerPage = [[MKCRScannerViewController alloc] init];
    scannerPage.tabBarItem.title = @"Scanner";
    scannerPage.tabBarItem.image = LOADICON(@"MKDeltrtackMQTT", @"MKCRTabBarController", @"cr_scanner_tabBarUnselected.png");
    scannerPage.tabBarItem.selectedImage = LOADICON(@"MKDeltrtackMQTT", @"MKCRTabBarController", @"cr_scanner_tabBarSelected.png");
    MKBaseNavigationController *scannerNav = [[MKBaseNavigationController alloc] initWithRootViewController:scannerPage];

    MKCRSettingsController *settingPage = [[MKCRSettingsController alloc] init];
    settingPage.tabBarItem.title = @"Settings";
    settingPage.tabBarItem.image = LOADICON(@"MKDeltrtackMQTT", @"MKCRTabBarController", @"cr_setting_tabBarUnselected.png");
    settingPage.tabBarItem.selectedImage = LOADICON(@"MKDeltrtackMQTT", @"MKCRTabBarController", @"cr_setting_tabBarSelected.png");
    MKBaseNavigationController *settingNav = [[MKBaseNavigationController alloc] initWithRootViewController:settingPage];
    
    self.viewControllers = @[networkNav,scannerNav,settingNav];
}

@end
