//
//  MKCRServerForDeviceModel.h
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2024/09/2.
//  Copyright © 2023 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKCRServerForDeviceModel : NSObject

@property (nonatomic, copy)NSString *host;

@property (nonatomic, copy)NSString *port;

@property (nonatomic, copy)NSString *clientID;

@property (nonatomic, copy)NSString *broadPubTopic;

@property (nonatomic, assign)NSInteger broadQos;

@property (nonatomic, copy)NSString *gatewayPubTopic;

@property (nonatomic, copy)NSString *gatewaySubTopic;

@property (nonatomic, assign)NSInteger gatewayQos;

@property (nonatomic, copy)NSString *devicePubTopic;

@property (nonatomic, copy)NSString *deviceSubTopic;

@property (nonatomic, assign)NSInteger deviceQos;

@property (nonatomic, assign)BOOL cleanSession;

@property (nonatomic, copy)NSString *keepAlive;

@property (nonatomic, copy)NSString *userName;

@property (nonatomic, copy)NSString *password;

@property (nonatomic, assign)BOOL sslIsOn;

/// 0:CA signed server certificate     1:CA certificate     2:Self signed certificates
@property (nonatomic, assign)NSInteger certificate;

@property (nonatomic, copy)NSString *caFileName;

@property (nonatomic, copy)NSString *clientKeyName;

@property (nonatomic, copy)NSString *clientCertName;

@property (nonatomic, copy)NSString *macAddress;

@property (nonatomic, copy)NSString *deviceName;

- (NSString *)checkParams;

/// 更新数据
/// @param model 数据源
- (void)updateValue:(MKCRServerForDeviceModel *)model;

- (void)readDataWithSucBlock:(void (^)(void))sucBlock failedBlock:(void (^)(NSError *error))failedBlock;

- (void)configDataWithSucBlock:(void (^)(void))sucBlock failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
