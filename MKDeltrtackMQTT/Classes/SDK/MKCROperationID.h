

typedef NS_ENUM(NSInteger, mk_cr_taskOperationID) {
    mk_cr_defaultTaskOperationID,
    
#pragma mark - Read
    mk_cr_taskReadDeviceModelOperation,        //读取产品型号
    mk_cr_taskReadFirmwareOperation,           //读取固件版本
    mk_cr_taskReadHardwareOperation,           //读取硬件类型
    mk_cr_taskReadSoftwareOperation,           //读取软件版本
    mk_cr_taskReadManufacturerOperation,       //读取厂商信息
    
#pragma mark - 自定义协议读取
    mk_cr_taskReadEthernetMacOperation,         //读取以太网MAC
    mk_cr_taskReadDeviceNameOperation,         //读取设备名称
    mk_cr_taskReadDeviceMacAddressOperation,    //读取MAC地址
    mk_cr_taskReadDeviceWifiSTAMacAddressOperation, //读取WIFI STA MAC地址
    mk_cr_taskReadHeartbeatUploadIntervalOperation,       //读取心跳包间隔
    mk_cr_taskReadNTPServerHostOperation,       //读取NTP服务器域名
    mk_cr_taskReadIMEIOperation,            //读取IMEI
    mk_cr_taskReadICCIDOperation,           //读取ICCID
    
#pragma mark - Wifi Params
    mk_cr_taskReadWIFISSIDOperation,            //读取设备当前的wifi ssid
    mk_cr_taskReadWIFIPasswordOperation,        //读取设备当前的wifi密码
    mk_cr_taskReadWIFIDHCPStatusOperation,              //读取Wifi DHCP开关
    mk_cr_taskReadWIFINetworkIpInfosOperation,          //读取Wifi IP信息
    mk_cr_taskReadEthernetDHCPStatusOperation,          //读取Ethernet DHCP开关
    mk_cr_taskReadEthernetNetworkIpInfosOperation,      //读取Ethernet IP信息
    mk_cr_taskReadApnOperation,                 //读取APN
    mk_cr_taskReadApnUsernameOperation,         //读取APN用户名
    mk_cr_taskReadApnPasswordOperation,         //读取APN密码
    mk_cr_taskReadPinOperation,                 //读取PIN
    mk_cr_taskReadNetworkTypeOperation,                 //读取网络类型
    
#pragma mark - MQTT Params
    mk_cr_taskReadServerHostOperation,          //读取MQTT服务器域名
    mk_cr_taskReadServerPortOperation,          //读取MQTT服务器端口
    mk_cr_taskReadClientIDOperation,            //读取Client ID
    mk_cr_taskReadServerUserNameOperation,      //读取服务器登录用户名
    mk_cr_taskReadServerPasswordOperation,      //读取服务器登录密码
    mk_cr_taskReadServerCleanSessionOperation,  //读取MQTT Clean Session
    mk_cr_taskReadServerKeepAliveOperation,     //读取MQTT KeepAlive
    mk_cr_taskReadBroadcastQosOperation,           //读取Broadcast Qos
    mk_cr_taskReadGatewayQosOperation,             //读取Gateway Qos
    mk_cr_taskReadDeviceQosOperation,              //读取Device Qos
    mk_cr_taskReadBroadPubTopicOperation,          //读取pubBroadcast topic
    mk_cr_taskReadGatewayPubTopicOperation,        //读取pubGateway topic
    mk_cr_taskReadGatewaySubTopicOperation,        //读取subGateway topic
    mk_cr_taskReadDevicePubTopicOperation,         //读取pubDevice topic
    mk_cr_taskReadDeviceSubTopicOperation,         //读取subDevice topic
    mk_cr_taskReadLWTStatusOperation,           //读取LWT开关状态
    mk_cr_taskReadLWTQosOperation,              //读取LWT Qos
    mk_cr_taskReadLWTRetainOperation,           //读取LWT Retain
    mk_cr_taskReadLWTTopicOperation,            //读取LWT topic
    mk_cr_taskReadLWTPayloadOperation,          //读取LWT Payload
    mk_cr_taskReadConnectModeOperation,         //读取MTQQ服务器通信加密方式
    
#pragma mark - Filter Params
    mk_cr_taskReadRssiFilterValueOperation,             //读取扫描RSSI过滤
    mk_cr_taskReadFilterByMacPreciseMatchOperation, //读取精准过滤MAC开关
    mk_cr_taskReadFilterByMacReverseFilterOperation,    //读取反向过滤MAC开关
    mk_cr_taskReadFilterMACAddressListOperation,        //读取MAC过滤列表
    mk_cr_taskReadFilterBlackMACAddressListOperation,   //读取MAC地址黑名单
    mk_cr_taskReadFilterByAdvNamePreciseMatchOperation, //读取精准过滤ADV Name开关
    mk_cr_taskReadFilterByAdvNameReverseFilterOperation,    //读取反向过滤ADV Name开关
    mk_cr_taskReadFilterAdvNameListOperation,           //读取ADV Name过滤列表
    mk_cr_taskReadFilterByServiceIDOperation,           //读取Serviceid过滤
    mk_cr_taskReadFilterUploadIntervalOperation,        //读取数据上报间隔
    
    
#pragma mark - 密码特征
    mk_cr_connectPasswordOperation,             //连接设备时候发送密码
    
#pragma mark - 配置
    mk_cr_taskEnterSTAModeOperation,                //设备重启进入STA模式
    mk_cr_taskConfigHeartbeatUploadIntervalOperation,   //配置心跳包间隔
    mk_cr_taskConfigNTPServerHostOperation,         //配置NTP服务器域名
    mk_cr_taskConfigTimeZoneOperation,              //配置时区
    
#pragma mark - Wifi Params
    
    mk_cr_taskConfigWIFISSIDOperation,          //配置wifi的ssid
    mk_cr_taskConfigWIFIPasswordOperation,      //配置wifi的密码
    mk_cr_taskConfigWIFIDHCPStatusOperation,                //配置Wifi DHCP开关
    mk_cr_taskConfigWIFIIpInfoOperation,                    //配置Wifi IP地址相关信息
    mk_cr_taskConfigEthernetDHCPStatusOperation,            //配置Ethernet DHCP开关
    mk_cr_taskConfigEthernetIpInfoOperation,                //配置Ethernet IP地址相关信息
    mk_cr_taskConfigApnOperation,                       //配置APN
    mk_cr_taskConfigApnUsernameOperation,               //配置APN用户名
    mk_cr_taskConfigApnPasswordOperation,               //配置APN密码
    mk_cr_taskConfigPinOperation,                       //配置PIN
    mk_cr_taskStartWifiScanOperation,                   //进行一次wifi扫描
    mk_cr_taskConfigNetworkTypeOperation,               //配置网络模式
    
#pragma mark - MQTT Params
    mk_cr_taskConfigServerHostOperation,        //配置MQTT服务器域名
    mk_cr_taskConfigServerPortOperation,        //配置MQTT服务器端口
    mk_cr_taskConfigClientIDOperation,              //配置ClientID
    mk_cr_taskConfigServerUserNameOperation,        //配置服务器的登录用户名
    mk_cr_taskConfigServerPasswordOperation,        //配置服务器的登录密码
    mk_cr_taskConfigServerCleanSessionOperation,    //配置MQTT Clean Session
    mk_cr_taskConfigServerKeepAliveOperation,       //配置MQTT KeepAlive
    mk_cr_taskConfigBroadcastQosOperation,             //配置Broadcast Qos
    mk_cr_taskConfigGatewayQosOperation,               //配置Gateway Qos
    mk_cr_taskConfigDeviceQosOperation,                //配置Device Qos
    mk_cr_taskConfigBroadPubTopicOperation,            //配置pubBroadcast topic
    mk_cr_taskConfigGatewayPubTopicOperation,          //配置pubGateway topic
    mk_cr_taskConfigGatewaySubTopicOperation,          //配置subGateway topic
    mk_cr_taskConfigDevicePubTopicOperation,           //配置pubDevice topic
    mk_cr_taskConfigDeviceSubTopicOperation,           //配置subDevice topic
    mk_cr_taskConfigLWTStatusOperation,             //配置LWT开关
    mk_cr_taskConfigLWTQosOperation,                //配置LWT Qos
    mk_cr_taskConfigLWTRetainOperation,             //配置LWT Retain
    mk_cr_taskConfigLWTTopicOperation,              //配置LWT topic
    mk_cr_taskConfigLWTPayloadOperation,            //配置LWT payload
    mk_cr_taskConfigConnectModeOperation,           //配置MTQQ服务器通信加密方式
    mk_cr_taskConfigCAFileOperation,                //配置CA证书
    mk_cr_taskConfigClientCertOperation,            //配置设备证书
    mk_cr_taskConfigClientPrivateKeyOperation,      //配置私钥
        
#pragma mark - 过滤参数
    mk_cr_taskConfigRssiFilterValueOperation,                   //配置扫描RSSI过滤
    mk_cr_taskConfigFilterByMacPreciseMatchOperation,   //配置精准过滤MAC开关
    mk_cr_taskConfigFilterByMacReverseFilterOperation,  //配置反向过滤MAC开关
    mk_cr_taskConfigFilterMACAddressListOperation,      //配置MAC过滤规则
    mk_cr_taskConfigFilterBlackMACAddressListOperation, //配置mac地址黑名单
    mk_cr_taskConfigFilterByAdvNamePreciseMatchOperation,   //配置精准过滤Adv Name开关
    mk_cr_taskConfigFilterByAdvNameReverseFilterOperation,  //配置反向过滤Adv Name开关
    mk_cr_taskConfigFilterAdvNameListOperation,             //配置Adv Name过滤规则
    mk_cr_taskConfigFilterByServiceIDOperation,             //配置Serviceid过滤
    mk_cr_taskConfigFilterUploadIntervalOperation,          //配置数据上报间隔
};

