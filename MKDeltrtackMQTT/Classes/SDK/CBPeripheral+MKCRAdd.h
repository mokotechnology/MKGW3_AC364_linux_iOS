//
//  CBPeripheral+MKCRAdd.h
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2024/8/27.
//  Copyright © 2024 aadyx2007@163.com. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface CBPeripheral (MKCRAdd)

/// R
@property (nonatomic, strong, readonly)CBCharacteristic *cr_manufacturer;

/// R
@property (nonatomic, strong, readonly)CBCharacteristic *cr_deviceModel;

/// R
@property (nonatomic, strong, readonly)CBCharacteristic *cr_hardware;

/// R
@property (nonatomic, strong, readonly)CBCharacteristic *cr_software;

/// R
@property (nonatomic, strong, readonly)CBCharacteristic *cr_firmware;

#pragma mark - custom

/// W/N
@property (nonatomic, strong, readonly)CBCharacteristic *cr_password;

/// N
@property (nonatomic, strong, readonly)CBCharacteristic *cr_disconnectType;

/// W/N
@property (nonatomic, strong, readonly)CBCharacteristic *cr_custom;

- (void)cr_updateCharacterWithService:(CBService *)service;

- (void)cr_updateCurrentNotifySuccess:(CBCharacteristic *)characteristic;

- (BOOL)cr_connectSuccess;

- (void)cr_setNil;

@end

NS_ASSUME_NONNULL_END
