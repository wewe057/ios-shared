//
//  SDLocationManager.h
//
//  Created by brandon on 2/11/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SDLog.h"

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
