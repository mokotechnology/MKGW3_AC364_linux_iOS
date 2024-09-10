//
//  MKCRNearbyWifiController.m
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2024/9/5.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import "MKCRNearbyWifiController.h"

#import "Masonry.h"

#import "MLInputDodger.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"

#import "MKHudManager.h"

#import "MKBLEBaseSDKAdopter.h"
#import "MKCRCentralManager.h"
#import "MKCRInterface+MKCRConfig.h"

#import "MKCRNearbyWifiCell.h"

static NSTimeInterval const kRefreshInterval = 0.5f;

@interface MKCRNearbyWifiController ()<UITableViewDelegate,
UITableViewDataSource,
mk_cr_centralManagerScanWifiDelegate>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *contentList;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)dispatch_source_t contentTimer;

@property (nonatomic, assign)NSInteger contentTimeCount;

@property (nonatomic, assign)BOOL contentReceiveTimeout;

@end

@implementation MKCRNearbyWifiController

- (void)dealloc {
    NSLog(@"MKCRNearbyWifiController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.contentTimer) {
        dispatch_cancel(self.contentTimer);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
}

#pragma mark - super method
- (void)rightButtonMethod {
    [self startScanWifi];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MKCRNearbyWifiCellModel *cellModel = self.dataList[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(cr_nearbyWifiController_selectedWifi:)]) {
        [self.delegate cr_nearbyWifiController_selectedWifi:cellModel.ssid];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKCRNearbyWifiCell *cell = [MKCRNearbyWifiCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - mk_cr_centralManagerScanWifiDelegate
- (void)mk_cr_receiveWifi:(NSString *)content {
    if (self.contentReceiveTimeout || !ValidStr(content) || content.length < 6) {
        return;
    }
    NSLog(@"接收到数据:%@",content);
    self.contentTimeCount = 0;
    
    NSInteger index = 0;
    NSInteger totalPacket = [MKBLEBaseSDKAdopter getDecimalWithHex:content range:NSMakeRange(index, 2)];
    index += 2;
    NSInteger packetIndex = [MKBLEBaseSDKAdopter getDecimalWithHex:content range:NSMakeRange(index, 2)];
    index += 2;
    NSInteger totalDataLen = [MKBLEBaseSDKAdopter getDecimalWithHex:content range:NSMakeRange(index, 2)];
    index += 2;
    
    [self.contentList addObject:[content substringFromIndex:index]];
    
    if (totalPacket == self.contentList.count) {
        //接受数据完成，开始解析
        if (self.contentTimer) {
            dispatch_cancel(self.contentTimer);
        }
        self.contentTimeCount = 0;
        self.contentReceiveTimeout = NO;
        [self parseContentList];
        return;
    }
}

#pragma mark - interface
- (void)startScanWifi {
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    @weakify(self);
    [MKCRInterface cr_startWifiScanWithSucBlock:^{
        [MKCRCentralManager shared].wifiDelegate = self;
        [[MKHudManager share] hide];
        [self.dataList removeAllObjects];
        [self.contentList removeAllObjects];
        [[MKHudManager share] showHUDWithTitle:@"Loading..." inView:self.view isPenetration:NO];
        [self contentTimerRun];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - Private method
- (void)parseContentList {
    NSString *content = @"";
    for (NSInteger i = 0; i < self.contentList.count; i ++) {
        content = [content stringByAppendingString:self.contentList[i]];
    }
    NSUInteger length = content.length;
    NSUInteger index = 0;

    while (index < length) {
        // 检查第一个字节是否是 00
        NSString *startString = [content substringWithRange:NSMakeRange(index, 2)];
        if (![startString isEqualToString:@"00"]) {
            break;
        }
        index += 2;

        // 读取 BSSID 长度
        if (index >= length) break;
        NSInteger bssidLength = [MKBLEBaseSDKAdopter getDecimalWithHex:content range:NSMakeRange(index, 2)];
        index += 2;
        
        if (index + bssidLength > length) break; // 确保不会越界

        // 读取 BSSID 数据
        NSString *bssid = [content substringWithRange:NSMakeRange(index, 2 * bssidLength)];
        index += (2 * bssidLength);

        // 创建模型对象
        MKCRNearbyWifiCellModel *model = [[MKCRNearbyWifiCellModel alloc] init];
        model.bssid = bssid;

        // 解析类型和数据项
        while (index < length) {
            // 读取类型（01 或 02）
            if (index >= length) break;
            NSString *type = [content substringWithRange:NSMakeRange(index, 2)];
            if ([type isEqualToString:@"00"]) {
                break;
            }
            index += 2;
            // 读取数据长度
            if (index >= length) break;
            NSInteger dataLength = [MKBLEBaseSDKAdopter getDecimalWithHex:content range:NSMakeRange(index, 2)];
            index += 2;
            if (index + dataLength > length) break; // 确保不会越界
            
            // 根据类型设置属性
            if ([type isEqualToString:@"01"]) {
                NSString *dataString = [content substringWithRange:NSMakeRange(index, 2 * dataLength)];
                model.ssid = [[NSString alloc] initWithData:[MKBLEBaseSDKAdopter stringToData:dataString] encoding:NSUTF8StringEncoding];
            } else if ([type isEqualToString:@"02"]) {
                // 处理有符号的十六进制 RSSI 数据
                model.rssi = [MKBLEBaseSDKAdopter signedHexTurnString:[content substringWithRange:NSMakeRange(index, 2 * dataLength)]];
            }
            index += (dataLength * 2);
        }

        // 添加模型对象到全局数组
        [self.dataList addObject:model];
    }
    [[MKHudManager share] hide];
    [self.tableView reloadData];
}

- (void)contentTimerRun{
    if (self.contentTimer) {
        dispatch_cancel(self.contentTimer);
    }
    self.contentTimeCount = 0;
    self.contentReceiveTimeout = NO;
    self.contentTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,dispatch_get_global_queue(0, 0));
    //开始时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC);
    //间隔时间
    uint64_t interval = NSEC_PER_SEC;
    dispatch_source_set_timer(self.contentTimer, start, interval, 0);
    @weakify(self);
    dispatch_source_set_event_handler(self.contentTimer, ^{
        @strongify(self);
        NSLog(@"接收到数据");
        self.contentTimeCount ++;
        if (self.contentTimeCount >= 8) {
            dispatch_cancel(self.contentTimer);
            self.contentTimeCount = 0;
            self.contentReceiveTimeout = YES;
            moko_dispatch_main_safe(^{
                [[MKHudManager share] hide];
            });
            return;
        }
    });
    dispatch_resume(self.contentTimer);
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = @"Nearby WIFI";
    [self.rightButton setImage:LOADICON(@"MKDeltrtackMQTT", @"MKCRNearbyWifiController", @"cr_refreshWifiListIcon.png") forState:UIControlStateNormal];
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

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (NSMutableArray *)contentList {
    if (!_contentList) {
        _contentList = [NSMutableArray array];
    }
    return _contentList;
}

@end
