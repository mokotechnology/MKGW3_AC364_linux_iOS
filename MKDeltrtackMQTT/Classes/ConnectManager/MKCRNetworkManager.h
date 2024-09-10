//
//  MKCRNetworkManager.h
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2024/9/5.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKCRNetworkManager : NSObject

@property (nonatomic, assign)BOOL networkSettings;

@property (nonatomic, assign)BOOL mqttSettings;

+ (MKCRNetworkManager *)shared;

+ (void)sharedDealloc;

@end

NS_ASSUME_NONNULL_END
