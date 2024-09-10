//
//  MKCRDeviceInfoModel.h
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2024/9/4.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKCRDeviceInfoModel : NSObject

@property (nonatomic, copy)NSString *deviceName;

@property (nonatomic, copy)NSString *productMode;

@property (nonatomic, copy)NSString *manu;

@property (nonatomic, copy)NSString *firmware;

@property (nonatomic, copy)NSString *hardware;

@property (nonatomic, copy)NSString *ethernetMac;

@property (nonatomic, copy)NSString *wifiStaMac;

@property (nonatomic, copy)NSString *btMac;

@property (nonatomic, copy)NSString *imei;

- (void)readDataWithSucBlock:(void (^)(void))sucBlock failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
