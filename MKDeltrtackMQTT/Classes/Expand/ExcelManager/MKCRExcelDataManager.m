//
//  MKCRExcelDataManager.m
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2023/12/25.
//  Copyright © 2023 aadyx2007@163.com. All rights reserved.
//

#import "MKCRExcelDataManager.h"

#import <xlsxwriter/xlsxwriter.h>

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

#import "MKExcelWookbook.h"

static NSString *const defaultKeyValueString = @"value:";

@implementation MKCRExcelDataManager

+ (void)parseMacBlackList:(NSString *)excelName
                 sucBlock:(void (^)(NSArray *blackList))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock {
    if (!ValidStr(excelName)) {
        [self operationFailedBlockWithMsg:@"File Name Cannot be empty" block:failedBlock];
        return;
    }
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingPathComponent:excelName];
    NSURL *excelUrl = [[NSURL alloc] initFileURLWithPath:path];
    if (!excelUrl) {
        [self operationFailedBlockWithMsg:@"Load Excel Data Failed" block:failedBlock];
        return;
    }
    MKExcelWookbook *workbook = [[MKExcelWookbook alloc] initWithExcelFilePathUrl:excelUrl];
    if (!workbook || workbook.sheetArray.count == 0) {
        [self operationFailedBlockWithMsg:@"Load Excel Data Failed" block:failedBlock];
        return;
    }
    MKExcelSheet *sheet = workbook.sheetArray.firstObject;
    if (![sheet isKindOfClass:MKExcelSheet.class]) {
        [self operationFailedBlockWithMsg:@"Load Excel Data Failed" block:failedBlock];
        return;
    }
    NSArray *list = sheet.cellArray;
    NSMutableArray *macList = [NSMutableArray array];
    NSMutableArray *passwordList = [NSMutableArray array];
    //根据横竖坐标，获取单元格
    for (NSInteger i = 0; i < list.count; i ++) {
        MKExcelCell *cell = list[i];
        if ([cell.column isEqualToString:@"A"]) {
            //MAC地址列
            [macList addObject:cell];
        }
    }
    //去掉每一列第一行说明性文字
    [macList removeObjectAtIndex:0];
    NSMutableArray *resultList = [NSMutableArray array];
    NSInteger totalNum = macList.count;
    for (NSInteger i = 0; i < totalNum; i ++) {
        MKExcelCell *macCell = macList[i];
        NSString *macAddress = [macCell.stringValue stringByReplacingOccurrencesOfString:@":" withString:@""];
        macAddress = [macAddress stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (macAddress.length == 12 && [macAddress regularExpressions:isHexadecimal]) {
            //必须是有效的mac地址
            [resultList addObject:[SafeStr(macCell.stringValue) uppercaseString]];
        }
    }
    if (sucBlock) {
        sucBlock(resultList);
    }
}

#pragma mark - private method

+ (void)operationFailedBlockWithMsg:(NSString *)msg block:(void (^)(NSError *error))block {
    moko_dispatch_main_safe(^{
        NSError *error = [[NSError alloc] initWithDomain:@"excelOperation"
                                                    code:-999
                                                userInfo:@{@"errorInfo":msg}];
        block(error);
    })
}

@end
