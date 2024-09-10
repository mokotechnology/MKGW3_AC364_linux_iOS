//
//  MKCRNetworkSettingsModel.m
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2024/9/1.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import "MKCRNetworkSettingsModel.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

#import "MKCRInterface.h"
#import "MKCRInterface+MKCRConfig.h"

@interface MKCRNetworkSettingsModel ()

@property (nonatomic, strong)dispatch_queue_t readQueue;

@property (nonatomic, strong)dispatch_semaphore_t semaphore;

@end

@implementation MKCRNetworkSettingsModel

- (void)readDataWithSucBlock:(void (^)(void))sucBlock failedBlock:(void (^)(NSError *error))failedBlock {
    dispatch_async(self.readQueue, ^{
        if (![self readNetworkType]) {
            [self operationFailedBlockWithMsg:@"Read Network Type Error" block:failedBlock];
            return;
        }
        
        if (![self readWifiSSID]) {
            [self operationFailedBlockWithMsg:@"Read WIFI SSID Error" block:failedBlock];
            return;
        }
        
        if (![self readWifiPassword]) {
            [self operationFailedBlockWithMsg:@"Read WIFI Password Error" block:failedBlock];
            return;
        }
        
        if (![self readWifiDHCPStatus]) {
            [self operationFailedBlockWithMsg:@"Read Wifi DHCP Error" block:failedBlock];
            return;
        }
        
        if (![self readWifiIpAddress]) {
            [self operationFailedBlockWithMsg:@"Read Wifi Ip Error" block:failedBlock];
            return;
        }
        
        if (![self readEthernetDHCPStatus]) {
            [self operationFailedBlockWithMsg:@"Read Ethernet DHCP Error" block:failedBlock];
            return;
        }
        
        if (![self readEthernetIpAddress]) {
            [self operationFailedBlockWithMsg:@"Read Ethernet Ip Error" block:failedBlock];
            return;
        }
        
        if (![self readApn]) {
            [self operationFailedBlockWithMsg:@"Read APN Error" block:failedBlock];
            return;
        }
        
        if (![self readApnUsername]) {
            [self operationFailedBlockWithMsg:@"Read APN Username Error" block:failedBlock];
            return;
        }
        
        if (![self readApnPassword]) {
            [self operationFailedBlockWithMsg:@"Read APN Password Error" block:failedBlock];
            return;
        }
        
        if (![self readPin]) {
            [self operationFailedBlockWithMsg:@"Read PIN Error" block:failedBlock];
            return;
        }
        
        moko_dispatch_main_safe(^{
            if (sucBlock) {
                sucBlock();
            }
        });
    });
}

- (void)configDataWithSucBlock:(void (^)(void))sucBlock failedBlock:(void (^)(NSError *error))failedBlock {
    dispatch_async(self.readQueue, ^{
        NSString *msg = [self checkMsg];
        if (ValidStr(msg)) {
            [self operationFailedBlockWithMsg:msg block:failedBlock];
            return;
        }
        if (![self configNetworkType]) {
            [self operationFailedBlockWithMsg:@"Config Network Type Error" block:failedBlock];
            return;
        }
        if (self.netType == 0 || self.netType == 3 || self.netType == 4) {
            //ETH/ETH_WIFI/ETH_WIFI_CELLULAR
            if (![self configEthernetDHCPStatus]) {
                [self operationFailedBlockWithMsg:@"Config DHCP Error" block:failedBlock];
                return;
            }
            if (!self.ethernet_dhcp) {
                if (![self configEthernetIpAddress]) {
                    [self operationFailedBlockWithMsg:@"Config IP Error" block:failedBlock];
                    return;
                }
            }
            if (self.netType == 0) {
                //ETH
                moko_dispatch_main_safe(^{
                    if (sucBlock) {
                        sucBlock();
                    }
                });
                return;
            }
        }
        
        if (self.netType == 1 || self.netType == 3 || self.netType == 4) {
            //WIFI/ETH_WIFI/ETH_WIFI_CELLULAR
            if (![self configWifiSSID]) {
                [self operationFailedBlockWithMsg:@"Config WIFI SSID Error" block:failedBlock];
                return;
            }
            if (![self configWifiPassword]) {
                [self operationFailedBlockWithMsg:@"Config WIFI Password Error" block:failedBlock];
                return;
            }
            
            if (![self configWifiDHCPStatus]) {
                [self operationFailedBlockWithMsg:@"Config DHCP Error" block:failedBlock];
                return;
            }
            if (!self.wifi_dhcp) {
                if (![self configWifiIpAddress]) {
                    [self operationFailedBlockWithMsg:@"Config IP Error" block:failedBlock];
                    return;
                }
            }
            
            if (self.netType == 1 || self.netType == 3) {
                //WIFI
                moko_dispatch_main_safe(^{
                    if (sucBlock) {
                        sucBlock();
                    }
                });
                return;
            }
        }
        
        //Cellular/ETH_WIFI_CELLULAR
        if (![self configApn]) {
            [self operationFailedBlockWithMsg:@"Config APN Error" block:failedBlock];
            return;
        }
        
        if (![self configApnUsername]) {
            [self operationFailedBlockWithMsg:@"Config APN Username Error" block:failedBlock];
            return;
        }
        
        if (![self configApnPassword]) {
            [self operationFailedBlockWithMsg:@"Config APN Password Error" block:failedBlock];
            return;
        }
        
        if (![self configPin]) {
            [self operationFailedBlockWithMsg:@"Config PIN Error" block:failedBlock];
            return;
        }
        
        moko_dispatch_main_safe(^{
            if (sucBlock) {
                sucBlock();
            }
        });
    });
}

