//
//  MKCRTaskAdopter.m
//  MKDeltrtackMQTT_Example
//
//  Created by aa on 2024/8/27.
//  Copyright © 2024 aadyx2007@163.com. All rights reserved.
//

#import "MKCRTaskAdopter.h"

#import <CoreBluetooth/CoreBluetooth.h>

#import "MKBLEBaseSDKAdopter.h"
#import "MKBLEBaseSDKDefines.h"

#import "MKCROperationID.h"
#import "CBPeripheral+MKCRAdd.h"
#import "MKCRSDKDataAdopter.h"

NSString *const mk_cr_totalNumKey = @"mk_cr_totalNumKey";
NSString *const mk_cr_totalIndexKey = @"mk_cr_totalIndexKey";
NSString *const mk_cr_contentKey = @"mk_cr_contentKey";

@implementation MKCRTaskAdopter

+ (NSDictionary *)parseReadDataWithCharacteristic:(CBCharacteristic *)characteristic {
    NSData *readData = characteristic.value;
    NSLog(@"+++++%@-----%@",characteristic.UUID.UUIDString,readData);
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A24"]]) {
        //产品型号
        NSString *tempString = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
        return [self dataParserGetDataSuccess:@{@"modeID":tempString} operationID:mk_cr_taskReadDeviceModelOperation];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A26"]]) {
        //firmware
        NSString *tempString = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
        return [self dataParserGetDataSuccess:@{@"firmware":tempString} operationID:mk_cr_taskReadFirmwareOperation];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A27"]]) {
        //hardware
        NSString *tempString = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
        return [self dataParserGetDataSuccess:@{@"hardware":tempString} operationID:mk_cr_taskReadHardwareOperation];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A28"]]) {
        //soft ware
        NSString *tempString = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
        return [self dataParserGetDataSuccess:@{@"software":tempString} operationID:mk_cr_taskReadSoftwareOperation];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]]) {
        //manufacturerKey
        NSString *tempString = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
        return [self dataParserGetDataSuccess:@{@"manufacturer":tempString} operationID:mk_cr_taskReadManufacturerOperation];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"AA00"]]) {
        //密码相关
        NSString *content = [MKBLEBaseSDKAdopter hexStringFromData:readData];
        NSString *state = @"";
        if (content.length == 10) {
            state = [content substringWithRange:NSMakeRange(8, 2)];
        }
        return [self dataParserGetDataSuccess:@{@"state":state} operationID:mk_cr_connectPasswordOperation];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"AA03"]]) {
        return [self parseCustomData:readData];
    }
    return @{};
}

+ (NSDictionary *)parseWriteDataWithCharacteristic:(CBCharacteristic *)characteristic {
    return @{};
}

#pragma mark - Private method

