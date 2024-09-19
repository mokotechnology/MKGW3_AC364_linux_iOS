//
//  MKCRServerForDeviceModel.m
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2024/09/2.
//  Copyright © 2023 aadyx2007@163.com. All rights reserved.
//

#import "MKCRServerForDeviceModel.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

#import "MKCRInterface+MKCRConfig.h"

static NSString *const defaultSubTopic = @"{device_name}/{device_id}/app_to_device";
static NSString *const defaultPubTopic = @"{device_name}/{device_id}/device_to_app";

@interface MKCRServerForDeviceModel ()

@property (nonatomic, strong)dispatch_queue_t configQueue;

@property (nonatomic, strong)dispatch_semaphore_t semaphore;

@end

@implementation MKCRServerForDeviceModel

- (NSString *)checkParams {
    if (!ValidStr(self.host) || self.host.length > 64 || ![self.host isAsciiString]) {
        return @"Host error";
    }
    if (!ValidStr(self.port) || [self.port integerValue] < 1 || [self.port integerValue] > 65535) {
        return @"Port error";
    }
    if (!ValidStr(self.clientID) || self.clientID.length > 64 || ![self.clientID isAsciiString]) {
        return @"ClientID error";
    }
    if (!ValidStr(self.broadPubTopic) || self.broadPubTopic.length > 128 || ![self.broadPubTopic isAsciiString]) {
        return @"Broad PublishTopic error";
    }
    if (self.broadQos < 0 || self.broadQos > 2) {
        return @"Broad Qos error";
    }
    if (!ValidStr(self.gatewayPubTopic) || self.gatewayPubTopic.length > 128 || ![self.gatewayPubTopic isAsciiString]) {
        return @"Gateway PublishTopic error";
    }
    if (!ValidStr(self.gatewaySubTopic) || self.gatewaySubTopic.length > 128 || ![self.gatewaySubTopic isAsciiString]) {
        return @"Gateway SublishTopic error";
    }
    if (self.gatewayQos < 0 || self.gatewayQos > 2) {
        return @"Gateway Qos error";
    }
    if (!ValidStr(self.devicePubTopic) || self.devicePubTopic.length > 128 || ![self.devicePubTopic isAsciiString]) {
        return @"Device PublishTopic error";
    }
    if (!ValidStr(self.deviceSubTopic) || self.deviceSubTopic.length > 128 || ![self.deviceSubTopic isAsciiString]) {
        return @"Device SublishTopic error";
    }
    if (self.deviceQos < 0 || self.deviceQos > 2) {
        return @"Device Qos error";
    }
    if (!ValidStr(self.keepAlive) || [self.keepAlive integerValue] < 10 || [self.keepAlive integerValue] > 120) {
        return @"KeepAlive error";
    }
    if (self.userName.length > 256 || (ValidStr(self.userName) && ![self.userName isAsciiString])) {
        return @"UserName error";
    }
    if (self.password.length > 256 || (ValidStr(self.password) && ![self.password isAsciiString])) {
        return @"Password error";
    }
    if (self.sslIsOn) {
        if (self.certificate < 0 || self.certificate > 2) {
            return @"Certificate error";
        }
        if (self.certificate == 0) {
            return @"";
        }
        if (!ValidStr(self.caFileName)) {
            return @"CA File cannot be empty.";
        }
        if (self.certificate == 2 && (!ValidStr(self.clientKeyName) || !ValidStr(self.clientCertName))) {
            return @"Client File cannot be empty.";
        }
    }
    
    return @"";
}

- (void)updateValue:(MKCRServerForDeviceModel *)model {
    if (!model || ![model isKindOfClass:MKCRServerForDeviceModel.class]) {
        return;
    }
    self.host = model.host;
    self.port = model.port;
    self.clientID = model.clientID;
    
    self.broadPubTopic = model.broadPubTopic;
    self.broadQos = model.broadQos;
    
    self.gatewayPubTopic = model.gatewayPubTopic;
    self.gatewaySubTopic = model.gatewaySubTopic;
    self.gatewayQos = model.gatewayQos;
    
    self.devicePubTopic = model.devicePubTopic;
    self.deviceSubTopic = model.deviceSubTopic;
    self.deviceQos = model.deviceQos;
    
    self.cleanSession = model.cleanSession;
    
    self.keepAlive = model.keepAlive;
    self.userName = model.userName;
    self.password = model.password;
    self.sslIsOn = model.sslIsOn;
    self.certificate = model.certificate;
    self.caFileName = model.caFileName;
    self.clientKeyName = model.clientKeyName;
    self.clientCertName = model.clientCertName;
}

