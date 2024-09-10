//
//  MKCRScanPageCell.h
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2021/10/21.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKCRScanPageCellDelegate <NSObject>

/// 连接按钮点击事件
/// @param index 当前cell的row
- (void)cr_scanCellConnectButtonPressed:(NSInteger)index;

@end

@class MKCRScanPageModel;
@interface MKCRScanPageCell : MKBaseCell

@property (nonatomic, strong)MKCRScanPageModel *dataModel;

@property (nonatomic, weak)id <MKCRScanPageCellDelegate>delegate;

+ (MKCRScanPageCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
