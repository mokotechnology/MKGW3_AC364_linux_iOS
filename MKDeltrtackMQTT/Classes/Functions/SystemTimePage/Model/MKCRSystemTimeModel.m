//
//  MKCRSystemTimeModel.m
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2024/9/4.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import "MKCRSystemTimeModel.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

#import "MKCRInterface.h"
#import "MKCRInterface+MKCRConfig.h"

@interface MKCRSystemTimeModel ()

@property (nonatomic, strong)dispatch_queue_t readQueue;

@property (nonatomic, strong)dispatch_semaphore_t semaphore;

@end

@implementation MKCRSystemTimeModel

- (void)readDataWithSucBlock:(void (^)(void))sucBlock failedBlock:(void (^)(NSError *error))failedBlock {
    dispatch_async(self.readQueue, ^{
        if (![self readSystemTime]) {
            [self operationFailedBlockWithMsg:@"Read NTP Server Error" block:failedBlock];
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
        if (![self configSystemTime]) {
            [self operationFailedBlockWithMsg:@"Config NTP Server Error" block:failedBlock];
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

- (BOOL)readSystemTime {
    __block BOOL success = NO;
    [MKCRInterface cr_readNTPServerHostWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.ntpServer = returnData[@"result"][@"host"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configSystemTime {
    __block BOOL success = NO;
    [MKCRInterface cr_configNTPServerHost:self.ntpServer sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (void)operationFailedBlockWithMsg:(NSString *)msg block:(void (^)(NSError *error))block {
    moko_dispatch_main_safe(^{
        NSError *error = [[NSError alloc] initWithDomain:@"SystemTime"
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
        _readQueue = dispatch_queue_create("SystemTimeQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _readQueue;
}

@end