- (void)readDataWithSucBlock:(void (^)(void))sucBlock failedBlock:(void (^)(NSError *error))failedBlock {
    dispatch_async(self.configQueue, ^{
        if (![self readDeviceMac]) {
            [self operationFailedBlockWithMsg:@"Read Mac Address Timeout" block:failedBlock];
            return;
        }
        if (![self readDeviceName]) {
            [self operationFailedBlockWithMsg:@"Read Device Name Timeout" block:failedBlock];
            return;
        }
        if (![self readHost]) {
            [self operationFailedBlockWithMsg:@"Read Host Timeout" block:failedBlock];
            return;
        }
        if (![self readPort]) {
            [self operationFailedBlockWithMsg:@"Read Port Timeout" block:failedBlock];
            return;
        }
        if (![self readClientID]) {
            [self operationFailedBlockWithMsg:@"Read Client ID Timeout" block:failedBlock];
            return;
        }
        if (![self readUsername]) {
            [self operationFailedBlockWithMsg:@"Read Username Timeout" block:failedBlock];
            return;
        }
        if (![self readPassword]) {
            [self operationFailedBlockWithMsg:@"Read Password Timeout" block:failedBlock];
            return;
        }
        if (![self readCleanSession]) {
            [self operationFailedBlockWithMsg:@"Read Clean Session Timeout" block:failedBlock];
            return;
        }
        if (![self readKeepAlive]) {
            [self operationFailedBlockWithMsg:@"Read KeepAlive Timeout" block:failedBlock];
            return;
        }
        if (![self readBroadQos]) {
            [self operationFailedBlockWithMsg:@"Read Broad Qos Timeout" block:failedBlock];
            return;
        }
        if (![self readBroadPublish]) {
            [self operationFailedBlockWithMsg:@"Read Broad Pubscribe Topic Timeout" block:failedBlock];
            return;
        }
        if (![self readGatewayQos]) {
            [self operationFailedBlockWithMsg:@"Read Gateway Qos Timeout" block:failedBlock];
            return;
        }
        if (![self readGatewayPublish]) {
            [self operationFailedBlockWithMsg:@"Read Gateway Pubscribe Topic Timeout" block:failedBlock];
            return;
        }
        if (![self readGatewaySublish]) {
            [self operationFailedBlockWithMsg:@"Read Gateway Subscribe Topic Timeout" block:failedBlock];
            return;
        }
        if (![self readDeviceQos]) {
            [self operationFailedBlockWithMsg:@"Read Device Qos Timeout" block:failedBlock];
            return;
        }
        if (![self readDevicePublish]) {
            [self operationFailedBlockWithMsg:@"Read Device Pubscribe Topic Timeout" block:failedBlock];
            return;
        }
        if (![self readDeviceSublish]) {
            [self operationFailedBlockWithMsg:@"Read Device Subscribe Topic Timeout" block:failedBlock];
            return;
        }
        if (![self readSSLStatus]) {
            [self operationFailedBlockWithMsg:@"Read SSL Status Timeout" block:failedBlock];
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
    dispatch_async(self.configQueue, ^{
        NSString *checkMsg = [self checkParams];
        if (ValidStr(checkMsg)) {
            [self operationFailedBlockWithMsg:checkMsg block:failedBlock];
            return;
        }
        if (![self configHost]) {
            [self operationFailedBlockWithMsg:@"Config Host Timeout" block:failedBlock];
            return;
        }
        if (![self configPort]) {
            [self operationFailedBlockWithMsg:@"Config Port Timeout" block:failedBlock];
            return;
        }
        if (![self configClientID]) {
            [self operationFailedBlockWithMsg:@"Config Client Id Timeout" block:failedBlock];
            return;
        }
        if (![self configUserName]) {
            [self operationFailedBlockWithMsg:@"Config UserName Timeout" block:failedBlock];
            return;
        }
        if (![self configPassword]) {
            [self operationFailedBlockWithMsg:@"Config Password Timeout" block:failedBlock];
            return;
        }
        if (![self configCleanSession]) {
            [self operationFailedBlockWithMsg:@"Config Clean Session Timeout" block:failedBlock];
            return;
        }
        if (![self configKeepAlive]) {
            [self operationFailedBlockWithMsg:@"Config Keep Alive Timeout" block:failedBlock];
            return;
        }
        if (![self configBroadQos]) {
            [self operationFailedBlockWithMsg:@"Config Broad Qos Timeout" block:failedBlock];
            return;
        }
        if (![self configBroadPublish]) {
            [self operationFailedBlockWithMsg:@"Config Broad Pubscribe Topic Timeout" block:failedBlock];
            return;
        }
        if (![self configGatewayQos]) {
            [self operationFailedBlockWithMsg:@"Config Gateway Qos Timeout" block:failedBlock];
            return;
        }
        if (![self configGatewayPublish]) {
            [self operationFailedBlockWithMsg:@"Config Gateway Pubscribe Topic Timeout" block:failedBlock];
            return;
        }
        if (![self configGatewaySublish]) {
            [self operationFailedBlockWithMsg:@"Config Gateway Subscribe Topic Timeout" block:failedBlock];
            return;
        }
        if (![self configDeviceQos]) {
            [self operationFailedBlockWithMsg:@"Config Device Qos Timeout" block:failedBlock];
            return;
        }
        if (![self configDevicePublish]) {
            [self operationFailedBlockWithMsg:@"Config Device Pubscribe Topic Timeout" block:failedBlock];
            return;
        }
        if (![self configDeviceSublish]) {
            [self operationFailedBlockWithMsg:@"Config Device Subscribe Topic Timeout" block:failedBlock];
            return;
        }
        
        if (![self configSSLStatus]) {
            [self operationFailedBlockWithMsg:@"Config SSL Status Timeout" block:failedBlock];
            return;
        }
        if (self.sslIsOn && self.certificate > 0) {
            if (![self configCAFile]) {
                [self operationFailedBlockWithMsg:@"Config CA File Error" block:failedBlock];
                return;
            }
            if (self.certificate == 2) {
                //双向验证
                if (![self configClientKey]) {
                    [self operationFailedBlockWithMsg:@"Config Client Key Error" block:failedBlock];
                    return;
                }
                if (![self configClientCert]) {
                    [self operationFailedBlockWithMsg:@"Config Client Cert Error" block:failedBlock];
                    return;
                }
            }
        }
        moko_dispatch_main_safe(^{
            if (sucBlock) {
                sucBlock();
            }
        });
    });
}

#pragma mark - interface
- (BOOL)readDeviceMac {
    __block BOOL success = NO;
    [MKCRInterface cr_readDeviceWifiSTAMacAddressWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.macAddress = returnData[@"result"][@"macAddress"];
        self.macAddress = [self.macAddress stringByReplacingOccurrencesOfString:@":" withString:@""];
        self.macAddress = [self.macAddress lowercaseString];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readDeviceName {
    __block BOOL success = NO;
    [MKCRInterface cr_readDeviceNameWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.deviceName = returnData[@"result"][@"deviceName"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readHost {
    __block BOOL success = NO;
    [MKCRInterface cr_readServerHostWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.host = returnData[@"result"][@"host"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configHost {
    __block BOOL success = NO;
    [MKCRInterface cr_configServerHost:self.host sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readPort {
    __block BOOL success = NO;
    [MKCRInterface cr_readServerPortWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.port = returnData[@"result"][@"port"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configPort {
    __block BOOL success = NO;
    [MKCRInterface cr_configServerPort:[self.port integerValue] sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readClientID {
    __block BOOL success = NO;
    [MKCRInterface cr_readClientIDWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.clientID = returnData[@"result"][@"clientID"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configClientID {
    __block BOOL success = NO;
    [MKCRInterface cr_configClientID:self.clientID sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readUsername {
    __block BOOL success = NO;
    [MKCRInterface cr_readServerUserNameWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.userName = returnData[@"result"][@"username"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configUserName {
    __block BOOL success = NO;
    [MKCRInterface cr_configServerUserName:self.userName sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readPassword {
    __block BOOL success = NO;
    [MKCRInterface cr_readServerPasswordWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.password = returnData[@"result"][@"password"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configPassword {
    __block BOOL success = NO;
    [MKCRInterface cr_configServerPassword:self.password sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readCleanSession {
    __block BOOL success = NO;
    [MKCRInterface cr_readServerCleanSessionWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.cleanSession = [returnData[@"result"][@"clean"] boolValue];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configCleanSession {
    __block BOOL success = NO;
    [MKCRInterface cr_configServerCleanSession:self.cleanSession sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readKeepAlive {
    __block BOOL success = NO;
    [MKCRInterface cr_readServerKeepAliveWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.keepAlive = returnData[@"result"][@"keepAlive"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configKeepAlive {
    __block BOOL success = NO;
    [MKCRInterface cr_configServerKeepAlive:[self.keepAlive integerValue] sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readBroadPublish {
    __block BOOL success = NO;
    [MKCRInterface cr_readBroadPubTopicWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.broadPubTopic = returnData[@"result"][@"topic"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configBroadPublish {
    __block BOOL success = NO;
    NSString *topic = self.broadPubTopic;
    [MKCRInterface cr_configBroadPubTopic:topic sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readBroadQos {
    __block BOOL success = NO;
    [MKCRInterface cr_readBroadcastQosWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.broadQos = [returnData[@"result"][@"qos"] integerValue];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configBroadQos {
    __block BOOL success = NO;
    [MKCRInterface cr_configBroadcastQos:self.broadQos sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readGatewayPublish {
    __block BOOL success = NO;
    [MKCRInterface cr_readGatewayPubTopicWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.gatewayPubTopic = returnData[@"result"][@"topic"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configGatewayPublish {
    __block BOOL success = NO;
    NSString *topic = self.gatewayPubTopic;
    [MKCRInterface cr_configGatewayPubTopic:topic sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readGatewaySublish {
    __block BOOL success = NO;
    [MKCRInterface cr_readGatewaySubTopicWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.gatewaySubTopic = returnData[@"result"][@"topic"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configGatewaySublish {
    __block BOOL success = NO;
    NSString *topic = self.gatewaySubTopic;
    [MKCRInterface cr_configGatewaySubTopic:topic sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readGatewayQos {
    __block BOOL success = NO;
    [MKCRInterface cr_readGatewayQosWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.gatewayQos = [returnData[@"result"][@"qos"] integerValue];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configGatewayQos {
    __block BOOL success = NO;
    [MKCRInterface cr_configGatewayQos:self.gatewayQos sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}


- (BOOL)readDevicePublish {
    __block BOOL success = NO;
    [MKCRInterface cr_readDevicePubTopicWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.devicePubTopic = returnData[@"result"][@"topic"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configDevicePublish {
    __block BOOL success = NO;
    NSString *topic = self.devicePubTopic;
    [MKCRInterface cr_configDevicePubTopic:topic sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readDeviceSublish {
    __block BOOL success = NO;
    [MKCRInterface cr_readDeviceSubTopicWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.deviceSubTopic = returnData[@"result"][@"topic"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configDeviceSublish {
    __block BOOL success = NO;
    NSString *topic = self.deviceSubTopic;
    [MKCRInterface cr_configDeviceSubTopic:topic sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readDeviceQos {
    __block BOOL success = NO;
    [MKCRInterface cr_readDeviceQosWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.deviceQos = [returnData[@"result"][@"qos"] integerValue];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configDeviceQos {
    __block BOOL success = NO;
    [MKCRInterface cr_configDeviceQos:self.deviceQos sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readSSLStatus {
    __block BOOL success = NO;
    [MKCRInterface cr_readConnectModeWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        NSInteger value = [returnData[@"result"][@"mode"] integerValue];
        self.sslIsOn = YES;
        if (value == 0) {
            //TCP
            self.sslIsOn = NO;
        }else if (value == 1) {
            self.certificate = 0;
        }else if (value == 2) {
            self.certificate = 1;
        }
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configSSLStatus {
    __block BOOL success = NO;
    mk_cr_connectMode mode = mk_cr_connectMode_TCP;
    if (self.sslIsOn) {
        if (self.certificate == 0) {
            mode = mk_cr_connectMode_CACertificate;
        }else if (self.certificate == 1) {
            mode = mk_cr_connectMode_SelfSignedCertificates;
        }
    }
    [MKCRInterface cr_configConnectMode:mode sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configCAFile {
    __block BOOL success = NO;
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [document stringByAppendingPathComponent:self.caFileName];
    NSData *caData = [NSData dataWithContentsOfFile:filePath];
    if (!ValidData(caData)) {
        return NO;
    }
    [MKCRInterface cr_configCAFile:caData sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configClientKey {
    __block BOOL success = NO;
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [document stringByAppendingPathComponent:self.clientKeyName];
    NSData *clientKeyData = [NSData dataWithContentsOfFile:filePath];
    if (!ValidData(clientKeyData)) {
        return NO;
    }
    [MKCRInterface cr_configClientPrivateKey:clientKeyData sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configClientCert {
    __block BOOL success = NO;
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [document stringByAppendingPathComponent:self.clientCertName];
    NSData *clientCertData = [NSData dataWithContentsOfFile:filePath];
    if (!ValidData(clientCertData)) {
        return NO;
    }
    [MKCRInterface cr_configClientCert:clientCertData sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

#pragma mark - private method
- (void)operationFailedBlockWithMsg:(NSString *)msg block:(void (^)(NSError *error))block {
    moko_dispatch_main_safe(^{
        NSError *error = [[NSError alloc] initWithDomain:@"serverParams"
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

- (dispatch_queue_t)configQueue {
    if (!_configQueue) {
        _configQueue = dispatch_queue_create("serverSettingsQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _configQueue;
}

@end
