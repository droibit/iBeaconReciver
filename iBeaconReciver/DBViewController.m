//
//  DBViewController.m
//  iBeaconReciver
//
//  Created by kumagai on 2014/04/05.
//  Copyright (c) 2014年 kumagai. All rights reserved.
//

#import "DBViewController.h"

@interface DBViewController ()

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSUUID *proximityUUID;
@property (nonatomic) CLBeaconRegion *beaconRegion;

@end

@implementation DBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        // CLLocationManagerの生成とデリゲートの設定
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        
        self.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID
                                                               identifier:[[NSBundle mainBundle] bundleIdentifier]];
        // Beaconによる領域観測を開始
        [self.locationManager startMonitoringForRegion:self.beaconRegion];
     }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocation Manager Delegate

- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region
{
    // Beaconの距離測定を開始する
    if ([self isBeaconRegionAvailable:region]) {
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
    
    [self notificationWithMessage:@"Beaconの範囲内に入りました"];
}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region
{
    // Beaconの距離測定を終了する
    if ([self isBeaconRegionAvailable:region]) {
        [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
    
    [self notificationWithMessage:@"Beaconの範囲内に入りました"];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    // #locationManager:didDetermineState:forRegion:メソッドが呼ばれるようにする。
    // ※ Beaconのリージョン内に入っている状態で監視を始めた場合、Enterイベントが走らないため
    [self.locationManager requestStateForRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state
              forRegion:(CLRegion *)region
{
    // 既にBeaconリージョン内に入っている
    if (state == CLRegionStateInside) {
        if ([self isBeaconRegionAvailable:region]) {
            [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
        }
    }
 }

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region
{
    if (beacons.count == 0) {
        return;
    }
    // 最も距離の近いBeaconについて処理する
    CLBeacon *nearestBeacon = beacons.firstObject;
    
    NSString *proximityString;
    switch (nearestBeacon.proximity) {
        case CLProximityImmediate:
            proximityString = @"かなり近い";
            break;
        case CLProximityNear:
            proximityString = @"近い";
            break;
        case CLProximityFar:
            proximityString = @"遠い";
            break;
        default:
            proximityString = @"不明";
            break;
    }
    
    self.uuidLabel.text = nearestBeacon.proximityUUID.UUIDString;
    self.majorLabel.text = [NSString stringWithFormat:@"%@", nearestBeacon.major];
    self.minorLabel.text = [NSString stringWithFormat:@"%@", nearestBeacon.minor];
    self.proximityLabel.text = proximityString;
    self.accuracyLabel.text = [NSString stringWithFormat:@"%f", nearestBeacon.accuracy];
    self.rssiLabel.text = [NSString stringWithFormat:@"%ld", (long)nearestBeacon.rssi];
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region
              withError:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSLog(@"Domain: %@, Error Code: %ld",error.domain, (long)error.code);
}

#pragma mark - Private Methods

- (void)notificationWithMessage:(NSString *)message
{
    // 以前の通知をキャンセルしておく
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    // 新しい情報を通知する
    UILocalNotification *notification = [UILocalNotification new];
    notification.fireDate = [[NSDate date] init];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertBody = message;
    //notification.alertAction = @"Open";
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (BOOL)isBeaconRegionAvailable:(CLRegion *)region
{
    return [region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable];
}

@end
