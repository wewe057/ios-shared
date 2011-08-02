//
//  SDLocationManager.m
//
//  Created by brandon on 2/11/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import "SDLocationManager.h"

@implementation SDLocationManager

@synthesize delegate;
@synthesize timeout;

static SDLocationManager *sdLocationManagerInstance = NULL;

+ (SDLocationManager *) instance
{
	if (sdLocationManagerInstance == NULL)
	{
		sdLocationManagerInstance = [self new];
	}
	return sdLocationManagerInstance;
}

- (id)init
{
	self = [super init];
	
	timeout = 60;
	
	return self;
}

- (void)dealloc
{
	[timeoutTimer invalidate];
	timeoutTimer = nil;
	
	[super dealloc];
}

- (void)timeoutHandler
{
	timeoutTimer = nil;
	
	//SDLog(@"SDLocationManager - Timeout triggered!");
	
	// if we have a location, pass it along...
	if (self.location)
	{
		if (delegate && [delegate respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)])
			[delegate locationManager:self didUpdateToLocation:self.location fromLocation:self.location];
	}
	else
	{
		// otherwise, lets simulate a failure...
		if (delegate && [delegate respondsToSelector:@selector(locationManager:didFailWithError:)])
			[delegate locationManager:self didFailWithError:[NSError errorWithDomain:kCLErrorDomain code:0 userInfo:nil]];
	}
}

- (void)internalStart
{
	// make ourselves a timestamp to compare against.
	timestamp = [[NSDate date] retain];
	
	if (delegate)
		[super setDelegate:self];	
	else
		[super setDelegate:nil];	
}

- (void)internalStop
{
	[timeoutTimer invalidate];
	timeoutTimer = nil;
	
	[timestamp release];
	timestamp = nil;

	[super setDelegate:nil];
}

- (void)startUpdatingLocation
{
	[self internalStart];
	[super startUpdatingLocation];
}

- (void)stopUpdatingLocation
{
	[self internalStop];
	[super stopUpdatingLocation];
}

- (void)startUpdatingHeading
{
	[self internalStart];
	[super startUpdatingHeading];
}

- (void)stopUpdatingHeading
{
	[self internalStop];
	[super stopUpdatingHeading];
}

- (void)setDelegate:(id)aDelegate
{
	delegate = aDelegate;
}

- (id)delegate
{
	return delegate;
}

- (void)setDesiredAccuracy:(CLLocationAccuracy)anAccuracy
{
	actualDesiredAccuracy = anAccuracy;
	// actually set it somewhat below what we want.  this insures we get something under what we asked for.
	anAccuracy -= 600;
	if (anAccuracy < 10)
		anAccuracy = kCLLocationAccuracyBest;
	[super setDesiredAccuracy:anAccuracy];
}

#pragma mark CoreLocationManager delegates

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if ( ! gotFirstLocationUpdate )
    {
        // dont start the timeout until we got the first location change, which should only happen after the user said YES to
        // Apple's built-in prompt to use current location, or if use of location was pre-approved in a previous run. And once
        // approved, this should always get called at least once, so we should never have a case of waiting forever to get here
        gotFirstLocationUpdate = YES;
        // timeout in 60 (or whatever they set it to) seconds.
        timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(timeoutHandler) userInfo:nil repeats:NO];
    }
    
	SDLog(@"newLocation = %@", newLocation);
	SDLog(@"desiredAccuracy = %f", self.desiredAccuracy);
	if ([newLocation.timestamp timeIntervalSinceDate:timestamp] < 0)
	{
		SDLog(@"SDLocationManager: this location was cached.");
        if (delegate && [delegate respondsToSelector:@selector(locationManager:didUpdateToInaccurateLocation:fromLocation:)])
            [delegate locationManager:self didUpdateToInaccurateLocation:newLocation fromLocation:oldLocation];
		return; // this one is cached, lets wait for a good one.
	}
	
	// if the accuracy is within what we're looking for, OR.. we got the same accuracy multiple times.. continue on..
	if ((newLocation.horizontalAccuracy >= actualDesiredAccuracy) || (newLocation.horizontalAccuracy > oldLocation.horizontalAccuracy))
	{
		SDLog(@"SDLocationManager: this location didn't meet the accuracy requirements (%f).", newLocation.horizontalAccuracy);
		//return; // the accuracy isn't good enough, wait some more...
        if (delegate && [delegate respondsToSelector:@selector(locationManager:didUpdateToInaccurateLocation:fromLocation:)])
            [delegate locationManager:self didUpdateToInaccurateLocation:newLocation fromLocation:oldLocation];
        return;
	}
	
	SDLog(@"SDLocationManager: location obtained.");
	if (delegate && [delegate respondsToSelector:_cmd])
		[delegate locationManager:self didUpdateToLocation:newLocation fromLocation:oldLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
	if ([newHeading.timestamp timeIntervalSinceDate:timestamp] < 0)
		return; // this one is cached, lets wait for a good one.
	
	if (delegate && [delegate respondsToSelector:_cmd])
		[delegate locationManager:self didUpdateHeading:newHeading];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	// we're masking out didFail unless they've said NO to the "allow" dialog.
	if ([error.domain isEqualToString:kCLErrorDomain] && error.code == kCLErrorDenied)
	{
		if (delegate && [delegate respondsToSelector:_cmd])
			[delegate locationManager:self didFailWithError:error];
	}	
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
	if (delegate && [delegate respondsToSelector:_cmd])
		[delegate locationManager:self didEnterRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
	if (delegate && [delegate respondsToSelector:_cmd])
		[delegate locationManager:self didExitRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
	if (delegate && [delegate respondsToSelector:_cmd])
		[delegate locationManager:self monitoringDidFailForRegion:region withError:error];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
	if (delegate && [delegate respondsToSelector:_cmd])
		return [delegate locationManagerShouldDisplayHeadingCalibration:self];
	return FALSE;
}

@end
