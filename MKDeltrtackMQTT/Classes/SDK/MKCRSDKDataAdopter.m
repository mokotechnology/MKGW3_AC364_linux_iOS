//
//  MKCRSDKDataAdopter.m
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2024/8/27.
//  Copyright © 2024 aadyx2007@163.com. All rights reserved.
//

#import "MKCRSDKDataAdopter.h"

#import "MKBLEBaseSDKDefines.h"
#import "MKBLEBaseSDKAdopter.h"

@implementation MKCRSDKDataAdopter

+ (NSString *)fetchConnectModeString:(mk_cr_connectMode)mode {
    switch (mode) {
        case mk_cr_connectMode_TCP:
            return @"00";
        case mk_cr_connectMode_CACertificate:
            return @"01";
        case mk_cr_connectMode_SelfSignedCertificates:
            return @"02";
    }
}

+ (NSString *)fetchMqttServerQosMode:(mk_cr_mqttServerQosMode)mode {
    switch (mode) {
        case mk_cr_mqttQosLevelAtMostOnce:
            return @"00";
        case mk_cr_mqttQosLevelAtLeastOnce:
            return @"01";
        case mk_cr_mqttQosLevelExactlyOnce:
            return @"02";
    }
}

+ (NSString *)fetchAsciiCode:(NSString *)value {
    if (!MKValidStr(value)) {
        return @"";
    }
    NSString *tempString = @"";
    for (NSInteger i = 0; i < value.length; i ++) {
        int asciiCode = [value characterAtIndex:i];
        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"%1lx",(unsigned long)asciiCode]];
    }
    return tempString;
}

+ (NSString *)parseIpAddress:(NSString *)value {
    if (!MKValidStr(value) || value.length != 8) {
        return @"";
    }
    NSString *value1 = [MKBLEBaseSDKAdopter getDecimalStringWithHex:value range:NSMakeRange(0, 2)];
    NSString *value2 = [MKBLEBaseSDKAdopter getDecimalStringWithHex:value range:NSMakeRange(2, 2)];
    NSString *value3 = [MKBLEBaseSDKAdopter getDecimalStringWithHex:value range:NSMakeRange(4, 2)];
    NSString *value4 = [MKBLEBaseSDKAdopter getDecimalStringWithHex:value range:NSMakeRange(6, 2)];
    return [NSString stringWithFormat:@"%@.%@.%@.%@",value1,value2,value3,value4];
}

+ (BOOL)isIpAddress:(NSString *)ip {
    if (!MKValidStr(ip)) {
        return NO;
    }
    NSString *regex = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:ip];
}

+ (NSString *)ipAddressToHex:(NSString *)ip {
    if (![self isIpAddress:ip]) {
        return @"";
    }
    NSArray *tempList = [ip componentsSeparatedByString:@"."];
    if (tempList.count != 4) {
        return @"";
    }
    NSString *value1 = [MKBLEBaseSDKAdopter fetchHexValue:[tempList[0] integerValue] byteLen:1];
    NSString *value2 = [MKBLEBaseSDKAdopter fetchHexValue:[tempList[1] integerValue] byteLen:1];
    NSString *value3 = [MKBLEBaseSDKAdopter fetchHexValue:[tempList[2] integerValue] byteLen:1];
    NSString *value4 = [MKBLEBaseSDKAdopter fetchHexValue:[tempList[3] integerValue] byteLen:1];
    return [NSString stringWithFormat:@"%@%@%@%@",value1,value2,value3,value4];
}

+ (NSArray <NSString *>*)parseFilterMacList:(NSString *)content {
    if (!MKValidStr(content) || content.length < 4) {
        return @[];
    }
    NSInteger index = 0;
    NSMutableArray *dataList = [NSMutableArray array];
    for (NSInteger i = 0; i < content.length; i ++) {
        if (index >= content.length) {
            break;
        }
        NSInteger subLen = [MKBLEBaseSDKAdopter getDecimalWithHex:content range:NSMakeRange(index, 2)];
        index += 2;
        if (content.length < (index + subLen * 2)) {
            break;
        }
        NSString *subContent = [content substringWithRange:NSMakeRange(index, subLen * 2)];
        index += subLen * 2;
        [dataList addObject:subContent];
    }
    return dataList;
}

+ (NSArray <NSString *>*)parseFilterAdvNameList:(NSArray <NSData *>*)contentList {
    if (!MKValidArray(contentList)) {
        return @[];
    }
    NSMutableData *contentData = [[NSMutableData alloc] init];
    for (NSInteger i = 0; i < contentList.count; i ++) {
        NSData *tempData = contentList[i];
        if (![tempData isKindOfClass:NSData.class]) {
            return @[];
        }
        [contentData appendData:tempData];
    }
    if (!MKValidData(contentData)) {
        return @[];
    }
    NSInteger index = 0;
    NSMutableArray *advNameList = [NSMutableArray array];
    for (NSInteger i = 0; i < contentData.length; i ++) {
        if (index >= contentData.length) {
            break;
        }
        NSData *lenData = [contentData subdataWithRange:NSMakeRange(index, 1)];
        NSString *lenString = [MKBLEBaseSDKAdopter hexStringFromData:lenData];
        NSInteger subLen = [MKBLEBaseSDKAdopter getDecimalWithHex:lenString range:NSMakeRange(0, lenString.length)];
        NSData *subData = [contentData subdataWithRange:NSMakeRange(index + 1, subLen)];
        NSString *advName = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
        if (advName) {
            [advNameList addObject:advName];
        }
        index += (subLen + 1);
    }
    return advNameList;
}

+ (NSArray <NSString *>*)parseFilterMacBlackList:(NSArray <NSData *>*)contentList {
    if (!MKValidArray(contentList)) {
        return @[];
    }
    NSString *contentData = @"";
    for (NSInteger i = 0; i < contentList.count; i ++) {
        NSData *tempData = contentList[i];
        if (![tempData isKindOfClass:NSData.class]) {
            return @[];
        }
        contentData = [contentData stringByAppendingString:[MKBLEBaseSDKAdopter hexStringFromData:tempData]];
    }
    if (!MKValidStr(contentData)) {
        return @[];
    }
    NSInteger totalNumber = contentData.length / 12;
    NSMutableArray *macList = [NSMutableArray array];
    for (NSInteger i = 0; i < totalNumber; i ++) {
        NSString *tempMac = [contentData substringWithRange:NSMakeRange(i * 12, 12)];
        [macList addObject:[tempMac uppercaseString]];
    }
    return macList;
}

@end
