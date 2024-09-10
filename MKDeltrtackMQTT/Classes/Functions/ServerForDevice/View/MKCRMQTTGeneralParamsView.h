//
//  MKCRMQTTGeneralParamsView.h
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2024/9/2.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKCRMQTTGeneralParamsViewModel : NSObject

@property (nonatomic, assign)BOOL clean;

@property (nonatomic, copy)NSString *keepAlive;

@end

@protocol MKCRMQTTGeneralParamsViewDelegate <NSObject>

- (void)cr_generalParams_cleanSessionStatusChanged:(BOOL)isOn;

- (void)cr_generalParams_KeepAliveChanged:(NSString *)keepAlive;

@end

@interface MKCRMQTTGeneralParamsView : UIView

@property (nonatomic, strong)MKCRMQTTGeneralParamsViewModel *dataModel;

@property (nonatomic, weak)id <MKCRMQTTGeneralParamsViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
