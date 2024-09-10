//
//  MKCRNetworkSettingsController.m
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2024/9/1.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import "MKCRNetworkSettingsController.h"

#import "Masonry.h"

#import "MLInputDodger.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"
#import "UITableView+MKAdd.h"
#import "NSString+MKAdd.h"

#import "MKTableSectionLineHeader.h"

#import "MKHudManager.h"
#import "MKTextButtonCell.h"
#import "MKTextFieldCell.h"
#import "MKTextSwitchCell.h"

#import "MKCRNetworkManager.h"

#import "MKCRNetworkSettingsModel.h"

#include "MKCRNetworkSsidSettingsCell.h"

#import "MKCRNearbyWifiController.h"

@interface MKCRNetworkSettingsController ()<UITableViewDelegate,
UITableViewDataSource,
MKTextButtonCellDelegate,
MKTextFieldCellDelegate,
mk_textSwitchCellDelegate,
MKCRNetworkSsidSettingsCellDelegate,
MKCRNearbyWifiControllerDelegate>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *section0List;

@property (nonatomic, strong)NSMutableArray *section1List;

@property (nonatomic, strong)NSMutableArray *section2List;

@property (nonatomic, strong)NSMutableArray *section3List;

@property (nonatomic, strong)NSMutableArray *section4List;

@property (nonatomic, strong)NSMutableArray *section5List;

@property (nonatomic, strong)NSMutableArray *section6List;

@property (nonatomic, strong)NSMutableArray *section7List;

@property (nonatomic, strong)NSMutableArray *headerList;

@property (nonatomic, strong)MKCRNetworkSettingsModel *dataModel;

@end

@implementation MKCRNetworkSettingsController

- (void)dealloc {
    NSLog(@"MKCRNetworkSettingsController销毁");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.view.shiftHeightAsDodgeViewForMLInputDodger = 50.0f;
    [self.view registerAsDodgeViewForMLInputDodgerWithOriginalY:self.view.frame.origin.y];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self readDatasFromDevice];
}

#pragma mark - super method
- (void)rightButtonMethod {
    [self saveDataToDevice];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.dataModel.netType == 3 || self.dataModel.netType == 4) {
        //3:ETH_WIFI    4:ETH_WIFI_CELLULAR
        if (section == 1 || section == 3) {
            return 25.f;
        }
    }
    if (self.dataModel.netType == 4 && section == 7) {
        return 25.f;
    }
    
    return 0.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MKTableSectionLineHeader *headerView = [MKTableSectionLineHeader initHeaderViewWithTableView:tableView];
    headerView.headerModel = self.headerList[section];
    return headerView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.headerList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self cellForRowAtIndexPath:indexPath];
}

#pragma mark - MKTextButtonCellDelegate
/// 右侧按钮点击触发的回调事件
/// @param index 当前cell所在的index
/// @param dataListIndex 点击按钮选中的dataList里面的index
/// @param value dataList[dataListIndex]
- (void)mk_loraTextButtonCellSelected:(NSInteger)index
                        dataListIndex:(NSInteger)dataListIndex
                                value:(NSString *)value {
    if (index == 0) {
        //Type
        self.dataModel.netType = dataListIndex;
        MKTextButtonCellModel *cellModel = self.section0List[0];
        cellModel.dataListIndex = dataListIndex;
        [self.tableView reloadData];
        return;
    }
}

