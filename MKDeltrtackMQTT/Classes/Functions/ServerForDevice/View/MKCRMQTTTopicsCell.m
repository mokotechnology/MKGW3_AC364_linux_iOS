//
//  MKCRMQTTTopicsCell.m
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2024/9/2.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import "MKCRMQTTTopicsCell.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"
#import "UISegmentedControl+MKAdd.h"

#import "MKTextField.h"
#import "MKCustomUIAdopter.h"

const CGFloat msgLabelWidth = 130.f;

@implementation MKCRMQTTTopicsCellModel
@end

@interface MKCRMQTTTopicsCell ()

@property (nonatomic, strong)UILabel *pubLabel;

@property (nonatomic, strong)MKTextField *pubTextField;

@property (nonatomic, strong)UILabel *subLabel;

@property (nonatomic, strong)MKTextField *subTextField;

@property (nonatomic, strong)UILabel *qosLabel;

@property (nonatomic, strong)UISegmentedControl *segment;

@end

@implementation MKCRMQTTTopicsCell

+ (MKCRMQTTTopicsCell *)initCellWithTableView:(UITableView *)tableView {
    MKCRMQTTTopicsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKCRMQTTTopicsCellIdenty"];
    if (!cell) {
        cell = [[MKCRMQTTTopicsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKCRMQTTTopicsCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.pubLabel];
        [self.contentView addSubview:self.pubTextField];
        [self.contentView addSubview:self.subLabel];
        [self.contentView addSubview:self.subTextField];
        [self.contentView addSubview:self.qosLabel];
        [self.contentView addSubview:self.segment];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.pubLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(msgLabelWidth);
        make.top.mas_equalTo(10.f);
        make.height.mas_equalTo(30.f);
    }];
    [self.pubTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.left.mas_equalTo(self.pubLabel.mas_right).mas_offset(5.f);
        make.centerY.mas_equalTo(self.pubLabel.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
    if (self.dataModel.showSubTopic) {
        [self.subLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15.f);
            make.width.mas_equalTo(msgLabelWidth);
            make.top.mas_equalTo(self.pubLabel.mas_bottom).mas_offset(10.f);
            make.height.mas_equalTo(30.f);
        }];
        [self.subTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-15.f);
            make.left.mas_equalTo(self.subLabel.mas_right).mas_offset(5.f);
            make.centerY.mas_equalTo(self.subLabel.mas_centerY);
            make.height.mas_equalTo(30.f);
        }];
    }
    [self.qosLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(msgLabelWidth);
        make.centerY.mas_equalTo(self.segment.mas_centerY);
        make.height.mas_equalTo(MKFont(14.f).lineHeight);
    }];
    [self.segment mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.qosLabel.mas_right).mas_offset(10.f);
        make.right.mas_equalTo(-15.f);
        if (self.dataModel.showSubTopic) {
            make.top.mas_equalTo(self.subTextField.mas_bottom).mas_offset(10.f);
        }else {
            make.top.mas_equalTo(self.pubTextField.mas_bottom).mas_offset(10.f);
        }
        make.height.mas_equalTo(30.f);
    }];
}

#pragma mark - event method
- (void)segmentValueChanged {
    if ([self.delegate respondsToSelector:@selector(cr_mqttTopicsCell_qosChanged:qos:)]) {
        [self.delegate cr_mqttTopicsCell_qosChanged:self.dataModel.index qos:self.segment.selectedSegmentIndex];
    }
}

#pragma mark - setter
- (void)setDataModel:(MKCRMQTTTopicsCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKCRMQTTTopicsCellModel.class]) {
        return;
    }
    self.pubLabel.text = _dataModel.pubMsg;
    self.pubTextField.text = _dataModel.pubTopic;
    if (self.subLabel.superview) {
        [self.subLabel removeFromSuperview];
    }
    if (self.subTextField.superview) {
        [self.subTextField removeFromSuperview];
    }
    if (_dataModel.showSubTopic) {
        [self.contentView addSubview:self.subLabel];
        [self.contentView addSubview:self.subTextField];
        self.subLabel.text = _dataModel.subMsg;
        self.subTextField.text = _dataModel.subTopic;
    }
    self.qosLabel.text = _dataModel.qosMsg;
    self.segment.selectedSegmentIndex = _dataModel.qos;
    [self setNeedsLayout];
}

#pragma mark - getter
- (UILabel *)pubLabel {
    if (!_pubLabel) {
        _pubLabel = [[UILabel alloc] init];
        _pubLabel.textColor = DEFAULT_TEXT_COLOR;
        _pubLabel.textAlignment = NSTextAlignmentLeft;
        _pubLabel.font = MKFont(14.f);
    }
    return _pubLabel;
}

- (MKTextField *)pubTextField {
    if (!_pubTextField) {
        _pubTextField = [MKCustomUIAdopter customNormalTextFieldWithText:@""
                                                             placeHolder:@"1~128 characters"
                                                                textType:mk_normal];
        _pubTextField.font = MKFont(13.f);
        _pubTextField.maxLength = 128;
        @weakify(self);
        _pubTextField.textChangedBlock = ^(NSString * _Nonnull text) {
            @strongify(self);
            if ([self.delegate respondsToSelector:@selector(cr_mqttTopicsCell_pubTopicChanged:topic:)]) {
                [self.delegate cr_mqttTopicsCell_pubTopicChanged:self.dataModel.index topic:text];
            }
        };
    }
    return _pubTextField;
}

- (UILabel *)subLabel {
    if (!_subLabel) {
        _subLabel = [[UILabel alloc] init];
        _subLabel.textColor = DEFAULT_TEXT_COLOR;
        _subLabel.textAlignment = NSTextAlignmentLeft;
        _subLabel.font = MKFont(14.f);
    }
    return _subLabel;
}

- (MKTextField *)subTextField {
    if (!_subTextField) {
        _subTextField = [MKCustomUIAdopter customNormalTextFieldWithText:@""
                                                             placeHolder:@"1~128 characters"
                                                                textType:mk_normal];
        _subTextField.font = MKFont(13.f);
        _subTextField.maxLength = 128;
        @weakify(self);
        _subTextField.textChangedBlock = ^(NSString * _Nonnull text) {
            @strongify(self);
            if ([self.delegate respondsToSelector:@selector(cr_mqttTopicsCell_subTopicChanged:topic:)]) {
                [self.delegate cr_mqttTopicsCell_subTopicChanged:self.dataModel.index topic:text];
            }
        };
    }
    return _subTextField;
}

- (UILabel *)qosLabel {
    if (!_qosLabel) {
        _qosLabel = [[UILabel alloc] init];
        _qosLabel.textColor = DEFAULT_TEXT_COLOR;
        _qosLabel.textAlignment = NSTextAlignmentLeft;
        _qosLabel.font = MKFont(14.f);
    }
    return _qosLabel;
}

- (UISegmentedControl *)segment {
    if (!_segment) {
        _segment = [[UISegmentedControl alloc] initWithItems:@[@"0",@"1",@"2"]];
        [_segment mk_setTintColor:NAVBAR_COLOR_MACROS];
//        _segment.selectedSegmentTintColor = COLOR_WHITE_MACROS;
        _segment.selectedSegmentIndex = 1;
        [_segment addTarget:self
                     action:@selector(segmentValueChanged)
           forControlEvents:UIControlEventValueChanged];
    }
    return _segment;
}

@end