+ (NSDictionary *)parseCustomData:(NSData *)readData {
    NSString *readString = [MKBLEBaseSDKAdopter hexStringFromData:readData];
    
    if ([[readString substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"ee"]) {
        //多帧数据
        return [self parseMultiData:readData];
    }
    
    NSInteger dataLen = [MKBLEBaseSDKAdopter getDecimalWithHex:readString range:NSMakeRange(6, 2)];
    if (readData.length != dataLen + 4) {
        return @{};
    }
    NSString *flag = [readString substringWithRange:NSMakeRange(2, 2)];
    NSString *cmd = [readString substringWithRange:NSMakeRange(4, 2)];
    NSString *content = [readString substringWithRange:NSMakeRange(8, dataLen * 2)];
    if ([[readString substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"ed"]) {
        //单帧数据
        if ([flag isEqualToString:@"00"]) {
            //读取
            return [self parseCustomReadData:content cmd:cmd data:readData];
        }
        if ([flag isEqualToString:@"01"]) {
            return [self parseCustomConfigData:content cmd:cmd];
        }
    }
    
    return @{};
}

+ (NSDictionary *)parseMultiData:(NSData *)readData {
    NSString *readString = [MKBLEBaseSDKAdopter hexStringFromData:readData];
    NSString *flag = [readString substringWithRange:NSMakeRange(2, 2)];
    NSString *cmd = [readString substringWithRange:NSMakeRange(4, 2)];
    NSString *content = [readString substringFromIndex:8];
    if ([flag isEqualToString:@"00"]) {
        return [self parseMultiPackageReadData:readData cmd:[readString substringWithRange:NSMakeRange(4, 2)]];
    }
    if ([flag isEqualToString:@"01"]) {
        return [self parseMultiPackageData:content cmd:[readString substringWithRange:NSMakeRange(4, 2)]];
    }
    return @{};
}

+ (NSDictionary *)parseCustomReadData:(NSString *)content cmd:(NSString *)cmd data:(NSData *)data {
    mk_cr_taskOperationID operationID = mk_cr_defaultTaskOperationID;
    NSDictionary *resultDic = @{};
    if ([cmd isEqualToString:@"02"]) {
        
    }else if ([cmd isEqualToString:@"04"]) {
        //读取以太网MAC
        NSString *macAddress = [NSString stringWithFormat:@"%@:%@:%@:%@:%@:%@",[content substringWithRange:NSMakeRange(0, 2)],[content substringWithRange:NSMakeRange(2, 2)],[content substringWithRange:NSMakeRange(4, 2)],[content substringWithRange:NSMakeRange(6, 2)],[content substringWithRange:NSMakeRange(8, 2)],[content substringWithRange:NSMakeRange(10, 2)]];
        resultDic = @{@"macAddress":[macAddress uppercaseString]};
        operationID = mk_cr_taskReadEthernetMacOperation;
    }else if ([cmd isEqualToString:@"05"]) {
        //读取deviceName
        NSString *deviceName = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(4, data.length - 4)] encoding:NSUTF8StringEncoding];
        resultDic = @{@"deviceName":deviceName};
        operationID = mk_cr_taskReadDeviceNameOperation;
    }else if ([cmd isEqualToString:@"09"]) {
        //读取MAC
        NSString *macAddress = [NSString stringWithFormat:@"%@:%@:%@:%@:%@:%@",[content substringWithRange:NSMakeRange(0, 2)],[content substringWithRange:NSMakeRange(2, 2)],[content substringWithRange:NSMakeRange(4, 2)],[content substringWithRange:NSMakeRange(6, 2)],[content substringWithRange:NSMakeRange(8, 2)],[content substringWithRange:NSMakeRange(10, 2)]];
        resultDic = @{@"macAddress":[macAddress uppercaseString]};
        operationID = mk_cr_taskReadDeviceMacAddressOperation;
    }else if ([cmd isEqualToString:@"0a"]) {
        //读取WIFI STA MAC
        NSString *macAddress = [NSString stringWithFormat:@"%@:%@:%@:%@:%@:%@",[content substringWithRange:NSMakeRange(0, 2)],[content substringWithRange:NSMakeRange(2, 2)],[content substringWithRange:NSMakeRange(4, 2)],[content substringWithRange:NSMakeRange(6, 2)],[content substringWithRange:NSMakeRange(8, 2)],[content substringWithRange:NSMakeRange(10, 2)]];
        resultDic = @{@"macAddress":[macAddress uppercaseString]};
        operationID = mk_cr_taskReadDeviceWifiSTAMacAddressOperation;
    }else if ([cmd isEqualToString:@"0f"]) {
        //读取心跳包间隔
        NSString *interval = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(0, content.length)];
        resultDic = @{@"interval":interval};
        operationID = mk_cr_taskReadHeartbeatUploadIntervalOperation;
    }else if ([cmd isEqualToString:@"10"]) {
        //读取NTP服务器域名
        NSString *host = @"";
        if (data.length > 4) {
            NSData *hostData = [data subdataWithRange:NSMakeRange(4, data.length - 4)];
            host = [[NSString alloc] initWithData:hostData encoding:NSUTF8StringEncoding];
        }
        resultDic = @{
            @"host":(MKValidStr(host) ? host : @""),
        };
        operationID = mk_cr_taskReadNTPServerHostOperation;
    }else if ([cmd isEqualToString:@"12"]) {
        //读取蜂窝IMEI
        NSString *imei = @"";
        if (data.length > 4) {
            NSData *imeiData = [data subdataWithRange:NSMakeRange(4, data.length - 4)];
            imei = [[NSString alloc] initWithData:imeiData encoding:NSUTF8StringEncoding];
        }
        resultDic = @{
            @"imei":(MKValidStr(imei) ? imei : @""),
        };
        operationID = mk_cr_taskReadIMEIOperation;
    }else if ([cmd isEqualToString:@"13"]) {
        //读取SIM卡ICCID
        NSString *iccid = @"";
        if (data.length > 4) {
            NSData *iccidData = [data subdataWithRange:NSMakeRange(4, data.length - 4)];
            iccid = [[NSString alloc] initWithData:iccidData encoding:NSUTF8StringEncoding];
        }
        resultDic = @{
            @"iccid":(MKValidStr(iccid) ? iccid : @""),
        };
        operationID = mk_cr_taskReadICCIDOperation;
    }else if ([cmd isEqualToString:@"20"]) {
        //读取MQTT服务器域名
        NSString *host = @"";
        if (data.length > 4) {
            NSData *hostData = [data subdataWithRange:NSMakeRange(4, data.length - 4)];
            host = [[NSString alloc] initWithData:hostData encoding:NSUTF8StringEncoding];
        }
        resultDic = @{
            @"host":(MKValidStr(host) ? host : @""),
        };
        operationID = mk_cr_taskReadServerHostOperation;
    }else if ([cmd isEqualToString:@"21"]) {
        //读取MQTT服务器端口
        NSString *port = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(0, content.length)];
        resultDic = @{@"port":port};
        operationID = mk_cr_taskReadServerPortOperation;
    }else if ([cmd isEqualToString:@"22"]) {
        //读取ClientID
        NSString *clientID = @"";
        if (data.length > 4) {
            NSData *clientIDData = [data subdataWithRange:NSMakeRange(4, data.length - 4)];
            clientID = [[NSString alloc] initWithData:clientIDData encoding:NSUTF8StringEncoding];
        }
        resultDic = @{
            @"clientID":(MKValidStr(clientID) ? clientID : @""),
        };
        operationID = mk_cr_taskReadClientIDOperation;
    }else if ([cmd isEqualToString:@"25"]) {
        //读取MQTT Clean Session
        BOOL clean = ([content isEqualToString:@"01"]);
        resultDic = @{@"clean":@(clean)};
        operationID = mk_cr_taskReadServerCleanSessionOperation;
    }else if ([cmd isEqualToString:@"26"]) {
        //读取MQTT KeepAlive
        NSString *keepAlive = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(0, content.length)];
        resultDic = @{@"keepAlive":keepAlive};
        operationID = mk_cr_taskReadServerKeepAliveOperation;
    }else if ([cmd isEqualToString:@"27"]) {
        //读取Broadcast Qos
        NSString *qos = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(0, content.length)];
        resultDic = @{@"qos":qos};
        operationID = mk_cr_taskReadBroadcastQosOperation;
    }else if ([cmd isEqualToString:@"28"]) {
        //读取ateway Qos
        NSString *qos = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(0, content.length)];
        resultDic = @{@"qos":qos};
        operationID = mk_cr_taskReadGatewayQosOperation;
    }else if ([cmd isEqualToString:@"29"]) {
        //读取Device Qos
        NSString *qos = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(0, content.length)];
        resultDic = @{@"qos":qos};
        operationID = mk_cr_taskReadDeviceQosOperation;
    }else if ([cmd isEqualToString:@"2a"]) {
        //读取pubBroadcast topic
        NSString *topic = @"";
        if (data.length > 4) {
            NSData *topicData = [data subdataWithRange:NSMakeRange(4, data.length - 4)];
            topic = [[NSString alloc] initWithData:topicData encoding:NSUTF8StringEncoding];
        }
        resultDic = @{
            @"topic":(MKValidStr(topic) ? topic : @""),
        };
        operationID = mk_cr_taskReadBroadPubTopicOperation;
    }else if ([cmd isEqualToString:@"2b"]) {
        //读取pubGateway topic
        NSString *topic = @"";
        if (data.length > 4) {
            NSData *topicData = [data subdataWithRange:NSMakeRange(4, data.length - 4)];
            topic = [[NSString alloc] initWithData:topicData encoding:NSUTF8StringEncoding];
        }
        resultDic = @{
            @"topic":(MKValidStr(topic) ? topic : @""),
        };
        operationID = mk_cr_taskReadGatewayPubTopicOperation;
    }else if ([cmd isEqualToString:@"2c"]) {
        //读取subGateway topic
        NSString *topic = @"";
        if (data.length > 4) {
            NSData *topicData = [data subdataWithRange:NSMakeRange(4, data.length - 4)];
            topic = [[NSString alloc] initWithData:topicData encoding:NSUTF8StringEncoding];
        }
        resultDic = @{
            @"topic":(MKValidStr(topic) ? topic : @""),
        };
        operationID = mk_cr_taskReadGatewaySubTopicOperation;
    }else if ([cmd isEqualToString:@"2d"]) {
        //读取pubDevice topic
        NSString *topic = @"";
        if (data.length > 4) {
            NSData *topicData = [data subdataWithRange:NSMakeRange(4, data.length - 4)];
            topic = [[NSString alloc] initWithData:topicData encoding:NSUTF8StringEncoding];
        }
        resultDic = @{
            @"topic":(MKValidStr(topic) ? topic : @""),
        };
        operationID = mk_cr_taskReadDevicePubTopicOperation;
    }else if ([cmd isEqualToString:@"2e"]) {
        //读取subDevice topic
        NSString *topic = @"";
        if (data.length > 4) {
            NSData *topicData = [data subdataWithRange:NSMakeRange(4, data.length - 4)];
            topic = [[NSString alloc] initWithData:topicData encoding:NSUTF8StringEncoding];
        }
        resultDic = @{
            @"topic":(MKValidStr(topic) ? topic : @""),
        };
        operationID = mk_cr_taskReadDeviceSubTopicOperation;
    }else if ([cmd isEqualToString:@"2f"]) {
        //读取LWT 开关
        BOOL isOn = ([content isEqualToString:@"01"]);
        resultDic = @{@"isOn":@(isOn)};
        operationID = mk_cr_taskReadLWTStatusOperation;
    }else if ([cmd isEqualToString:@"30"]) {
        //读取LWT Qos
        NSString *qos = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(0, content.length)];
        resultDic = @{@"qos":qos};
        operationID = mk_cr_taskReadLWTQosOperation;
    }else if ([cmd isEqualToString:@"31"]) {
        //读取LWT Retain
        BOOL isOn = ([content isEqualToString:@"01"]);
        resultDic = @{@"isOn":@(isOn)};
        operationID = mk_cr_taskReadLWTRetainOperation;
    }else if ([cmd isEqualToString:@"32"]) {
        //读取LWT topic
        NSString *topic = @"";
        if (data.length > 4) {
            NSData *topicData = [data subdataWithRange:NSMakeRange(4, data.length - 4)];
            topic = [[NSString alloc] initWithData:topicData encoding:NSUTF8StringEncoding];
        }
        resultDic = @{
            @"topic":(MKValidStr(topic) ? topic : @""),
        };
        operationID = mk_cr_taskReadLWTTopicOperation;
    }else if ([cmd isEqualToString:@"33"]) {
        //读取LWT payload
        NSString *payload = @"";
        if (data.length > 4) {
            NSData *payloadData = [data subdataWithRange:NSMakeRange(4, data.length - 4)];
            payload = [[NSString alloc] initWithData:payloadData encoding:NSUTF8StringEncoding];
        }
        resultDic = @{
            @"payload":(MKValidStr(payload) ? payload : @""),
        };
        operationID = mk_cr_taskReadLWTPayloadOperation;
    }else if ([cmd isEqualToString:@"34"]) {
        //读取MTQQ服务器通信加密方式
        NSString *mode = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(0, content.length)];
        resultDic = @{@"mode":mode};
        operationID = mk_cr_taskReadConnectModeOperation;
    }else if ([cmd isEqualToString:@"41"]) {
        //读取WIFI SSID
        NSString *ssid = @"";
        if (data.length > 4) {
            NSData *ssidData = [data subdataWithRange:NSMakeRange(4, data.length - 4)];
            ssid = [[NSString alloc] initWithData:ssidData encoding:NSUTF8StringEncoding];
        }
        resultDic = @{
            @"ssid":(MKValidStr(ssid) ? ssid : @""),
        };
        operationID = mk_cr_taskReadWIFISSIDOperation;
    }else if ([cmd isEqualToString:@"42"]) {
        //读取WIFI password
        NSString *password = @"";
        if (data.length > 4) {
            NSData *passwordData = [data subdataWithRange:NSMakeRange(4, data.length - 4)];
            password = [[NSString alloc] initWithData:passwordData encoding:NSUTF8StringEncoding];
        }
        resultDic = @{
            @"password":(MKValidStr(password) ? password : @""),
        };
        operationID = mk_cr_taskReadWIFIPasswordOperation;
    }else if ([cmd isEqualToString:@"43"]) {
        //读取Wifi DHCP开关
        BOOL isOn = ([content isEqualToString:@"01"]);
        resultDic = @{@"isOn":@(isOn)};
        operationID = mk_cr_taskReadWIFIDHCPStatusOperation;
    }else if ([cmd isEqualToString:@"44"]) {
        //读取Wifi IP信息
        NSString *ip = [MKCRSDKDataAdopter parseIpAddress:[content substringWithRange:NSMakeRange(0, 8)]];
        NSString *mask = [MKCRSDKDataAdopter parseIpAddress:[content substringWithRange:NSMakeRange(8, 8)]];
        NSString *gateway = [MKCRSDKDataAdopter parseIpAddress:[content substringWithRange:NSMakeRange(16, 8)]];
        NSString *dns = [MKCRSDKDataAdopter parseIpAddress:[content substringWithRange:NSMakeRange(24, 8)]];
        resultDic = @{
            @"ip":ip,
            @"mask":mask,
            @"gateway":gateway,
            @"dns":dns
        };
        operationID = mk_cr_taskReadWIFINetworkIpInfosOperation;
    }else if ([cmd isEqualToString:@"45"]) {
        //读取Ethernet DHCP开关
        BOOL isOn = ([content isEqualToString:@"01"]);
        resultDic = @{@"isOn":@(isOn)};
        operationID = mk_cr_taskReadEthernetDHCPStatusOperation;
    }else if ([cmd isEqualToString:@"46"]) {
        //读取Ethernet IP信息
        NSString *ip = [MKCRSDKDataAdopter parseIpAddress:[content substringWithRange:NSMakeRange(0, 8)]];
        NSString *mask = [MKCRSDKDataAdopter parseIpAddress:[content substringWithRange:NSMakeRange(8, 8)]];
        NSString *gateway = [MKCRSDKDataAdopter parseIpAddress:[content substringWithRange:NSMakeRange(16, 8)]];
        NSString *dns = [MKCRSDKDataAdopter parseIpAddress:[content substringWithRange:NSMakeRange(24, 8)]];
        resultDic = @{
            @"ip":ip,
            @"mask":mask,
            @"gateway":gateway,
            @"dns":dns
        };
        operationID = mk_cr_taskReadEthernetNetworkIpInfosOperation;
    }else if ([cmd isEqualToString:@"47"]) {
        //读取APN
        NSString *apn = @"";
        if (data.length > 4) {
            NSData *apnData = [data subdataWithRange:NSMakeRange(4, data.length - 4)];
            apn = [[NSString alloc] initWithData:apnData encoding:NSUTF8StringEncoding];
        }
        resultDic = @{
            @"apn":(MKValidStr(apn) ? apn : @""),
        };
        operationID = mk_cr_taskReadApnOperation;
    }else if ([cmd isEqualToString:@"48"]) {
        //读取APN用户名
        NSString *username = @"";
        if (data.length > 4) {
            NSData *usernameData = [data subdataWithRange:NSMakeRange(4, data.length - 4)];
            username = [[NSString alloc] initWithData:usernameData encoding:NSUTF8StringEncoding];
        }
        resultDic = @{
            @"username":(MKValidStr(username) ? username : @""),
        };
        operationID = mk_cr_taskReadApnUsernameOperation;
    }else if ([cmd isEqualToString:@"49"]) {
        //读取APN密码
        NSString *password = @"";
        if (data.length > 4) {
            NSData *passwordData = [data subdataWithRange:NSMakeRange(4, data.length - 4)];
            password = [[NSString alloc] initWithData:passwordData encoding:NSUTF8StringEncoding];
        }
        resultDic = @{
            @"password":(MKValidStr(password) ? password : @""),
        };
        operationID = mk_cr_taskReadApnPasswordOperation;
    }else if ([cmd isEqualToString:@"4a"]) {
        //读取PIN
        NSString *pin = @"";
        if (data.length > 4) {
            NSData *pinData = [data subdataWithRange:NSMakeRange(4, data.length - 4)];
            pin = [[NSString alloc] initWithData:pinData encoding:NSUTF8StringEncoding];
        }
        resultDic = @{
            @"pin":(MKValidStr(pin) ? pin : @""),
        };
        operationID = mk_cr_taskReadPinOperation;
    }else if ([cmd isEqualToString:@"4d"]) {
        //读取网络类型
        resultDic = @{
            @"type":[MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(0, content.length)],
        };
        operationID = mk_cr_taskReadNetworkTypeOperation;
    }else if ([cmd isEqualToString:@"60"]) {
        //读取RSSI过滤规则
        resultDic = @{
            @"rssi":[NSString stringWithFormat:@"%ld",(long)[[MKBLEBaseSDKAdopter signedHexTurnString:content] integerValue]],
        };
        operationID = mk_cr_taskReadRssiFilterValueOperation;
    }else if ([cmd isEqualToString:@"61"]) {
        //读取精准过滤MAC开关
        BOOL isOn = ([content isEqualToString:@"01"]);
        resultDic = @{
            @"isOn":@(isOn)
        };
        operationID = mk_cr_taskReadFilterByMacPreciseMatchOperation;
    }else if ([cmd isEqualToString:@"62"]) {
        //读取反向过滤MAC开关
        BOOL isOn = ([content isEqualToString:@"01"]);
        resultDic = @{
            @"isOn":@(isOn)
        };
        operationID = mk_cr_taskReadFilterByMacReverseFilterOperation;
    }else if ([cmd isEqualToString:@"63"]) {
        //读取MAC过滤列表
        NSArray *macList = [MKCRSDKDataAdopter parseFilterMacList:content];
        resultDic = @{
            @"macList":(MKValidArray(macList) ? macList : @[]),
        };
        operationID = mk_cr_taskReadFilterMACAddressListOperation;
    }else if ([cmd isEqualToString:@"65"]) {
        //读取精准过滤Adv Name开关
        BOOL isOn = ([content isEqualToString:@"01"]);
        resultDic = @{
            @"isOn":@(isOn)
        };
        operationID = mk_cr_taskReadFilterByAdvNamePreciseMatchOperation;
    }else if ([cmd isEqualToString:@"66"]) {
        //读取反向过滤Adv Name开关
        BOOL isOn = ([content isEqualToString:@"01"]);
        resultDic = @{
            @"isOn":@(isOn)
        };
        operationID = mk_cr_taskReadFilterByAdvNameReverseFilterOperation;
    }else if ([cmd isEqualToString:@"68"]) {
        //读取网络类型
        resultDic = @{
            @"serviceID":MKValidStr(content) ? content : @"",
        };
        operationID = mk_cr_taskReadFilterByServiceIDOperation;
    }else if ([cmd isEqualToString:@"69"]) {
        //读取数据上报间隔
        resultDic = @{
            @"interval":[MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(0, content.length)],
        };
        operationID = mk_cr_taskReadFilterUploadIntervalOperation;
    }
    
    return [self dataParserGetDataSuccess:resultDic operationID:operationID];
}

