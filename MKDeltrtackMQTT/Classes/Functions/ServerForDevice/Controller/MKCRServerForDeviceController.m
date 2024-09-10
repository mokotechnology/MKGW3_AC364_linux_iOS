//
//  MKCRServerForDeviceController.m
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2024/09/2.
//  Copyright © 2023 aadyx2007@163.com. All rights reserved.
//

#import "MKCRServerForDeviceController.h"

#import <MessageUI/MessageUI.h>

#import "Masonry.h"

#import "MLInputDodger.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "NSString+MKAdd.h"
#import "UIView+MKAdd.h"
#import "NSObject+MKModel.h"

#import "MKHudManager.h"
#import "MKTextFieldCell.h"
#import "MKTableSectionLineHeader.h"
#import "MKCustomUIAdopter.h"
#import "MKCAFileSelectController.h"
#import "MKAlertView.h"

#import "MKCRNetworkManager.h"

#import "MKCRServerConfigDeviceFooterView.h"

#import "MKCRServerForDeviceModel.h"

#import "MKCRMQTTTopicsCell.h"

@interface MKCRServerForDeviceController ()<UITableViewDelegate,
UITableViewDataSource,
MKTextFieldCellDelegate,
MKCRServerConfigDeviceFooterViewDelegate,
MKCAFileSelectControllerDelegate,
MKCRMQTTTopicsCellDelegate>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *section0List;

@property (nonatomic, strong)NSMutableArray *section1List;

@property (nonatomic, strong)NSMutableArray *section2List;

@property (nonatomic, strong)NSMutableArray *section3List;

@property (nonatomic, strong)NSMutableArray *sectionHeaderList;

@property (nonatomic, strong)MKCRServerForDeviceModel *dataModel;

@property (nonatomic, strong)MKCRServerConfigDeviceFooterView *sslParamsView;

@property (nonatomic, strong)MKCRServerConfigDeviceFooterViewModel *sslParamsModel;

@property (nonatomic, strong)UIView *footerView;

@end

@implementation MKCRServerForDeviceController

- (void)dealloc {
    NSLog(@"MKCRServerForDeviceController销毁");
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //本页面禁止右划退出手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.view.shiftHeightAsDodgeViewForMLInputDodger = 50.0f;
    [self.view registerAsDodgeViewForMLInputDodgerWithOriginalY:self.view.frame.origin.y];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self readDataFromDevice];
}

