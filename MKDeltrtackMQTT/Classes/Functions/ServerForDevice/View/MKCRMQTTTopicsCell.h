//
//  MKCRMQTTTopicsCell.h
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2024/9/2.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKCRMQTTTopicsCellModel : NSObject

@property (nonatomic, assign)NSInteger index;

@property (nonatomic, assign)BOOL showSubTopic;

@property (nonatomic, copy)NSString *pubMsg;

@property (nonatomic, copy)NSString *pubTopic;

@property (nonatomic, copy)NSString *subMsg;

@property (nonatomic, copy)NSString *subTopic;

@property (nonatomic, copy)NSString *qosMsg;

@property (nonatomic, assign)NSInteger qos;

@end

@protocol MKCRMQTTTopicsCellDelegate <NSObject>

- (void)cr_mqttTopicsCell_pubTopicChanged:(NSInteger)index topic:(NSString *)topic;

- (void)cr_mqttTopicsCell_subTopicChanged:(NSInteger)index topic:(NSString *)topic;

- (void)cr_mqttTopicsCell_qosChanged:(NSInteger)index qos:(NSInteger)qos;

@end

@interface MKCRMQTTTopicsCell : MKBaseCell

@property (nonatomic, strong)MKCRMQTTTopicsCellModel *dataModel;

@property (nonatomic, weak)id <MKCRMQTTTopicsCellDelegate>delegate;

+ (MKCRMQTTTopicsCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
