//
//  MKCRScanController.m
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2021/10/21.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKCRScanController.h"

#import "Masonry.h"

#import "UIViewController+HHTransition.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"
#import "NSObject+MKModel.h"

#import "MKHudManager.h"
#import "MKSearchButton.h"
#import "MKSearchConditionsView.h"
#import "MKCustomUIAdopter.h"
#import "MKAlertView.h"

#import "MKCRBLESDK.h"

#import "MKCRConnectManager.h"

#import "MKCRScanPageModel.h"
#import "MKCRScanPageCell.h"

#import "MKCRTabBarController.h"

static NSString *const localPasswordKey = @"mk_cr_passwordKey";

static CGFloat const searchButtonHeight = 40.f;

static NSTimeInterval const kRefreshInterval = 0.5f;

@interface MKCRScanController ()<UITableViewDelegate,
UITableViewDataSource,
mk_cr_centralManagerScanDelegate,
MKCRScanPageCellDelegate,
MKSearchButtonDelegate,
MKCRTabBarControllerDelegate>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)MKSearchButtonDataModel *buttonModel;

@property (nonatomic, strong)MKSearchButton *searchButton;

@property (nonatomic, strong)UIButton *refreshButton;

@property (nonatomic, strong)UIImageView *refreshIcon;

/**
 数据源
 */
@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)dispatch_source_t scanTimer;

/// 定时刷新
@property (nonatomic, assign)CFRunLoopObserverRef observerRef;
//扫描到新的设备不能立即刷新列表，降低刷新频率
@property (nonatomic, assign)BOOL isNeedRefresh;

/// 保存当前密码输入框ascii字符部分
@property (nonatomic, copy)NSString *asciiText;

@end

@implementation MKCRScanController

