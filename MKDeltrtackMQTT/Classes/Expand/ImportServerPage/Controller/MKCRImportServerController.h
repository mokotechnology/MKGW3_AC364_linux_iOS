//
//  MKCRImportServerController.h
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2023/9/19.
//  Copyright © 2023 aadyx2007@163.com. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseViewController.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKCRImportServerControllerDelegate <NSObject>

- (void)cr_selectedServerParams:(NSString *)fileName;

@end

@interface MKCRImportServerController : MKBaseViewController

@property (nonatomic, weak)id <MKCRImportServerControllerDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
