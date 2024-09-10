//
//  MKCRNearbyWifiCell.h
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2024/9/5.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKCRNearbyWifiCellModel : NSObject

@property (nonatomic, copy)NSString *ssid;

@property (nonatomic, copy)NSString *bssid;

@property (nonatomic, strong)NSNumber *rssi;

@end

@interface MKCRNearbyWifiCell : MKBaseCell

@property (nonatomic, strong)MKCRNearbyWifiCellModel *dataModel;

+ (MKCRNearbyWifiCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