#pragma mark - super method
- (void)rightButtonMethod {
    [self saveDataToDevice];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return 90.f;
    }
    if (indexPath.section == 2 || indexPath.section == 3) {
        return 130.f;
    }
    return 44.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MKTableSectionLineHeader *header = [MKTableSectionLineHeader initHeaderViewWithTableView:tableView];
    header.headerModel = self.sectionHeaderList[section];
    return header;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionHeaderList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.section0List.count;
    }
    if (section == 1) {
        return self.section1List.count;
    }
    if (section == 2) {
        return self.section2List.count;
    }
    if (section == 3) {
        return self.section3List.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        MKTextFieldCell *cell = [MKTextFieldCell initCellWithTableView:tableView];
        cell.dataModel = self.section0List[indexPath.row];
        cell.delegate = self;
        return cell;
    }
    if (indexPath.section == 1) {
        MKCRMQTTTopicsCell *cell = [MKCRMQTTTopicsCell initCellWithTableView:tableView];
        cell.dataModel = self.section1List[indexPath.row];
        cell.delegate = self;
        return cell;
    }
    if (indexPath.section == 2) {
        MKCRMQTTTopicsCell *cell = [MKCRMQTTTopicsCell initCellWithTableView:tableView];
        cell.dataModel = self.section2List[indexPath.row];
        cell.delegate = self;
        return cell;
    }
    MKCRMQTTTopicsCell *cell = [MKCRMQTTTopicsCell initCellWithTableView:tableView];
    cell.dataModel = self.section3List[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - MKTextFieldCellDelegate
/// textField内容发送改变时的回调事件
/// @param index 当前cell所在的index
/// @param value 当前textField的值
- (void)mk_deviceTextCellValueChanged:(NSInteger)index textValue:(NSString *)value {
    if (index == 0) {
        //host
        self.dataModel.host = value;
        MKTextFieldCellModel *cellModel = self.section0List[0];
        cellModel.textFieldValue = value;
        return;
    }
    if (index == 1) {
        //Port
        self.dataModel.port = value;
        MKTextFieldCellModel *cellModel = self.section0List[1];
        cellModel.textFieldValue = value;
        return;
    }
    if (index == 2) {
        //clientID
        self.dataModel.clientID = value;
        MKTextFieldCellModel *cellModel = self.section0List[2];
        cellModel.textFieldValue = value;
        return;
    }
}

#pragma mark - MKCRMQTTTopicsCellDelegate
- (void)cr_mqttTopicsCell_pubTopicChanged:(NSInteger)index topic:(NSString *)topic {
    if (index == 0) {
        //Broadcast Publish Topic
        self.dataModel.broadPubTopic = topic;
        MKCRMQTTTopicsCellModel *cellModel = self.section1List[0];
        cellModel.pubTopic = topic;
        return;
    }
    if (index == 1) {
        //Gateway Publish Topic
        self.dataModel.gatewayPubTopic = topic;
        MKCRMQTTTopicsCellModel *cellModel = self.section2List[0];
        cellModel.pubTopic = topic;
        return;
    }
    if (index == 2) {
        //Device Publish Topic
        self.dataModel.devicePubTopic = topic;
        MKCRMQTTTopicsCellModel *cellModel = self.section3List[0];
        cellModel.pubTopic = topic;
        return;
    }
}

- (void)cr_mqttTopicsCell_subTopicChanged:(NSInteger)index topic:(NSString *)topic {
    if (index == 0) {
        //Broadcast Sublish Topic
//        self.dataModel.broadSubTopic = topic;
//        MKCRMQTTTopicsCellModel *cellModel = self.section1List[0];
//        cellModel.subTopic = topic;
//        return;
    }
    if (index == 1) {
        //Gateway Sublish Topic
        self.dataModel.gatewaySubTopic = topic;
        MKCRMQTTTopicsCellModel *cellModel = self.section2List[0];
        cellModel.subTopic = topic;
        return;
    }
    if (index == 2) {
        //Device Sublish Topic
        self.dataModel.deviceSubTopic = topic;
        MKCRMQTTTopicsCellModel *cellModel = self.section3List[0];
        cellModel.subTopic = topic;
        return;
    }
}

- (void)cr_mqttTopicsCell_qosChanged:(NSInteger)index qos:(NSInteger)qos {
    if (index == 0) {
        //Broadcast Publish Qos
        self.dataModel.broadQos = qos;
        MKCRMQTTTopicsCellModel *cellModel = self.section1List[0];
        cellModel.qos = qos;
        return;
    }
    if (index == 1) {
        //Gateway Publish Qos
        self.dataModel.gatewayQos = qos;
        MKCRMQTTTopicsCellModel *cellModel = self.section2List[0];
        cellModel.qos = qos;
        return;
    }
    if (index == 2) {
        //Device Publish Qos
        self.dataModel.deviceQos = qos;
        MKCRMQTTTopicsCellModel *cellModel = self.section3List[0];
        cellModel.qos = qos;
        return;
    }
}

#pragma mark - MKCRServerConfigDeviceFooterViewDelegate
/// 用户改变了开关状态
/// @param isOn isOn
/// @param statusID 0:cleanSession   1:ssl
- (void)cr_mqtt_serverForDevice_switchStatusChanged:(BOOL)isOn statusID:(NSInteger)statusID {
    if (statusID == 0) {
        //cleanSession
        self.dataModel.cleanSession = isOn;
        self.sslParamsModel.cleanSession = isOn;
        return;
    }
    if (statusID == 1) {
        //ssl
        self.dataModel.sslIsOn = isOn;
        self.sslParamsModel.sslIsOn = isOn;
        //动态刷新footer
        [self setupSSLViewFrames];
        self.sslParamsView.dataModel = self.sslParamsModel;
        return;
    }
}

/// 输入框内容发生了改变
/// @param text 最新的输入框内容
/// @param textID 0:keepAlive    1:userName     2:password    3:deviceID   4:ntpURL  5:lwtTopic   6:lwtPayload
- (void)cr_mqtt_serverForDevice_textFieldValueChanged:(NSString *)text textID:(NSInteger)textID {
    if (textID == 0) {
        //keepAlive
        self.dataModel.keepAlive = text;
        self.sslParamsModel.keepAlive = text;
        return;
    }
    if (textID == 1) {
        //userName
        self.dataModel.userName = text;
        self.sslParamsModel.userName = text;
        return;
    }
    if (textID == 2) {
        //password
        self.dataModel.password = text;
        self.sslParamsModel.password = text;
        return;
    }
}

/// 用户选择了加密方式
/// @param certificate 0:CA signed server certificate     1:CA certificate     2:Self signed certificates
- (void)cr_mqtt_serverForDevice_certificateChanged:(NSInteger)certificate {
    self.dataModel.certificate = certificate;
    self.sslParamsModel.certificate = certificate;
    //动态刷新footer
    [self setupSSLViewFrames];
    self.sslParamsView.dataModel = self.sslParamsModel;
}

/// 用户点击了证书相关按钮
/// @param fileType 0:caFaile   1:cilentKeyFile   2:client cert file
- (void)cr_mqtt_serverForDevice_fileButtonPressed:(NSInteger)fileType {
    if (fileType == 0) {
        //caFile
        MKCAFileSelectController *vc = [[MKCAFileSelectController alloc] init];
        vc.pageType = mk_caCertSelPage;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if (fileType == 1) {
        //cilentKeyFile
        MKCAFileSelectController *vc = [[MKCAFileSelectController alloc] init];
        vc.pageType = mk_clientKeySelPage;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if (fileType == 2) {
        //client cert file
        MKCAFileSelectController *vc = [[MKCAFileSelectController alloc] init];
        vc.pageType = mk_clientCertSelPage;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
}

#pragma mark - MKCAFileSelectControllerDelegate
- (void)mk_certSelectedMethod:(mk_certListPageType)certType certName:(NSString *)certName {
    if (certType == mk_caCertSelPage) {
        //CA File
        self.dataModel.caFileName = certName;
        self.sslParamsModel.caFileName = certName;
        
        //动态布局底部footer
        [self setupSSLViewFrames];
        
        self.sslParamsView.dataModel = self.sslParamsModel;
        return;
    }
    if (certType == mk_clientKeySelPage) {
        //客户端私钥
        self.dataModel.clientKeyName = certName;
        self.sslParamsModel.clientKeyName = certName;
        
        //动态布局底部footer
        [self setupSSLViewFrames];
        
        self.sslParamsView.dataModel = self.sslParamsModel;
        return;
    }
    if (certType == mk_clientCertSelPage) {
        //客户端证书
        self.dataModel.clientCertName = certName;
        self.sslParamsModel.clientCertName = certName;
        
        //动态布局底部footer
        [self setupSSLViewFrames];
        
        self.sslParamsView.dataModel = self.sslParamsModel;
        return;
    }
}

#pragma mark - interface
- (void)readDataFromDevice {
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
    NSString *errorMsg = [self.dataModel checkParams];
    if (ValidStr(errorMsg)) {
        [self.view showCentralToast:errorMsg];
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    @weakify(self);
    [self.dataModel configDataWithSucBlock:^{
        @strongify(self);
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success!"];
        [MKCRNetworkManager shared].mqttSettings = YES;
    } failedBlock:^(NSError * _Nonnull error) {
        @strongify(self);
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
        [MKCRNetworkManager shared].mqttSettings = NO;
    }];
}

#pragma mark - loadSectionDatas
- (void)loadSectionDatas {
    [self loadSection0Datas];
    [self loadSection1Datas];
    [self loadSection2Datas];
    [self loadSection3Datas];
    
    [self loadSectionHeaderDatas];
    [self loadFooterViewDatas];
    
    [self.tableView reloadData];
}

- (void)loadSection0Datas {
    MKTextFieldCellModel *cellModel1 = [[MKTextFieldCellModel alloc] init];
    cellModel1.index = 0;
    cellModel1.msg = @"Host";
    cellModel1.textPlaceholder = @"Less than 64 Characters";
    cellModel1.textFieldType = mk_normal;
    cellModel1.textFieldValue = self.dataModel.host;
    cellModel1.maxLength = 64;
    [self.section0List addObject:cellModel1];
    
    MKTextFieldCellModel *cellModel2 = [[MKTextFieldCellModel alloc] init];
    cellModel2.index = 1;
    cellModel2.msg = @"Port";
    cellModel2.textPlaceholder = @"1-65535";
    cellModel2.textFieldType = mk_realNumberOnly;
    cellModel2.textFieldValue = self.dataModel.port;
    cellModel2.maxLength = 5;
    [self.section0List addObject:cellModel2];
    
    MKTextFieldCellModel *cellModel3 = [[MKTextFieldCellModel alloc] init];
    cellModel3.index = 2;
    cellModel3.msg = @"Client Id";
    cellModel3.textPlaceholder = @"1-64 Characters";
    cellModel3.textFieldType = mk_normal;
    cellModel3.textFieldValue = self.dataModel.clientID;
    cellModel3.maxLength = 64;
    [self.section0List addObject:cellModel3];
}

- (void)loadSection1Datas {
    MKCRMQTTTopicsCellModel *cellModel = [[MKCRMQTTTopicsCellModel alloc] init];
    cellModel.index = 0;
    cellModel.showSubTopic = NO;
    cellModel.pubMsg = @"Publish Topic";
    cellModel.pubTopic = self.dataModel.broadPubTopic;
    cellModel.qosMsg = @"Broadcast Qos";
    cellModel.qos = self.dataModel.broadQos;
    [self.section1List addObject:cellModel];
}

- (void)loadSection2Datas {
    MKCRMQTTTopicsCellModel *cellModel = [[MKCRMQTTTopicsCellModel alloc] init];
    cellModel.index = 1;
    cellModel.showSubTopic = YES;
    cellModel.pubMsg = @"Publish Topic";
    cellModel.pubTopic = self.dataModel.gatewayPubTopic;
    cellModel.subMsg = @"Subscribe Topic";
    cellModel.subTopic = self.dataModel.gatewaySubTopic;
    cellModel.qosMsg = @"Gateway Qos";
    cellModel.qos = self.dataModel.gatewayQos;
    [self.section2List addObject:cellModel];
}

- (void)loadSection3Datas {
    MKCRMQTTTopicsCellModel *cellModel = [[MKCRMQTTTopicsCellModel alloc] init];
    cellModel.index = 2;
    cellModel.showSubTopic = YES;
    cellModel.pubMsg = @"Publish Topic";
    cellModel.pubTopic = self.dataModel.devicePubTopic;
    cellModel.subMsg = @"Subscribe Topic";
    cellModel.subTopic = self.dataModel.deviceSubTopic;
    cellModel.qosMsg = @"Gateway Qos";
    cellModel.qos = self.dataModel.deviceQos;
    [self.section3List addObject:cellModel];
}

- (void)loadSectionHeaderDatas {
    MKTableSectionLineHeaderModel *model1 = [[MKTableSectionLineHeaderModel alloc] init];
    model1.contentColor = RGBCOLOR(242, 242, 242);
    model1.text = @"Broker Setting";
    [self.sectionHeaderList addObject:model1];
    
    MKTableSectionLineHeaderModel *model2 = [[MKTableSectionLineHeaderModel alloc] init];
    model2.contentColor = RGBCOLOR(242, 242, 242);
    model2.text = @"Upload Beacon and Hearbeat Packets";
    [self.sectionHeaderList addObject:model2];
    
    MKTableSectionLineHeaderModel *model3 = [[MKTableSectionLineHeaderModel alloc] init];
    model3.contentColor = RGBCOLOR(242, 242, 242);
    model3.text = @"Gateway Remote Management";
    [self.sectionHeaderList addObject:model3];
    
    MKTableSectionLineHeaderModel *model4 = [[MKTableSectionLineHeaderModel alloc] init];
    model4.contentColor = RGBCOLOR(242, 242, 242);
    model4.text = @"BLE Remote Communication";
    [self.sectionHeaderList addObject:model4];
}

- (void)loadFooterViewDatas {
    self.sslParamsModel.cleanSession = self.dataModel.cleanSession;
    self.sslParamsModel.keepAlive = self.dataModel.keepAlive;
    self.sslParamsModel.userName = self.dataModel.userName;
    self.sslParamsModel.password = self.dataModel.password;
    self.sslParamsModel.sslIsOn = self.dataModel.sslIsOn;
    self.sslParamsModel.certificate = self.dataModel.certificate;
    self.sslParamsModel.caFileName = self.dataModel.caFileName;
    self.sslParamsModel.clientKeyName = self.dataModel.clientKeyName;
    self.sslParamsModel.clientCertName = self.dataModel.clientCertName;
    
    //动态布局底部footer
    [self setupSSLViewFrames];
    
    self.sslParamsView.dataModel = self.sslParamsModel;
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = @"MQTT settings";
    [self.rightButton setImage:LOADICON(@"MKDeltrtackMQTT", @"MKCRServerForDeviceController", @"cr_saveIcon.png") forState:UIControlStateNormal];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
}

- (void)setupSSLViewFrames {
    if (self.sslParamsView.superview) {
        [self.sslParamsView removeFromSuperview];
    }

    CGFloat height = [self.sslParamsView fetchHeightWithSSLStatus:self.dataModel.sslIsOn
                                                       CAFileName:self.dataModel.caFileName
                                                    clientKeyName:self.dataModel.clientKeyName
                                                   clientCertName:self.dataModel.clientCertName
                                                      certificate:self.dataModel.certificate];
    
    [self.footerView addSubview:self.sslParamsView];
    self.footerView.frame = CGRectMake(0, 0, kViewWidth, height + 70.f);
    self.sslParamsView.frame = CGRectMake(0, 0, kViewWidth, height);
    self.tableView.tableFooterView = self.footerView;
}

#pragma mark - getter

- (MKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = RGBCOLOR(242, 242, 242);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.tableFooterView = self.footerView;
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

- (MKCRServerForDeviceModel *)dataModel {
    if (!_dataModel) {
        _dataModel = [[MKCRServerForDeviceModel alloc] init];
    }
    return _dataModel;
}

- (NSMutableArray *)sectionHeaderList {
    if (!_sectionHeaderList) {
        _sectionHeaderList = [NSMutableArray array];
    }
    return _sectionHeaderList;
}

- (MKCRServerConfigDeviceFooterView *)sslParamsView {
    if (!_sslParamsView) {
        _sslParamsView = [[MKCRServerConfigDeviceFooterView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, 380.f)];
        _sslParamsView.delegate = self;
    }
    return _sslParamsView;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, 450.f)];
        _footerView.backgroundColor = COLOR_WHITE_MACROS;
        [_footerView addSubview:self.sslParamsView];
    }
    return _footerView;
}

- (MKCRServerConfigDeviceFooterViewModel *)sslParamsModel {
    if (!_sslParamsModel) {
        _sslParamsModel = [[MKCRServerConfigDeviceFooterViewModel alloc] init];
    }
    return _sslParamsModel;
}

@end
