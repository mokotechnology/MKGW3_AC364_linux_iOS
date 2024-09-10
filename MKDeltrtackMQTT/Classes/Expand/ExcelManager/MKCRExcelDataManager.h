//
//  MKCRExcelDataManager.h
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2023/12/25.
//  Copyright © 2023 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKCRExcelDataManager : NSObject

+ (void)parseMacBlackList:(NSString *)excelName
                 sucBlock:(void (^)(NSArray *blackList))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
