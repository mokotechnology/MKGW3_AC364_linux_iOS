//
//  MKCRNearbyWifiCell.m
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2024/9/5.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import "MKCRNearbyWifiCell.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

@implementation MKCRNearbyWifiCellModel
@end

@interface MKCRNearbyWifiCell ()

@property (nonatomic, strong)UILabel *ssidLabel;

@property (nonatomic, strong)UILabel *bssidLabel;

@property (nonatomic, strong)UILabel *rssiLabel;

@end

@implementation MKCRNearbyWifiCell


+ (MKCRNearbyWifiCell *)initCellWithTableView:(UITableView *)tableView {
    MKCRNearbyWifiCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKCRNearbyWifiCellIdenty"];
    if (!cell) {
        cell = [[MKCRNearbyWifiCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKCRNearbyWifiCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.ssidLabel];
        [self.contentView addSubview:self.bssidLabel];
        [self.contentView addSubview:self.rssiLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.ssidLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.top.mas_equalTo(10.f);
        make.right.mas_equalTo(-15.f);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.bssidLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.rssiLabel.mas_left).mas_offset(-15.f);
        make.top.mas_equalTo(self.ssidLabel.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
    [self.rssiLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(60.f);
        make.centerY.mas_equalTo(self.bssidLabel.mas_centerY);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
}

#pragma mark - setter
- (void)setDataModel:(MKCRNearbyWifiCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKCRNearbyWifiCellModel.class]) {
        return;
    }
    //顶部
    self.rssiLabel.text = [NSString stringWithFormat:@"%@dBm",_dataModel.rssi];
    self.ssidLabel.text = (ValidStr(_dataModel.ssid) ? _dataModel.ssid : @"N/A");
    self.bssidLabel.text = [@"BSSID: " stringByAppendingString:(ValidStr(_dataModel.bssid) ? _dataModel.bssid : @"N/A")];
}

#pragma mark - getter
- (UILabel *)ssidLabel {
    if (!_ssidLabel) {
        _ssidLabel = [[UILabel alloc] init];
        _ssidLabel.textAlignment = NSTextAlignmentLeft;
        _ssidLabel.font = MKFont(15.f);
        _ssidLabel.textColor = DEFAULT_TEXT_COLOR;
    }
    return _ssidLabel;
}

- (UILabel *)bssidLabel {
    if (!_bssidLabel) {
        _bssidLabel = [[UILabel alloc] init];
        _bssidLabel.textAlignment = NSTextAlignmentLeft;
        _bssidLabel.font = MKFont(13.f);
        _bssidLabel.textColor = DEFAULT_TEXT_COLOR;
    }
    return _bssidLabel;
}

- (UILabel *)rssiLabel {
    if (!_rssiLabel) {
        _rssiLabel = [[UILabel alloc] init];
        _rssiLabel.textColor = RGBCOLOR(102, 102, 102);
        _rssiLabel.textAlignment = NSTextAlignmentCenter;
        _rssiLabel.font = MKFont(13.f);
    }
    return _rssiLabel;
}

@end
