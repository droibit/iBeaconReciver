//
//  DBViewController.h
//  iBeaconReciver
//
//  Created by kumagai on 2014/04/05.
//  Copyright (c) 2014年 kumagai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface DBViewController : UIViewController<CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *proximityLabel;

@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *majorLabel;
@property (weak, nonatomic) IBOutlet UILabel *minorLabel;
@property (weak, nonatomic) IBOutlet UILabel *accuracyLabel;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;

@end
