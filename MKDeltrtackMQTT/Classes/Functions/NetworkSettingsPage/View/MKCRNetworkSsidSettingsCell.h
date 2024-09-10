//
//  MKCRNetworkSsidSettingsCell.h
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2024/9/1.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKCRNetworkSsidSettingsCellModel : NSObject

@property (nonatomic, copy)NSString *ssid;

@end

@protocol MKCRNetworkSsidSettingsCellDelegate <NSObject>

- (void)cr_networkSsidSettingsCell_ssidChanged:(NSString *)ssid;

- (void)cr_networkSsidSettingsCell_buttonPressed;

@end

@interface MKCRNetworkSsidSettingsCell : MKBaseCell

@property (nonatomic, strong)MKCRNetworkSsidSettingsCellModel *dataModel;

@property (nonatomic, weak)id <MKCRNetworkSsidSettingsCellDelegate>delegate;

+ (MKCRNetworkSsidSettingsCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