- (void)dealloc {
    NSLog(@"MKCRScanController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //移除runloop的监听
    CFRunLoopRemoveObserver(CFRunLoopGetCurrent(), self.observerRef, kCFRunLoopCommonModes);
    [[MKCRCentralManager shared] stopScan];
    [MKCRCentralManager removeFromCentralList];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    self.searchButton.dataModel = self.buttonModel;
    [self runloopObserver];
    [MKCRCentralManager shared].delegate = self;
    [self performSelector:@selector(showCentralStatus) withObject:nil afterDelay:.5f];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MKCRScanPageCell *cell = [MKCRScanPageCell initCellWithTableView:self.tableView];
    cell.dataModel = self.dataList[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.f;
}

#pragma mark - MKSearchButtonDelegate
- (void)mk_scanSearchButtonMethod {
    [MKSearchConditionsView showSearchKey:self.buttonModel.searchKey
                                     rssi:self.buttonModel.searchRssi
                                  minRssi:-127 searchBlock:^(NSString * _Nonnull searchKey, NSInteger searchRssi) {
        self.buttonModel.searchRssi = searchRssi;
        self.buttonModel.searchKey = searchKey;
        self.searchButton.dataModel = self.buttonModel;
        
        self.refreshButton.selected = NO;
        [self refreshButtonPressed];
    }];
}

- (void)mk_scanSearchButtonClearMethod {
    self.buttonModel.searchRssi = -127;
    self.buttonModel.searchKey = @"";
    self.refreshButton.selected = NO;
    [self refreshButtonPressed];
}

#pragma mark - mk_cr_centralManagerScanDelegate
- (void)mk_cr_receiveDevice:(NSDictionary *)deviceModel {
    MKCRScanPageModel *model = [MKCRScanPageModel mk_modelWithJSON:deviceModel];
    [self updateDataWithScanModel:model];
}

- (void)mk_cr_stopScan {
    //如果是左上角在动画，则停止动画
    if (self.refreshButton.isSelected) {
        [self.refreshIcon.layer removeAnimationForKey:@"mk_refreshAnimationKey"];
        [self.refreshButton setSelected:NO];
    }
}

#pragma mark - MKCRScanPageCellDelegate
- (void)cr_scanCellConnectButtonPressed:(NSInteger)index {
    [self connectDeviceWithModel:self.dataList[index]];
}

#pragma mark - MKCRTabBarControllerDelegate
- (void)mk_cr_needResetScanDelegate:(BOOL)need {
    if (need) {
        [MKCRCentralManager shared].delegate = self;
    }
    [self performSelector:@selector(startScanDevice) withObject:nil afterDelay:(need ? 1.f : 0.1f)];
}

#pragma mark - event method
- (void)refreshButtonPressed {
    if ([MKCRCentralManager shared].centralStatus != mk_cr_centralManagerStatusEnable) {
        [self.view showCentralToast:@"The current system of bluetooth is not available!"];
        return;
    }
    self.refreshButton.selected = !self.refreshButton.selected;
    [self.refreshIcon.layer removeAnimationForKey:@"mk_refreshAnimationKey"];
    if (!self.refreshButton.isSelected) {
        //停止扫描
        [[MKCRCentralManager shared] stopScan];
        if (self.scanTimer) {
            dispatch_cancel(self.scanTimer);
        }
        return;
    }
    [self.dataList removeAllObjects];
    [self.tableView reloadData];
    //刷新顶部设备数量
    [self.titleLabel setText:[NSString stringWithFormat:@"DEVICE(%@)",[NSString stringWithFormat:@"%ld",(long)self.dataList.count]]];
    [self.refreshIcon.layer addAnimation:[MKCustomUIAdopter refreshAnimation:2.f] forKey:@"mk_refreshAnimationKey"];
    [self scanTimerRun];
}

#pragma mark - notice method

- (void)showCentralStatus{
    if ([MKCRCentralManager shared].centralStatus != mk_cr_centralManagerStatusEnable) {
        NSString *msg = @"The current system of bluetooth is not available!";
        MKAlertViewAction *cancelAction = [[MKAlertViewAction alloc] initWithTitle:@"OK" handler:^{
            
        }];
        MKAlertView *alertView = [[MKAlertView alloc] init];
        [alertView addAction:cancelAction];
        [alertView showAlertWithTitle:@"Dismiss" message:msg notificationName:@""];
        return;
    }
    [self refreshButtonPressed];
}

#pragma mark - 刷新
- (void)startScanDevice {
    self.refreshButton.selected = NO;
    [self refreshButtonPressed];
}

- (void)scanTimerRun{
    if (self.scanTimer) {
        dispatch_cancel(self.scanTimer);
    }
    [[MKCRCentralManager shared] startScan];
    self.scanTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,dispatch_get_global_queue(0, 0));
    //开始时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC);
    //间隔时间
    uint64_t interval = 30 * NSEC_PER_SEC;
    dispatch_source_set_timer(self.scanTimer, start, interval, 0);
    @weakify(self);
    dispatch_source_set_event_handler(self.scanTimer, ^{
        @strongify(self);
        [[MKCRCentralManager shared] stopScan];
        [self needRefreshList];
    });
    dispatch_resume(self.scanTimer);
}

- (void)needRefreshList {
    //标记需要刷新
    self.isNeedRefresh = YES;
    //唤醒runloop
    CFRunLoopWakeUp(CFRunLoopGetMain());
}

- (void)runloopObserver {
    @weakify(self);
    __block NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    self.observerRef = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        @strongify(self);
        if (activity == kCFRunLoopBeforeWaiting) {
            //runloop空闲的时候刷新需要处理的列表,但是需要控制刷新频率
            NSTimeInterval currentInterval = [[NSDate date] timeIntervalSince1970];
            if (currentInterval - timeInterval < kRefreshInterval) {
                return;
            }
            timeInterval = currentInterval;
            if (self.isNeedRefresh) {
                [self.tableView reloadData];
                [self.titleLabel setText:[NSString stringWithFormat:@"DEVICE(%@)",[NSString stringWithFormat:@"%ld",(long)self.dataList.count]]];
                self.isNeedRefresh = NO;
            }
        }
    });
    //添加监听，模式为kCFRunLoopCommonModes
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), self.observerRef, kCFRunLoopCommonModes);
}