+ (NSDictionary *)parseCustomConfigData:(NSString *)content cmd:(NSString *)cmd {
    mk_cr_taskOperationID operationID = mk_cr_defaultTaskOperationID;
    BOOL success = [content isEqualToString:@"01"];
    if ([cmd isEqualToString:@"02"]) {
        //重启进入STA模式
        operationID = mk_cr_taskEnterSTAModeOperation;
    }else if ([cmd isEqualToString:@"0f"]) {
        //配置心跳包间隔
        operationID = mk_cr_taskConfigHeartbeatUploadIntervalOperation;
    }else if ([cmd isEqualToString:@"10"]) {
        //配置NTP服务器域名
        operationID = mk_cr_taskConfigNTPServerHostOperation;
    }else if ([cmd isEqualToString:@"12"]) {
        //配置时区
        operationID = mk_cr_taskConfigTimeZoneOperation;
    }else if ([cmd isEqualToString:@"20"]) {
        //配置MQTT服务器域名
        operationID = mk_cr_taskConfigServerHostOperation;
    }else if ([cmd isEqualToString:@"21"]) {
        //配置MQTT服务器端口
        operationID = mk_cr_taskConfigServerPortOperation;
    }else if ([cmd isEqualToString:@"22"]) {
        //配置ClientID
        operationID = mk_cr_taskConfigClientIDOperation;
    }else if ([cmd isEqualToString:@"25"]) {
        //配置MQTT Clean Session
        operationID = mk_cr_taskConfigServerCleanSessionOperation;
    }else if ([cmd isEqualToString:@"26"]) {
        //配置MQTT KeepAlive
        operationID = mk_cr_taskConfigServerKeepAliveOperation;
    }else if ([cmd isEqualToString:@"27"]) {
        //配置Broadcast Qos
        operationID = mk_cr_taskConfigBroadcastQosOperation;
    }else if ([cmd isEqualToString:@"28"]) {
        //配置Gateway Qos
        operationID = mk_cr_taskConfigGatewayQosOperation;
    }else if ([cmd isEqualToString:@"29"]) {
        //配置Device Qos
        operationID = mk_cr_taskConfigDeviceQosOperation;
    }else if ([cmd isEqualToString:@"2a"]) {
        //配置pubBroadcast topic
        operationID = mk_cr_taskConfigBroadPubTopicOperation;
    }else if ([cmd isEqualToString:@"2b"]) {
        //配置pubGateway topic
        operationID = mk_cr_taskConfigGatewayPubTopicOperation;
    }else if ([cmd isEqualToString:@"2c"]) {
        //配置subGateway topic
        operationID = mk_cr_taskConfigGatewaySubTopicOperation;
    }else if ([cmd isEqualToString:@"2d"]) {
        //配置pubDevice topic
        operationID = mk_cr_taskConfigDevicePubTopicOperation;
    }else if ([cmd isEqualToString:@"2e"]) {
        //配置subDevice topic
        operationID = mk_cr_taskConfigDeviceSubTopicOperation;
    }else if ([cmd isEqualToString:@"2f"]) {
        //配置LWT 开关
        operationID = mk_cr_taskConfigLWTStatusOperation;
    }else if ([cmd isEqualToString:@"30"]) {
        //配置LWT Qos
        operationID = mk_cr_taskConfigLWTQosOperation;
    }else if ([cmd isEqualToString:@"31"]) {
        //配置LWT Retain
        operationID = mk_cr_taskConfigLWTRetainOperation;
    }else if ([cmd isEqualToString:@"32"]) {
        //配置LWT topic
        operationID = mk_cr_taskConfigLWTTopicOperation;
    }else if ([cmd isEqualToString:@"33"]) {
        //配置LWT payload
        operationID = mk_cr_taskConfigLWTPayloadOperation;
    }else if ([cmd isEqualToString:@"34"]) {
        //配置MTQQ服务器通信加密方式
        operationID = mk_cr_taskConfigConnectModeOperation;
    }else if ([cmd isEqualToString:@"41"]) {
        //配置WIFI SSID
        operationID = mk_cr_taskConfigWIFISSIDOperation;
    }else if ([cmd isEqualToString:@"42"]) {
        //配置WIFI password
        operationID = mk_cr_taskConfigWIFIPasswordOperation;
    }else if ([cmd isEqualToString:@"43"]) {
        //配置Wifi DHCP状态
        operationID = mk_cr_taskConfigWIFIDHCPStatusOperation;
    }else if ([cmd isEqualToString:@"44"]) {
        //配置Wifi IP地址相关信息
        operationID = mk_cr_taskConfigWIFIIpInfoOperation;
    }else if ([cmd isEqualToString:@"45"]) {
        //配置Ethernet DHCP状态
        operationID = mk_cr_taskConfigEthernetDHCPStatusOperation;
    }else if ([cmd isEqualToString:@"46"]) {
        //配置Ethernet IP地址相关信息
        operationID = mk_cr_taskConfigEthernetIpInfoOperation;
    }else if ([cmd isEqualToString:@"47"]) {
        //配置APN
        operationID = mk_cr_taskConfigApnOperation;
    }else if ([cmd isEqualToString:@"48"]) {
        //配置APN用户名
        operationID = mk_cr_taskConfigApnUsernameOperation;
    }else if ([cmd isEqualToString:@"49"]) {
        //配置APN密码
        operationID = mk_cr_taskConfigApnPasswordOperation;
    }else if ([cmd isEqualToString:@"4a"]) {
        //配置PIN
        operationID = mk_cr_taskConfigPinOperation;
    }else if ([cmd isEqualToString:@"4b"]) {
        //进行一次wifi扫描
        operationID = mk_cr_taskStartWifiScanOperation;
    }else if ([cmd isEqualToString:@"4d"]) {
        //配置网络模式
        operationID = mk_cr_taskConfigNetworkTypeOperation;
    }else if ([cmd isEqualToString:@"60"]) {
        //配置扫描RSSI过滤
        operationID = mk_cr_taskConfigRssiFilterValueOperation;
    }else if ([cmd isEqualToString:@"61"]) {
        //配置精准过滤MAC开关
        operationID = mk_cr_taskConfigFilterByMacPreciseMatchOperation;
    }else if ([cmd isEqualToString:@"62"]) {
        //配置反向过滤MAC开关
        operationID = mk_cr_taskConfigFilterByMacReverseFilterOperation;
    }else if ([cmd isEqualToString:@"63"]) {
        //配置MAC过滤规则
        operationID = mk_cr_taskConfigFilterMACAddressListOperation;
    }else if ([cmd isEqualToString:@"65"]) {
        //配置精准过滤Adv Name开关
        operationID = mk_cr_taskConfigFilterByAdvNamePreciseMatchOperation;
    }else if ([cmd isEqualToString:@"66"]) {
        //配置反向过滤Adv Name开关
        operationID = mk_cr_taskConfigFilterByAdvNameReverseFilterOperation;
    }else if ([cmd isEqualToString:@"68"]) {
        //配置Serviceid过滤
        operationID = mk_cr_taskConfigFilterByServiceIDOperation;
    }else if ([cmd isEqualToString:@"69"]) {
        //配置数据上报间隔
        operationID = mk_cr_taskConfigFilterUploadIntervalOperation;
    }
    
    return [self dataParserGetDataSuccess:@{@"success":@(success)} operationID:operationID];
}

