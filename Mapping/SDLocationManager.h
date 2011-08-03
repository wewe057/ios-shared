//
//  SDLocationManager.h
//
//  Created by brandon on 2/11/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SDLog.h"

@protocol SDLocationManagerDelegate <NSObject>
@optional
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
- (void)locationManager:(CLLocationManager *)manager didUpdateToInaccurateLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);
- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager  __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0);
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0);
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0);
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_2);

@end

@interface SDLocationManager: CLLocationManager <CLLocationManagerDelegate>
{
	id delegate;
	NSTimeInterval timeout;
	
	NSTimer *timeoutTimer;
	NSDate *timestamp;
	CLLocationAccuracy actualDesiredAccuracy;
    BOOL gotFirstLocationUpdate;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) NSTimeInterval timeout;

+ (SDLocationManager *)instance;

@end