- (void)updateDataWithScanModel:(MKCRScanPageModel *)scanDataModel{
    if (ValidStr(self.buttonModel.searchKey)) {
        //过滤设备名字和mac地址
        [self filterTrackerDataWithSearchName:scanDataModel];
        return;
    }
    if (self.buttonModel.searchRssi > self.buttonModel.minSearchRssi) {
        //开启rssi过滤
        if (scanDataModel.rssi >= self.buttonModel.searchRssi) {
            [self processTrackerData:scanDataModel];
        }
        return;
    }
    [self processTrackerData:scanDataModel];
}

/**
 通过设备名称和mac地址过滤设备，这个时候肯定开启了rssi
 
 @param scanDataModel 设备
 */
- (void)filterTrackerDataWithSearchName:(MKCRScanPageModel *)scanDataModel{
    if (scanDataModel.rssi < self.buttonModel.searchRssi) {
        return;
    }
    if ([[scanDataModel.deviceName uppercaseString] containsString:[self.buttonModel.searchKey uppercaseString]]
        || [[[scanDataModel.macAddress stringByReplacingOccurrencesOfString:@":" withString:@""] uppercaseString] containsString:[self.buttonModel.searchKey uppercaseString]]) {
        //如果mac地址和设备名称包含搜索条件，则加入
        [self processTrackerData:scanDataModel];
    }
}

- (void)processTrackerData:(MKCRScanPageModel *)scanDataModel{
    //查看数据源中是否已经存在相关设备
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"macAddress == %@", scanDataModel.macAddress];
    NSArray *array = [self.dataList filteredArrayUsingPredicate:predicate];
    BOOL contain = ValidArray(array);
    if (contain) {
        //如果是已经存在了，替换
        [self dataExistDataSource:scanDataModel];
        return;
    }
    //不存在，则加入
    [self dataNoExistDataSource:scanDataModel];
}

/**
 将扫描到的设备加入到数据源
 
 @param scanDataModel 扫描到的设备
 */
- (void)dataNoExistDataSource:(MKCRScanPageModel *)scanDataModel{
    [self.dataList addObject:scanDataModel];
    scanDataModel.index = (self.dataList.count - 1);
    [self needRefreshList];
}

/**
 如果是已经存在了，直接替换
 
 @param scanDataModel  新扫描到的数据帧
 */
- (void)dataExistDataSource:(MKCRScanPageModel *)scanDataModel {
    NSInteger currentIndex = 0;
    for (NSInteger i = 0; i < self.dataList.count; i ++) {
        MKCRScanPageModel *dataModel = self.dataList[i];
        if ([dataModel.macAddress isEqualToString:scanDataModel.macAddress]) {
            currentIndex = i;
            break;
        }
    }
    MKCRScanPageModel *dataModel = self.dataList[currentIndex];
    scanDataModel.index = currentIndex;
    [self.dataList replaceObjectAtIndex:currentIndex withObject:scanDataModel];
    [self needRefreshList];
}

#pragma mark - 连接部分
- (void)connectDeviceWithModel:(MKCRScanPageModel *)scanDataModel {
    //停止扫描
    [self.refreshIcon.layer removeAnimationForKey:@"mk_refreshAnimationKey"];
    [[MKCRCentralManager shared] stopScan];
    if (self.scanTimer) {
        dispatch_cancel(self.scanTimer);
    }
    
    @weakify(self);
    MKAlertViewAction *cancelAction = [[MKAlertViewAction alloc] initWithTitle:@"Cancel" handler:^{
        @strongify(self);
        self.refreshButton.selected = NO;
        [self refreshButtonPressed];
    }];
    
    MKAlertViewAction *confirmAction = [[MKAlertViewAction alloc] initWithTitle:@"OK" handler:^{
        @strongify(self);
        [self connectDeviceWithDataModel:scanDataModel];
    }];
    NSString *localPassword = [[NSUserDefaults standardUserDefaults] objectForKey:localPasswordKey];
    self.asciiText = localPassword;
    MKAlertViewTextField *textField = [[MKAlertViewTextField alloc] initWithTextValue:SafeStr(localPassword)
                                                                          placeholder:@"The password is 8 characters."
                                                                        textFieldType:mk_normal
                                                                            maxLength:8
                                                                              handler:^(NSString * _Nonnull text) {
        @strongify(self);
        self.asciiText = text;
    }];
    
    NSString *msg = @"Please enter connection password.";
    MKAlertView *alertView = [[MKAlertView alloc] init];
    [alertView addAction:cancelAction];
    [alertView addAction:confirmAction];
    [alertView addTextField:textField];
    [alertView showAlertWithTitle:@"Enter password" message:msg notificationName:@"mk_cr_needDismissAlert"];
}