#pragma mark - interface

#pragma mark - Network Type

- (BOOL)readNetworkType {
    __block BOOL success = NO;
    [MKCRInterface cr_readNetworkTypeWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.netType = [returnData[@"result"][@"type"] integerValue];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configNetworkType {
    __block BOOL success = NO;
    [MKCRInterface cr_configNetworkType:self.netType sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

#pragma mark - Wifi Settings

- (BOOL)readWifiSSID {
    __block BOOL success = NO;
    [MKCRInterface cr_readWIFISSIDWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.wifi_ssid = returnData[@"result"][@"ssid"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configWifiSSID {
    __block BOOL success = NO;
    [MKCRInterface cr_configWIFISSID:self.wifi_ssid sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readWifiPassword {
    __block BOOL success = NO;
    [MKCRInterface cr_readWIFIPasswordWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.wifi_psd = returnData[@"result"][@"password"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configWifiPassword {
    __block BOOL success = NO;
    [MKCRInterface cr_configWIFIPassword:self.wifi_psd sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

#pragma mark - Wifi Network Settings
- (BOOL)readWifiDHCPStatus {
    __block BOOL success = NO;
    [MKCRInterface cr_readWIFIDHCPStatusWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.wifi_dhcp = [returnData[@"result"][@"isOn"] boolValue];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configWifiDHCPStatus {
    __block BOOL success = NO;
    [MKCRInterface cr_configWIFIDHCPStatus:self.wifi_dhcp sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readWifiIpAddress {
    __block BOOL success = NO;
    [MKCRInterface cr_readWIFINetworkIpInfosWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.wifi_ip = returnData[@"result"][@"ip"];
        self.wifi_mask = returnData[@"result"][@"mask"];
        self.wifi_gateway = returnData[@"result"][@"gateway"];
        self.wifi_dns = returnData[@"result"][@"dns"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configWifiIpAddress {
    __block BOOL success = NO;
    [MKCRInterface cr_configWIFIIpAddress:self.wifi_ip
                                     mask:self.wifi_mask
                                  gateway:self.wifi_gateway
                                      dns:self.wifi_dns
                                 sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    }
                          failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

#pragma mark - Ethernet Network Settings
- (BOOL)readEthernetDHCPStatus {
    __block BOOL success = NO;
    [MKCRInterface cr_readEthernetDHCPStatusWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.ethernet_dhcp = [returnData[@"result"][@"isOn"] boolValue];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configEthernetDHCPStatus {
    __block BOOL success = NO;
    [MKCRInterface cr_configEthernetDHCPStatus:self.ethernet_dhcp sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readEthernetIpAddress {
    __block BOOL success = NO;
    [MKCRInterface cr_readEthernetNetworkIpInfosWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.ethernet_ip = returnData[@"result"][@"ip"];
        self.ethernet_mask = returnData[@"result"][@"mask"];
        self.ethernet_gateway = returnData[@"result"][@"gateway"];
        self.ethernet_dns = returnData[@"result"][@"dns"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configEthernetIpAddress {
    __block BOOL success = NO;
    [MKCRInterface cr_configEthernetIpAddress:self.ethernet_ip
                                         mask:self.ethernet_mask
                                      gateway:self.ethernet_gateway
                                          dns:self.ethernet_dns
                                     sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    }
                          failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

#pragma mark - APN
- (BOOL)readApn {
    __block BOOL success = NO;
    [MKCRInterface cr_readApnWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.apn = returnData[@"result"][@"apn"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configApn {
    __block BOOL success = NO;
    [MKCRInterface cr_configApn:self.apn sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readApnUsername {
    __block BOOL success = NO;
    [MKCRInterface cr_readApnUsernameWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.apn_username = returnData[@"result"][@"username"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configApnUsername {
    __block BOOL success = NO;
    [MKCRInterface cr_configApnUsername:self.apn_username sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readApnPassword {
    __block BOOL success = NO;
    [MKCRInterface cr_readApnPasswordWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.apn_psd = returnData[@"result"][@"password"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configApnPassword {
    __block BOOL success = NO;
    [MKCRInterface cr_configApnPassword:self.apn_psd sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readPin {
    __block BOOL success = NO;
    [MKCRInterface cr_readPinWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.pin = returnData[@"result"][@"pin"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configPin {
    __block BOOL success = NO;
    [MKCRInterface cr_configPin:self.pin sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

#pragma mark - private method

- (NSString *)checkMsg {
    if (self.netType == 0 || self.netType == 3 || self.netType == 4) {
        //ETH
        NSString *networkMsg = [self checkNetworkMsg];
        if (ValidStr(networkMsg)) {
            return networkMsg;
        }
    }
    
    if (self.netType == 1 || self.netType == 3 || self.netType == 4) {
        //Wifi
        NSString *wifiMsg = [self checkWifiMsg];
        if (ValidStr(wifiMsg)) {
            return wifiMsg;
        }
    }
    
    if (self.netType == 2 || self.netType == 4) {
        //CELLULAR
        NSString *cellularMsg = [self checkCellularMsg];
        if (ValidStr(cellularMsg)) {
            return cellularMsg;
        }
    }
    
    return @"";
}

- (NSString *)checkNetworkMsg {
    //ethernet
    if (self.ethernet_dhcp) {
        return @"";
    }
    if (![self.ethernet_ip regularExpressions:isIPAddress]) {
        return @"IP Error";
    }
    if (![self.ethernet_mask regularExpressions:isIPAddress]) {
        return @"Mask Error";
    }
    if (![self.ethernet_gateway regularExpressions:isIPAddress]) {
        return @"Gateway Error";
    }
    if (![self.ethernet_dns regularExpressions:isIPAddress]) {
        return @"DNS Error";
    }
    return @"";
}

- (NSString *)checkWifiMsg {
    if (!ValidStr(self.wifi_ssid) || self.wifi_ssid.length > 32) {
        return @"ssid error";
    }
    if (self.wifi_psd.length > 64) {
        return @"password error";
    }
    if (self.wifi_dhcp) {
        return @"";
    }
    if (![self.wifi_ip regularExpressions:isIPAddress]) {
        return @"IP Error";
    }
    if (![self.wifi_mask regularExpressions:isIPAddress]) {
        return @"Mask Error";
    }
    if (![self.wifi_gateway regularExpressions:isIPAddress]) {
        return @"Gateway Error";
    }
    if (![self.wifi_dns regularExpressions:isIPAddress]) {
        return @"DNS Error";
    }
    
    return @"";
}

- (NSString *)checkCellularMsg {
    if (self.apn.length > 100) {
        return @"apn error";
    }
    if (self.apn_username.length > 100) {
        return @"apn username error";
    }
    if (self.apn_psd.length > 100) {
        return @"apn password error";
    }
    if ((self.pin.length > 0 && self.pin.length < 4) || self.pin.length > 8) {
        return @"pin error";
    }
    
    return @"";
}

- (void)operationFailedBlockWithMsg:(NSString *)msg block:(void (^)(NSError *error))block {
    moko_dispatch_main_safe(^{
        NSError *error = [[NSError alloc] initWithDomain:@"NetworkSettings"
                                                    code:-999
                                                userInfo:@{@"errorInfo":msg}];
        block(error);
    })
}

#pragma mark - getter
- (dispatch_semaphore_t)semaphore {
    if (!_semaphore) {
        _semaphore = dispatch_semaphore_create(0);
    }
    return _semaphore;
}

- (dispatch_queue_t)readQueue {
    if (!_readQueue) {
        _readQueue = dispatch_queue_create("WifiSettingsQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _readQueue;
}

@end