+ (NSDictionary *)parseMultiPackageReadData:(NSData *)readData cmd:(NSString *)cmd {
    NSString *readString = [MKBLEBaseSDKAdopter hexStringFromData:readData];
    NSString *totalNum = [MKBLEBaseSDKAdopter getDecimalStringWithHex:readString range:NSMakeRange(6, 2)];
    NSString *index = [MKBLEBaseSDKAdopter getDecimalStringWithHex:readString range:NSMakeRange(8, 2)];
    NSInteger len = [MKBLEBaseSDKAdopter getDecimalWithHex:readString range:NSMakeRange(10, 2)];
    if ([index integerValue] >= [totalNum integerValue]) {
        return @{};
    }
    mk_cr_taskOperationID operationID = mk_cr_defaultTaskOperationID;
    
    NSData *subData = [readData subdataWithRange:NSMakeRange(6, len)];
    NSDictionary *resultDic= @{
        mk_cr_totalNumKey:totalNum,
        mk_cr_totalIndexKey:index,
        mk_cr_contentKey:(subData ? subData : [NSData data]),
    };
    if ([cmd isEqualToString:@"23"]) {
        //读取服务器登录用户名
        operationID = mk_cr_taskReadServerUserNameOperation;
    }else if ([cmd isEqualToString:@"24"]) {
        //读取服务器登录密码
        operationID = mk_cr_taskReadServerPasswordOperation;
    }else if ([cmd isEqualToString:@"64"]) {
        //读取MAC地址黑名单
        operationID = mk_cr_taskReadFilterBlackMACAddressListOperation;
    }else if ([cmd isEqualToString:@"67"]) {
        //读取BLE Name过滤规则
        operationID = mk_cr_taskReadFilterAdvNameListOperation;
    }
    
    return [self dataParserGetDataSuccess:resultDic operationID:operationID];
}