- (void)connectDeviceWithDataModel:(MKCRScanPageModel *)scanDataModel {
    NSString *password = self.asciiText;
    if (password.length != 8) {
        [self.view showCentralToast:@"The password should be 8 characters."];
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Connecting..." inView:self.view isPenetration:NO];
    [[MKCRConnectManager shared] connectDevice:scanDataModel.peripheral password:password sucBlock:^{
        if (ValidStr(self.asciiText) && self.asciiText.length == 8) {
            [[NSUserDefaults standardUserDefaults] setObject:self.asciiText forKey:localPasswordKey];
        }
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Time sync completed!"];
        [self performSelector:@selector(pushTabBarPage) withObject:nil afterDelay:0.6f];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
        [self connectFailed];
    }];
}

- (void)pushTabBarPage {
    MKCRTabBarController *vc = [[MKCRTabBarController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    @weakify(self);
    [self hh_presentViewController:vc presentStyle:HHPresentStyleErected completion:^{
        @strongify(self);
        vc.delegate = self;
    }];
}

- (void)connectFailed {
    self.refreshButton.selected = NO;
    [self refreshButtonPressed];
}

#pragma mark - UI
- (void)loadSubViews {
    [self.view setBackgroundColor:RGBCOLOR(237, 243, 250)];
    [self.leftButton setHidden:YES];
    self.titleLabel.text = @"DEVICE(0)";
    UIView *topView = [[UIView alloc] init];
    topView.backgroundColor = RGBCOLOR(237, 243, 250);
    [self.view addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.height.mas_equalTo(searchButtonHeight + 2 * 15.f);
    }];
    [self.refreshButton addSubview:self.refreshIcon];
    [topView addSubview:self.refreshButton];
    [self.refreshIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.refreshButton.mas_centerX);
        make.centerY.mas_equalTo(self.refreshButton.mas_centerY);
        make.width.mas_equalTo(22.f);
        make.height.mas_equalTo(22.f);
    }];
    [self.refreshButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(40.f);
        make.top.mas_equalTo(15.f);
        make.height.mas_equalTo(40.f);
    }];
    [topView addSubview:self.searchButton];
    [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.refreshButton.mas_left).mas_offset(-10.f);
        make.top.mas_equalTo(15.f);
        make.height.mas_equalTo(searchButtonHeight);
    }];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10.f);
        make.right.mas_equalTo(-10.f);
        make.top.mas_equalTo(topView.mas_bottom);
        make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom).mas_offset(-5.f);
    }];
}

#pragma mark - getter
- (MKBaseTableView *)tableView{
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = COLOR_WHITE_MACROS;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.layer.masksToBounds = YES;
        _tableView.layer.borderColor = COLOR_CLEAR_MACROS.CGColor;
        _tableView.layer.cornerRadius = 6.f;
    }
    return _tableView;
}

- (UIImageView *)refreshIcon {
    if (!_refreshIcon) {
        _refreshIcon = [[UIImageView alloc] init];
        _refreshIcon.image = LOADICON(@"MKDeltrtackMQTT", @"MKCRScanController", @"cr_scan_refreshIcon.png");
    }
    return _refreshIcon;
}

- (UIButton *)refreshButton {
    if (!_refreshButton) {
        _refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_refreshButton addTarget:self
                           action:@selector(refreshButtonPressed)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    return _refreshButton;
}

- (MKSearchButton *)searchButton {
    if (!_searchButton) {
        _searchButton = [[MKSearchButton alloc] init];
        _searchButton.delegate = self;
    }
    return _searchButton;
}

- (MKSearchButtonDataModel *)buttonModel {
    if (!_buttonModel) {
        _buttonModel = [[MKSearchButtonDataModel alloc] init];
        _buttonModel.placeholder = @"Edit Filter";
        _buttonModel.minSearchRssi = -127;
        _buttonModel.searchRssi = -127;
    }
    return _buttonModel;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

@end
