//
//  MKCRNetworkController.m
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2024/8/28.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import "MKCRNetworkController.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"

#import "MKHudManager.h"
#import "MKNormalTextCell.h"
#import "MKCustomUIAdopter.h"

#import "MKCRConnectManager.h"
#import "MKCRNetworkManager.h"

#import "MKCRInterface+MKCRConfig.h"

#import "MKCRNetworkModel.h"

#import "MKCRNetworkSettingsController.h"
#import "MKCRServerForDeviceController.h"

@interface MKCRNetworkController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)MKCRNetworkModel *dataModel;

@end

@implementation MKCRNetworkController

- (void)dealloc {
    NSLog(@"MKCRNetworkController销毁");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadSections];
}

#pragma mark - super method
- (void)leftButtonMethod {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mk_cr_popToRootViewControllerNotification" object:nil];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        //Network Settings
        MKCRNetworkSettingsController *vc = [[MKCRNetworkSettingsController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if (indexPath.row == 1) {
        //MQTT Settings
        MKCRServerForDeviceController *vc = [[MKCRServerForDeviceController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKNormalTextCell *cell = [MKNormalTextCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - event method
- (void)connectButtonPressed {
    if (![MKCRNetworkManager shared].networkSettings) {
        [self.view showCentralToast:@"Please configure network first"];
        return;
    }
    if (![MKCRNetworkManager shared].mqttSettings) {
        [self.view showCentralToast:@"Please configure mqtt first"];
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKCRInterface cr_enterSTAModeWithSucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"The gateway is connecting network and cloud now, Bluetooth will disconnect"];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - loadSections
- (void)loadSections {
    MKNormalTextCellModel *cellModel1 = [[MKNormalTextCellModel alloc] init];
    cellModel1.showRightIcon = YES;
    cellModel1.leftMsg = @"Network Settings";
    [self.dataList addObject:cellModel1];
    
    MKNormalTextCellModel *cellModel2 = [[MKNormalTextCellModel alloc] init];
    cellModel2.showRightIcon = YES;
    cellModel2.leftMsg = @"MQTT Settings";
    [self.dataList addObject:cellModel2];
    
    [self.tableView reloadData];
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = [MKCRConnectManager shared].deviceName;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom).mas_offset(-49.f);
    }];
}

#pragma mark - getter
- (MKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.tableFooterView = [self footerView];
    }
    return _tableView;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (MKCRNetworkModel *)dataModel {
    if (!_dataModel) {
        _dataModel = [[MKCRNetworkModel alloc] init];
    }
    return _dataModel;
}

- (UIView *)footerView {
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, 300.f)];
    
    UIButton *connectButton = [MKCustomUIAdopter customButtonWithTitle:@"Connect"
                                                                target:self
                                                                action:@selector(connectButtonPressed)];
    connectButton.frame = CGRectMake((kViewWidth - 100.f) / 2, 20.f, 100.f, 35.5);
    [footView addSubview:connectButton];
    
    return footView;
}

@end
