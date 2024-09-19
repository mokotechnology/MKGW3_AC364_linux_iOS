
typedef NS_ENUM(NSInteger, mk_cr_centralConnectStatus) {
    mk_cr_centralConnectStatusUnknow,                                           //未知状态
    mk_cr_centralConnectStatusConnecting,                                       //正在连接
    mk_cr_centralConnectStatusConnected,                                        //连接成功
    mk_cr_centralConnectStatusConnectedFailed,                                  //连接失败
    mk_cr_centralConnectStatusDisconnect,
};

typedef NS_ENUM(NSInteger, mk_cr_centralManagerStatus) {
    mk_cr_centralManagerStatusUnable,                           //不可用
    mk_cr_centralManagerStatusEnable,                           //可用状态
};

typedef NS_ENUM(NSInteger, mk_cr_connectMode) {
    mk_cr_connectMode_TCP,                                          //TCP
    mk_cr_connectMode_CACertificate,                                //SSL.Verify the server's certificate
    mk_cr_connectMode_SelfSignedCertificates,                       //SSL.Two-way authentication
};

//Quality of MQQT service
typedef NS_ENUM(NSInteger, mk_cr_mqttServerQosMode) {
    mk_cr_mqttQosLevelAtMostOnce,      //At most once. The message sender to find ways to send messages, but an accident and will not try again.
    mk_cr_mqttQosLevelAtLeastOnce,     //At least once.If the message receiver does not know or the message itself is lost, the message sender sends it again to ensure that the message receiver will receive at least one, and of course, duplicate the message.
    mk_cr_mqttQosLevelExactlyOnce,     //Exactly once.Ensuring this semantics will reduce concurrency or increase latency, but level 2 is most appropriate when losing or duplicating messages is unacceptable.
};


@protocol mk_cr_centralManagerScanDelegate <NSObject>

/// Scan to new device.
/// @param deviceModel device
- (void)mk_cr_receiveDevice:(NSDictionary *)deviceModel;

@optional

/// Starts scanning equipment.
- (void)mk_cr_startScan;

/// Stops scanning equipment.
- (void)mk_cr_stopScan;

@end

@protocol mk_cr_centralManagerScanWifiDelegate <NSObject>

- (void)mk_cr_receiveWifi:(NSString *)content;

@end
