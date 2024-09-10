//
//  MKCRNearbyWifiController.h
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2024/9/5.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseViewController.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKCRNearbyWifiControllerDelegate <NSObject>

- (void)cr_nearbyWifiController_selectedWifi:(NSString *)ssid;

@end

@interface MKCRNearbyWifiController : MKBaseViewController

@property (nonatomic, weak)id <MKCRNearbyWifiControllerDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