#pragma mark - mk_textSwitchCellDelegate
/// 开关状态发生改变了
/// @param isOn 当前开关状态
/// @param index 当前cell所在的index
- (void)mk_textSwitchCellStatusChanged:(BOOL)isOn index:(NSInteger)index {
    if (index == 0) {
        //Ethernet DHCP
        self.dataModel.ethernet_dhcp = isOn;
        MKTextSwitchCellModel *cellModel = self.section1List[0];
        cellModel.isOn = isOn;
        [self.tableView mk_reloadSection:2 withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    if (index == 1) {
        //Wifi DHCP
        self.dataModel.wifi_dhcp = isOn;
        MKTextSwitchCellModel *cellModel = self.section5List[0];
        cellModel.isOn = isOn;
        [self.tableView mk_reloadSection:6 withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
}

#pragma mark - MKTextFieldCellDelegate
/// textField内容发送改变时的回调事件
/// @param index 当前cell所在的index
/// @param value 当前textField的值
- (void)mk_deviceTextCellValueChanged:(NSInteger)index textValue:(NSString *)value {
    if (index == 0) {
        //Ethernet IP
        self.dataModel.ethernet_ip = value;
        MKTextFieldCellModel *cellModel = self.section2List[0];
        cellModel.textFieldValue = value;
        return;
    }
    if (index == 1) {
        //Mask
        self.dataModel.ethernet_mask = value;
        MKTextFieldCellModel *cellModel = self.section2List[1];
        cellModel.textFieldValue = value;
        return;
    }
    if (index == 2) {
        //Gateway
        self.dataModel.ethernet_gateway = value;
        MKTextFieldCellModel *cellModel = self.section2List[2];
        cellModel.textFieldValue = value;
        return;
    }
    if (index == 3) {
        //DNS
        self.dataModel.ethernet_dns = value;
        MKTextFieldCellModel *cellModel = self.section2List[3];
        cellModel.textFieldValue = value;
        return;
    }
    if (index == 4) {
        //WIFI Password
        self.dataModel.wifi_psd = value;
        MKTextFieldCellModel *cellModel = self.section4List[0];
        cellModel.textFieldValue = value;
        return;
    }
    if (index == 5) {
        //Wifi IP
        self.dataModel.wifi_ip = value;
        MKTextFieldCellModel *cellModel = self.section6List[0];
        cellModel.textFieldValue = value;
        return;
    }
    if (index == 6) {
        //Mask
        self.dataModel.wifi_mask = value;
        MKTextFieldCellModel *cellModel = self.section6List[1];
        cellModel.textFieldValue = value;
        return;
    }
    if (index == 7) {
        //Gateway
        self.dataModel.wifi_gateway = value;
        MKTextFieldCellModel *cellModel = self.section6List[2];
        cellModel.textFieldValue = value;
        return;
    }
    if (index == 8) {
        //DNS
        self.dataModel.wifi_dns = value;
        MKTextFieldCellModel *cellModel = self.section6List[3];
        cellModel.textFieldValue = value;
        return;
    }
    if (index == 9) {
        //APN
        self.dataModel.apn = value;
        MKTextFieldCellModel *cellModel = self.section7List[0];
        cellModel.textFieldValue = value;
        return;
    }
    if (index == 10) {
        //APN Username
        self.dataModel.apn_username = value;
        MKTextFieldCellModel *cellModel = self.section7List[1];
        cellModel.textFieldValue = value;
        return;
    }
    if (index == 11) {
        //APN Password
        self.dataModel.apn_psd = value;
        MKTextFieldCellModel *cellModel = self.section7List[2];
        cellModel.textFieldValue = value;
        return;
    }
    if (index == 12) {
        //APN PIN
        self.dataModel.pin = value;
        MKTextFieldCellModel *cellModel = self.section7List[3];
        cellModel.textFieldValue = value;
        return;
    }
}

#pragma mark - MKCRNetworkSsidSettingsCellDelegate

- (void)cr_networkSsidSettingsCell_ssidChanged:(NSString *)ssid {
    //Wifi ssid
    MKCRNetworkSsidSettingsCellModel *cellModel = self.section3List[0];
    cellModel.ssid = ssid;
    self.dataModel.wifi_ssid = ssid;
}

- (void)cr_networkSsidSettingsCell_buttonPressed {
    MKCRNearbyWifiController *vc = [[MKCRNearbyWifiController alloc] init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - MKCRNearbyWifiControllerDelegate
- (void)cr_nearbyWifiController_selectedWifi:(NSString *)ssid {
    MKCRNetworkSsidSettingsCellModel *cellModel = self.section3List[0];
    cellModel.ssid = ssid;
    self.dataModel.wifi_ssid = ssid;
    
    [self.tableView mk_reloadSection:3 withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - interface
- (void)readDatasFromDevice {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    @weakify(self);
    [self.dataModel readDataWithSucBlock:^{
        @strongify(self);
        [[MKHudManager share] hide];
        [self loadSectionDatas];
    } failedBlock:^(NSError * _Nonnull error) {
        @strongify(self);
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)saveDataToDevice {
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    @weakify(self);
    [self.dataModel configDataWithSucBlock:^{
        @strongify(self);
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success"];
        [MKCRNetworkManager shared].networkSettings = YES;
    } failedBlock:^(NSError * _Nonnull error) {
        @strongify(self);
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
        [MKCRNetworkManager shared].networkSettings = NO;
    }];
}

#pragma mark - table数据处理方法
- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        //Type
        return self.section0List.count;
    }
    if (section == 1) {
        //Ethernet DHCP
        if (self.dataModel.netType == 0 || self.dataModel.netType == 3 || self.dataModel.netType == 4) {
            //0:ETH 3:ETH_WIFI  4:ETH_WIFI_CELLULAR
            return self.section1List.count;
        }
        return 0;
    }
    if (section == 2) {
        //Ethernet IP/Mask/Gateway/DNS
        if (self.dataModel.netType == 0 || self.dataModel.netType == 3 || self.dataModel.netType == 4) {
            //0:ETH 3:ETH_WIFI  4:ETH_WIFI_CELLULAR
            return (self.dataModel.ethernet_dhcp ? 0 : self.section2List.count);
        }
        return 0;
    }
    if (section == 3) {
        //Wifi SSID
        if (self.dataModel.netType == 1 || self.dataModel.netType == 3 || self.dataModel.netType == 4) {
            //0:WIFI 3:ETH_WIFI  4:ETH_WIFI_CELLULAR
            return self.section3List.count;
        }
        return 0;
    }
    if (section == 4) {
        //Wifi Password
        if (self.dataModel.netType == 1 || self.dataModel.netType == 3 || self.dataModel.netType == 4) {
            //0:WIFI 3:ETH_WIFI  4:ETH_WIFI_CELLULAR
            return self.section4List.count;
        }
        return 0;
    }
    if (section == 5) {
        //Wifi DHCP
        if (self.dataModel.netType == 1 || self.dataModel.netType == 3 || self.dataModel.netType == 4) {
            //0:WIFI 3:ETH_WIFI  4:ETH_WIFI_CELLULAR
            return self.section5List.count;
        }
        return 0;
    }
    if (section == 6) {
        //Wifi IP/Mask/Gateway/DNS
        if (self.dataModel.netType == 1 || self.dataModel.netType == 3 || self.dataModel.netType == 4) {
            //0:WIFI 3:ETH_WIFI  4:ETH_WIFI_CELLULAR
            return (self.dataModel.wifi_dhcp ? 0 : self.section6List.count);
        }
        return 0;
    }
    if (section == 7) {
        //APN/Username/Password/PIN
        if (self.dataModel.netType == 2 || self.dataModel.netType == 4) {
            //2:CELLULAR 4:ETH_WIFI_CELLULAR
            return self.section7List.count;
        }
        return 0;
    }
    
    return 0;
}

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        //Type
        MKTextButtonCell *cell = [MKTextButtonCell initCellWithTableView:self.tableView];
        cell.dataModel = self.section0List[indexPath.row];
        cell.delegate = self;
        return cell;
    }
    if (indexPath.section == 1) {
        //Ethernet DHCP
        MKTextSwitchCell *cell = [MKTextSwitchCell initCellWithTableView:self.tableView];
        cell.dataModel = self.section1List[indexPath.row];
        cell.delegate = self;
        return cell;
    }
    if (indexPath.section == 2) {
        //Ethernet IP/Mask/Gateway/DNS
        MKTextFieldCell *cell = [MKTextFieldCell initCellWithTableView:self.tableView];
        cell.dataModel = self.section2List[indexPath.row];
        cell.delegate = self;
        return cell;
    }
    if (indexPath.section == 3) {
        //Wifi SSID
        MKCRNetworkSsidSettingsCell *cell = [MKCRNetworkSsidSettingsCell initCellWithTableView:self.tableView];
        cell.dataModel = self.section3List[indexPath.row];
        cell.delegate = self;
        return cell;
    }
    if (indexPath.section == 4) {
        //WIFI Password
        MKTextFieldCell *cell = [MKTextFieldCell initCellWithTableView:self.tableView];
        cell.dataModel = self.section4List[indexPath.row];
        cell.delegate = self;
        return cell;
    }
    if (indexPath.section == 5) {
        //Wifi DHCP
        MKTextSwitchCell *cell = [MKTextSwitchCell initCellWithTableView:self.tableView];
        cell.dataModel = self.section5List[indexPath.row];
        cell.delegate = self;
        return cell;
    }
    if (indexPath.section == 6) {
        //Wifi IP/Mask/Gateway/DNS
        MKTextFieldCell *cell = [MKTextFieldCell initCellWithTableView:self.tableView];
        cell.dataModel = self.section6List[indexPath.row];
        cell.delegate = self;
        return cell;
    }
    MKTextFieldCell *cell = [MKTextFieldCell initCellWithTableView:self.tableView];
    cell.dataModel = self.section7List[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - loadSectionDatas
- (void)loadSectionDatas {
    [self loadSection0Datas];
    [self loadSection1Datas];
    [self loadSection2Datas];
    [self loadSection3Datas];
    [self loadSection4Datas];
    [self loadSection5Datas];
    [self loadSection6Datas];
    [self loadSection7Datas];
    
    for (NSInteger i = 0; i < 8; i ++) {
        MKTableSectionLineHeaderModel *headerModel = [[MKTableSectionLineHeaderModel alloc] init];
        if (i == 1) {
            headerModel.text = @"Ethernet";
        }else if (i == 3) {
            headerModel.text = @"WIFI";
        }else if (i == 7) {
            headerModel.text = @"Cellular";
        }
        [self.headerList addObject:headerModel];
    }
        
    [self.tableView reloadData];
}

- (void)loadSection0Datas {
    MKTextButtonCellModel *cellModel = [[MKTextButtonCellModel alloc] init];
    cellModel.index = 0;
    cellModel.msg = @"Type";
    cellModel.buttonLabelFont = MKFont(12.f);
    cellModel.dataList = @[@"ETH",@"WIFI",@"CELLULAR",@"ETH_WIFI",@"ETH_WIFI_CELLULAR"];
    cellModel.dataListIndex = self.dataModel.netType;
    [self.section0List addObject:cellModel];
}

- (void)loadSection1Datas {
    MKTextSwitchCellModel *cellModel = [[MKTextSwitchCellModel alloc] init];
    cellModel.index = 0;
    cellModel.msg = @"DHCP";
    cellModel.isOn = self.dataModel.ethernet_dhcp;
    [self.section1List addObject:cellModel];
}

- (void)loadSection2Datas {
    MKTextFieldCellModel *cellModel1 = [[MKTextFieldCellModel alloc] init];
    cellModel1.index = 0;
    cellModel1.msg = @"IP";
    cellModel1.textFieldType = mk_normal;
    cellModel1.textFieldValue = self.dataModel.ethernet_ip;
    [self.section2List addObject:cellModel1];
    
    MKTextFieldCellModel *cellModel2 = [[MKTextFieldCellModel alloc] init];
    cellModel2.index = 1;
    cellModel2.msg = @"Mask";
    cellModel2.textFieldType = mk_normal;
    cellModel2.textFieldValue = self.dataModel.ethernet_mask;
    [self.section2List addObject:cellModel2];
    
    MKTextFieldCellModel *cellModel3 = [[MKTextFieldCellModel alloc] init];
    cellModel3.index = 2;
    cellModel3.msg = @"Gateway";
    cellModel3.textFieldType = mk_normal;
    cellModel3.textFieldValue = self.dataModel.ethernet_gateway;
    [self.section2List addObject:cellModel3];
    
    MKTextFieldCellModel *cellModel4 = [[MKTextFieldCellModel alloc] init];
    cellModel4.index = 3;
    cellModel4.msg = @"DNS";
    cellModel4.textFieldType = mk_normal;
    cellModel4.textFieldValue = self.dataModel.ethernet_dns;
    [self.section2List addObject:cellModel4];
}

- (void)loadSection3Datas {
    MKCRNetworkSsidSettingsCellModel *cellModel = [[MKCRNetworkSsidSettingsCellModel alloc] init];
    cellModel.ssid = self.dataModel.wifi_ssid;
    [self.section3List addObject:cellModel];
}

- (void)loadSection4Datas {
    MKTextFieldCellModel *cellModel = [[MKTextFieldCellModel alloc] init];
    cellModel.index = 4;
    cellModel.msg = @"Password";
    cellModel.maxLength = 64;
    cellModel.textPlaceholder = @"0-64 Characters";
    cellModel.textFieldType = mk_normal;
    cellModel.textFieldValue = self.dataModel.wifi_psd;
    [self.section4List addObject:cellModel];
}

- (void)loadSection5Datas {
    MKTextSwitchCellModel *cellModel = [[MKTextSwitchCellModel alloc] init];
    cellModel.index = 1;
    cellModel.msg = @"DHCP";
    cellModel.isOn = self.dataModel.wifi_dhcp;
    [self.section5List addObject:cellModel];
}

- (void)loadSection6Datas {
    MKTextFieldCellModel *cellModel1 = [[MKTextFieldCellModel alloc] init];
    cellModel1.index = 5;
    cellModel1.msg = @"IP";
    cellModel1.textFieldType = mk_normal;
    cellModel1.textFieldValue = self.dataModel.wifi_ip;
    [self.section6List addObject:cellModel1];
    
    MKTextFieldCellModel *cellModel2 = [[MKTextFieldCellModel alloc] init];
    cellModel2.index = 6;
    cellModel2.msg = @"Mask";
    cellModel2.textFieldType = mk_normal;
    cellModel2.textFieldValue = self.dataModel.wifi_mask;
    [self.section6List addObject:cellModel2];
    
    MKTextFieldCellModel *cellModel3 = [[MKTextFieldCellModel alloc] init];
    cellModel3.index = 7;
    cellModel3.msg = @"Gateway";
    cellModel3.textFieldType = mk_normal;
    cellModel3.textFieldValue = self.dataModel.wifi_gateway;
    [self.section6List addObject:cellModel3];
    
    MKTextFieldCellModel *cellModel4 = [[MKTextFieldCellModel alloc] init];
    cellModel4.index = 8;
    cellModel4.msg = @"DNS";
    cellModel4.textFieldType = mk_normal;
    cellModel4.textFieldValue = self.dataModel.wifi_dns;
    [self.section6List addObject:cellModel4];
}

- (void)loadSection7Datas {
    MKTextFieldCellModel *cellModel1 = [[MKTextFieldCellModel alloc] init];
    cellModel1.index = 9;
    cellModel1.msg = @"APN";
    cellModel1.textFieldType = mk_normal;
    cellModel1.textFieldValue = self.dataModel.apn;
    cellModel1.textPlaceholder = @"0-100 Characters";
    cellModel1.maxLength = 100;
    [self.section7List addObject:cellModel1];
    
    MKTextFieldCellModel *cellModel2 = [[MKTextFieldCellModel alloc] init];
    cellModel2.index = 10;
    cellModel2.msg = @"Username";
    cellModel2.textFieldType = mk_normal;
    cellModel2.textFieldValue = self.dataModel.apn_username;
    cellModel2.textPlaceholder = @"0-100 Characters";
    cellModel2.maxLength = 100;
    [self.section7List addObject:cellModel2];
    
    MKTextFieldCellModel *cellModel3 = [[MKTextFieldCellModel alloc] init];
    cellModel3.index = 11;
    cellModel3.msg = @"Password";
    cellModel3.textFieldType = mk_normal;
    cellModel3.textFieldValue = self.dataModel.apn_psd;
    cellModel3.textPlaceholder = @"0-100 Characters";
    cellModel3.maxLength = 100;
    [self.section7List addObject:cellModel3];
    
    MKTextFieldCellModel *cellModel4 = [[MKTextFieldCellModel alloc] init];
    cellModel4.index = 12;
    cellModel4.msg = @"PIN";
    cellModel4.textFieldType = mk_normal;
    cellModel4.textFieldValue = self.dataModel.pin;
    cellModel4.textPlaceholder = @"0 or 4-8 characters";
    cellModel4.maxLength = 8;
    [self.section7List addObject:cellModel4];
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = @"Network Settings";
    [self.rightButton setImage:LOADICON(@"MKDeltrtackMQTT", @"MKCRNetworkSettingsController", @"cr_saveIcon.png") forState:UIControlStateNormal];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
}

#pragma mark - getter
- (MKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.backgroundColor = RGBCOLOR(242, 242, 242);
    }
    return _tableView;
}

- (NSMutableArray *)section0List {
    if (!_section0List) {
        _section0List = [NSMutableArray array];
    }
    return _section0List;
}

- (NSMutableArray *)section1List {
    if (!_section1List) {
        _section1List = [NSMutableArray array];
    }
    return _section1List;
}

- (NSMutableArray *)section2List {
    if (!_section2List) {
        _section2List = [NSMutableArray array];
    }
    return _section2List;
}

- (NSMutableArray *)section3List {
    if (!_section3List) {
        _section3List = [NSMutableArray array];
    }
    return _section3List;
}

- (NSMutableArray *)section4List {
    if (!_section4List) {
        _section4List = [NSMutableArray array];
    }
    return _section4List;
}

- (NSMutableArray *)section5List {
    if (!_section5List) {
        _section5List = [NSMutableArray array];
    }
    return _section5List;
}

- (NSMutableArray *)section6List {
    if (!_section6List) {
        _section6List = [NSMutableArray array];
    }
    return _section6List;
}

- (NSMutableArray *)section7List {
    if (!_section7List) {
        _section7List = [NSMutableArray array];
    }
    return _section7List;
}

- (NSMutableArray *)headerList {
    if (!_headerList) {
        _headerList = [NSMutableArray array];
    }
    return _headerList;
}

- (MKCRNetworkSettingsModel *)dataModel {
    if (!_dataModel) {
        _dataModel = [[MKCRNetworkSettingsModel alloc] init];
    }
    return _dataModel;
}


@end