+ (NSDictionary *)parseMultiPackageData:(NSString *)content cmd:(NSString *)cmd {
    mk_cr_taskOperationID operationID = mk_cr_defaultTaskOperationID;
    BOOL success = [content isEqualToString:@"01"];
    if ([cmd isEqualToString:@"23"]) {
        //配置服务器登录用户名
        operationID = mk_cr_taskConfigServerUserNameOperation;
    }else if ([cmd isEqualToString:@"24"]) {
        //配置服务器登录密码
        operationID = mk_cr_taskConfigServerPasswordOperation;
    }else if ([cmd isEqualToString:@"35"]) {
        //配置CA file
        operationID = mk_cr_taskConfigCAFileOperation;
    }else if ([cmd isEqualToString:@"36"]) {
        //配置Client certificate file
        operationID = mk_cr_taskConfigClientCertOperation;
    }else if ([cmd isEqualToString:@"37"]) {
        //配置Client key file
        operationID = mk_cr_taskConfigClientPrivateKeyOperation;
    }else if ([cmd isEqualToString:@"64"]) {
        //配置mac地址黑名单
        operationID = mk_cr_taskConfigFilterBlackMACAddressListOperation;
    }else if ([cmd isEqualToString:@"67"]) {
        //配置Adv Name过滤规则
        operationID = mk_cr_taskConfigFilterAdvNameListOperation;
    }
    
    return [self dataParserGetDataSuccess:@{@"success":@(success)} operationID:operationID];
}

+ (NSDictionary *)dataParserGetDataSuccess:(NSDictionary *)returnData operationID:(mk_cr_taskOperationID)operationID{
    if (!returnData) {
        return @{};
    }
    return @{@"returnData":returnData,@"operationID":@(operationID)};
}

@end
