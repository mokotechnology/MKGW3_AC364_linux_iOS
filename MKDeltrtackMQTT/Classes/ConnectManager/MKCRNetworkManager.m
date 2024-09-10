//
//  MKCRNetworkManager.m
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2024/9/5.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import "MKCRNetworkManager.h"

static MKCRNetworkManager *manager = nil;
static dispatch_once_t onceToken;

@implementation MKCRNetworkManager

+ (MKCRNetworkManager *)shared {
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [MKCRNetworkManager new];
        }
    });
    return manager;
}

+ (void)sharedDealloc {
    manager = nil;
    onceToken = 0;
}

@end
