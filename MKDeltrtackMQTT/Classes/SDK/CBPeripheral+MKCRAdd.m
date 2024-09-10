//
//  CBPeripheral+MKCRAdd.m
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2024/8/27.
//  Copyright © 2024 aadyx2007@163.com. All rights reserved.
//

#import "CBPeripheral+MKCRAdd.h"

#import <objc/runtime.h>

static const char *cr_manufacturerKey = "cr_manufacturerKey";
static const char *cr_deviceModelKey = "cr_deviceModelKey";
static const char *cr_hardwareKey = "cr_hardwareKey";
static const char *cr_softwareKey = "cr_softwareKey";
static const char *cr_firmwareKey = "cr_firmwareKey";

static const char *cr_passwordKey = "cr_passwordKey";
static const char *cr_disconnectTypeKey = "cr_disconnectTypeKey";
static const char *cr_customKey = "cr_customKey";

static const char *cr_passwordNotifySuccessKey = "cr_passwordNotifySuccessKey";
static const char *cr_disconnectTypeNotifySuccessKey = "cr_disconnectTypeNotifySuccessKey";
static const char *cr_customNotifySuccessKey = "cr_customNotifySuccessKey";

@implementation CBPeripheral (MKCRAdd)

- (void)cr_updateCharacterWithService:(CBService *)service {
    NSArray *characteristicList = service.characteristics;
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]]) {
        //设备信息
        for (CBCharacteristic *characteristic in characteristicList) {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A24"]]) {
                objc_setAssociatedObject(self, &cr_deviceModelKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A26"]]) {
                objc_setAssociatedObject(self, &cr_firmwareKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A27"]]) {
                objc_setAssociatedObject(self, &cr_hardwareKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A28"]]) {
                objc_setAssociatedObject(self, &cr_softwareKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]]) {
                objc_setAssociatedObject(self, &cr_manufacturerKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
        return;
    }
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"AA00"]]) {
        //自定义
        for (CBCharacteristic *characteristic in characteristicList) {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"AA00"]]) {
                objc_setAssociatedObject(self, &cr_passwordKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"AA01"]]) {
                objc_setAssociatedObject(self, &cr_disconnectTypeKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"AA03"]]) {
                objc_setAssociatedObject(self, &cr_customKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
            [self setNotifyValue:YES forCharacteristic:characteristic];
        }
        return;
    }
}

- (void)cr_updateCurrentNotifySuccess:(CBCharacteristic *)characteristic {
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"AA00"]]) {
        objc_setAssociatedObject(self, &cr_passwordNotifySuccessKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return;
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"AA01"]]) {
        objc_setAssociatedObject(self, &cr_disconnectTypeNotifySuccessKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return;
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"AA03"]]) {
        objc_setAssociatedObject(self, &cr_customNotifySuccessKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return;
    }
}

- (BOOL)cr_connectSuccess {
    if (![objc_getAssociatedObject(self, &cr_customNotifySuccessKey) boolValue] || ![objc_getAssociatedObject(self, &cr_passwordNotifySuccessKey) boolValue] || ![objc_getAssociatedObject(self, &cr_disconnectTypeNotifySuccessKey) boolValue]) {
        return NO;
    }
    if (!self.cr_hardware || !self.cr_firmware) {
        return NO;
    }
    if (!self.cr_password || !self.cr_disconnectType || !self.cr_custom) {
        return NO;
    }
    return YES;
}

- (void)cr_setNil {
    objc_setAssociatedObject(self, &cr_manufacturerKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cr_deviceModelKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cr_hardwareKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cr_softwareKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cr_firmwareKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    objc_setAssociatedObject(self, &cr_passwordKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cr_disconnectTypeKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cr_customKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    objc_setAssociatedObject(self, &cr_passwordNotifySuccessKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cr_disconnectTypeNotifySuccessKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cr_customNotifySuccessKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - getter

- (CBCharacteristic *)cr_manufacturer {
    return objc_getAssociatedObject(self, &cr_manufacturerKey);
}

- (CBCharacteristic *)cr_deviceModel {
    return objc_getAssociatedObject(self, &cr_deviceModelKey);
}

- (CBCharacteristic *)cr_hardware {
    return objc_getAssociatedObject(self, &cr_hardwareKey);
}

- (CBCharacteristic *)cr_software {
    return objc_getAssociatedObject(self, &cr_softwareKey);
}

- (CBCharacteristic *)cr_firmware {
    return objc_getAssociatedObject(self, &cr_firmwareKey);
}

- (CBCharacteristic *)cr_password {
    return objc_getAssociatedObject(self, &cr_passwordKey);
}

- (CBCharacteristic *)cr_disconnectType {
    return objc_getAssociatedObject(self, &cr_disconnectTypeKey);
}

- (CBCharacteristic *)cr_custom {
    return objc_getAssociatedObject(self, &cr_customKey);
}

@end
