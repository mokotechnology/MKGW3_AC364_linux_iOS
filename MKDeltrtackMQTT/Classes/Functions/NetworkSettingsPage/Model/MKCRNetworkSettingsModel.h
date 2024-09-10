//
//  MKCRNetworkSettingsModel.h
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2024/9/1.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKCRNetworkSettingsModel : NSObject


/// 0:ETH   1:WIFI  2:CELLULAR  3:ETH_WIFI  4:ETH_WIFI_CELLULAR
@property (nonatomic, assign)NSInteger netType;

#pragma mark - Wifi Network Settings

@property (nonatomic, copy)NSString *wifi_ssid;

@property (nonatomic, copy)NSString *wifi_psd;

@property (nonatomic, assign)BOOL wifi_dhcp;

@property (nonatomic, copy)NSString *wifi_ip;

@property (nonatomic, copy)NSString *wifi_mask;

@property (nonatomic, copy)NSString *wifi_gateway;

@property (nonatomic, copy)NSString *wifi_dns;


#pragma mark - Ethernet Network Settings

@property (nonatomic, assign)BOOL ethernet_dhcp;

@property (nonatomic, copy)NSString *ethernet_ip;

@property (nonatomic, copy)NSString *ethernet_mask;

@property (nonatomic, copy)NSString *ethernet_gateway;

@property (nonatomic, copy)NSString *ethernet_dns;

#pragma mark - apn

@property (nonatomic, copy)NSString *apn;

@property (nonatomic, copy)NSString *apn_username;

@property (nonatomic, copy)NSString *apn_psd;

@property (nonatomic, copy)NSString *pin;

- (void)readDataWithSucBlock:(void (^)(void))sucBlock failedBlock:(void (^)(NSError *error))failedBlock;

- (void)configDataWithSucBlock:(void (^)(void))sucBlock failedBlock:(void (^)(NSError *error))failedBlock;


@end

NS_ASSUME_NONNULL_END
