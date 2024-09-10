//
//  MKCRMacBlackListController.m
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2024/9/4.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import "MKCRMacBlackListController.h"


#import "Masonry.h"

#import "MKMacroDefines.h"
#import "UIView+MKAdd.h"

#import "MKHudManager.h"
#import "MKCustomUIAdopter.h"

#import "MKCRExcelDataManager.h"

#import "MKCRImportServerController.h"

#import "MKCRMacBlackListModel.h"

@interface MKCRMacBlackListController ()<MKCRImportServerControllerDelegate>

@property (nonatomic, strong)UITextView *textView;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)MKCRMacBlackListModel *dataModel;

@end

@implementation MKCRMacBlackListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self readDatasFromDevice];
}

#pragma mark - super method
- (void)rightButtonMethod {
    [self saveDataToDevice];
}

#pragma mark - MKCRImportServerControllerDelegate
- (void)cr_selectedServerParams:(NSString *)fileName {
    [[MKHudManager share] showHUDWithTitle:@"Loading..." inView:self.view isPenetration:NO];
    [MKCRExcelDataManager parseMacBlackList:fileName sucBlock:^(NSArray * _Nonnull blackList) {
        [self.dataList removeAllObjects];
        
        NSInteger count = MIN(blackList.count, 1000);
        NSString *macListString = @"";
        for (NSInteger i = 0; i < count; i ++) {
            NSString *mac = blackList[i];
            NSString *text = [NSString stringWithFormat:@"\n%@",mac];
            macListString = [macListString stringByAppendingFormat:text];
            [self.dataList addObject:mac];
        }
        
        self.textView.text = macListString;
        [[MKHudManager share] hide];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - event method
- (void)addButtonPressed {
    MKCRImportServerController *vc = [[MKCRImportServerController alloc] init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)clearButtonPressed {
    [self.dataList removeAllObjects];
    self.textView.text = @"";
}

#pragma mark - interface
- (void)readDatasFromDevice {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    @weakify(self);
    [self.dataModel readDataWithSucBlock:^{
        @strongify(self);
        NSString *macListString = @"";
        for (NSInteger i = 0; i < self.dataModel.macList.count; i ++) {
            NSString *mac = self.dataModel.macList[i];
            NSString *text = [NSString stringWithFormat:@"\n%@",mac];
            macListString = [macListString stringByAppendingFormat:text];
            [self.dataList addObject:mac];
        }
        self.textView.text = macListString;
        [[MKHudManager share] hide];
    } failedBlock:^(NSError * _Nonnull error) {
        @strongify(self);
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)saveDataToDevice {
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    @weakify(self);
    [self.dataModel configDataWithMacList:self.dataList sucBlock:^{
        @strongify(self);
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success"];
    } failedBlock:^(NSError * _Nonnull error) {
        @strongify(self);
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = @"MAC Address Blacklist";
    [self.rightButton setImage:LOADICON(@"MKDeltrtackMQTT", @"MKCRMacBlackListController", @"cr_saveIcon.png") forState:UIControlStateNormal];
    UIView *headerView = [self headerView];
    [self.view addSubview:headerView];
    [headerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(100.f);
    }];
    [self.view addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(headerView.mas_bottom).mas_offset(5.f);
        make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
}

#pragma mark - getter
- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.backgroundColor = COLOR_WHITE_MACROS;
        _textView.font = MKFont(13.f);
        _textView.layoutManager.allowsNonContiguousLayout = NO;
        _textView.editable = NO;
        _textView.textColor = DEFAULT_TEXT_COLOR;
        
        _textView.layer.masksToBounds = YES;
        _textView.layer.borderColor = CUTTING_LINE_COLOR.CGColor;
        _textView.layer.borderWidth = CUTTING_LINE_HEIGHT;
        _textView.layer.cornerRadius = 6.f;
    }
    return _textView;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (MKCRMacBlackListModel *)dataModel {
    if (!_dataModel) {
        _dataModel = [[MKCRMacBlackListModel alloc] init];
    }
    return _dataModel;
}

- (UIView *)headerView {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = COLOR_WHITE_MACROS;
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setImage:LOADICON(@"MKDeltrtackMQTT", @"MKCRMacBlackListController", @"cr_certAddIcon.png") forState:UIControlStateNormal];
    [addButton addTarget:self
                  action:@selector(addButtonPressed)
        forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:addButton];
    [addButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(40.f);
        make.top.mas_equalTo(20.f);
        make.height.mas_equalTo(30.f);
    }];
    
    UILabel *msgLabel = [MKCustomUIAdopter customTextLabel];
    msgLabel.text = @"Edit Mac Address";
    [headerView addSubview:msgLabel];
    [msgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(addButton.mas_left).mas_offset(-15.f);
        make.centerY.mas_equalTo(addButton.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    
    UIButton *clearButton = [MKCustomUIAdopter customButtonWithTitle:@"Clear"
                                                              target:self
                                                              action:@selector(clearButtonPressed)];
    [headerView addSubview:clearButton];
    [clearButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(headerView.mas_centerX);
        make.width.mas_equalTo(60.f);
        make.top.mas_equalTo(addButton.mas_bottom).mas_offset(15.f);
        make.height.mas_equalTo(30.f);
    }];
    
    return headerView;
}

@end
