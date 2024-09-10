//
//  MKCRMQTTGeneralParamsView.m
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2024/9/2.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import "MKCRMQTTGeneralParamsView.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

#import "MKTextField.h"

@implementation MKCRMQTTGeneralParamsViewModel
@end

@interface MKCRMQTTGeneralParamsView ()

@property (nonatomic, strong)UILabel *cleanLabel;

@property (nonatomic, strong)UIButton *cleanButton;

@property (nonatomic, strong)UILabel *keepAliveLabel;

@property (nonatomic, strong)MKTextField *textField;

@property (nonatomic, strong)UILabel *unitLabel;

@end

@implementation MKCRMQTTGeneralParamsView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.cleanLabel];
        [self addSubview:self.cleanButton];
        [self addSubview:self.keepAliveLabel];
        [self addSubview:self.textField];
        [self addSubview:self.unitLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.cleanButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(40.f);
        make.top.mas_equalTo(15.f);
        make.height.mas_equalTo(30.f);
    }];
    [self.cleanLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(100.f);
        make.centerY.mas_equalTo(self.cleanButton.mas_centerY);
        make.height.mas_equalTo(MKFont(14.f).lineHeight);
    }];
    [self.keepAliveLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(self.cleanLabel.mas_width);
        make.centerY.mas_equalTo(self.textField.mas_centerY);
        make.height.mas_equalTo(MKFont(14.f).lineHeight);
    }];
    [self.unitLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(60.f);
        make.centerY.mas_equalTo(self.textField.mas_centerY);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
    [self.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.unitLabel.mas_left).mas_offset(-5.f);
        make.width.mas_equalTo(80.f);
        make.top.mas_equalTo(self.cleanButton.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(35.f);
    }];
}

#pragma mark - event method
- (void)cleanButtonPressed {
    self.cleanButton.selected = !self.cleanButton.selected;
    [self updateCleanButtonIcon];
    if ([self.delegate respondsToSelector:@selector(cr_generalParams_cleanSessionStatusChanged:)]) {
        [self.delegate cr_generalParams_cleanSessionStatusChanged:self.cleanButton.selected];
    }
}

#pragma mark - setter
- (void)setDataModel:(MKCRMQTTGeneralParamsViewModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKCRMQTTGeneralParamsViewModel.class]) {
        return;
    }
    self.cleanButton.selected = _dataModel.clean;
    self.textField.text = _dataModel.keepAlive;
    [self updateCleanButtonIcon];
}

#pragma mark - private method
- (void)updateCleanButtonIcon {
    UIImage *image = (self.cleanButton.selected ? LOADICON(@"MKDeltrtackMQTT", @"MKCRMQTTGeneralParamsView", @"cr_switchSelectedIcon.png") : LOADICON(@"MKDeltrtackMQTT", @"MKCRMQTTGeneralParamsView", @"cr_switchUnselectedIcon.png"));
    [self.cleanButton setImage:image forState:UIControlStateNormal];
}

#pragma mark - getter
- (UILabel *)cleanLabel {
    if (!_cleanLabel) {
        _cleanLabel = [[UILabel alloc] init];
        _cleanLabel.textColor = DEFAULT_TEXT_COLOR;
        _cleanLabel.textAlignment = NSTextAlignmentLeft;
        _cleanLabel.font = MKFont(14.f);
        _cleanLabel.text = @"Clean Session";
    }
    return _cleanLabel;
}

- (UIButton *)cleanButton {
    if (!_cleanButton) {
        _cleanButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cleanButton setImage:LOADICON(@"MKDeltrtackMQTT", @"MKCRMQTTGeneralParamsView", @"cr_switchUnselectedIcon.png") forState:UIControlStateNormal];
        [_cleanButton addTarget:self
                         action:@selector(cleanButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _cleanButton;
}

- (UILabel *)keepAliveLabel {
    if (!_keepAliveLabel) {
        _keepAliveLabel = [[UILabel alloc] init];
        _keepAliveLabel.textColor = DEFAULT_TEXT_COLOR;
        _keepAliveLabel.textAlignment = NSTextAlignmentLeft;
        _keepAliveLabel.font = MKFont(14.f);
        _keepAliveLabel.text = @"Keep Alive";
    }
    return _keepAliveLabel;
}

- (MKTextField *)textField {
    if (!_textField) {
        _textField = [[MKTextField alloc] initWithTextFieldType:mk_realNumberOnly];
        @weakify(self);
        _textField.textChangedBlock = ^(NSString * _Nonnull text) {
            @strongify(self);
            if ([self.delegate respondsToSelector:@selector(cr_generalParams_KeepAliveChanged:)]) {
                [self.delegate cr_generalParams_KeepAliveChanged:text];
            }
        };
        _textField.maxLength = 3;
        _textField.placeholder = @"10-120";
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.font = MKFont(13.f);
        _textField.textColor = DEFAULT_TEXT_COLOR;
        
        _textField.backgroundColor = COLOR_WHITE_MACROS;
        _textField.layer.masksToBounds = YES;
        _textField.layer.borderWidth = CUTTING_LINE_HEIGHT;
        _textField.layer.borderColor = CUTTING_LINE_COLOR.CGColor;
        _textField.layer.cornerRadius = 6.f;
    }
    return _textField;
}

- (UILabel *)unitLabel {
    if (!_unitLabel) {
        _unitLabel = [[UILabel alloc] init];
        _unitLabel.textColor = DEFAULT_TEXT_COLOR;
        _unitLabel.textAlignment = NSTextAlignmentLeft;
        _unitLabel.font = MKFont(13.f);
        _unitLabel.text = @"s";
    }
    return _unitLabel;
}

@end
