//
//  SDLocationManager.m
//
//  Created by brandon on 2/11/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import "SDLocationManager.h"
#import "NSArray+SDExtensions.h"

NSString *kSDLocationManagerHasReceivedLocationUpdateDefaultsKey = @"SDLocationManagerHasReceivedLocationUpdate";

@implementation SDLocationManager

@synthesize timeout;
@synthesize hasReceivedLocationUpdate;
@synthesize isUpdatingLocation;

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
    delegates = [[NSMutableArray alloc] init];
	
	return self;
}

- (void)dealloc
{
    
	[timeoutTimer invalidate];
	timeoutTimer = nil;
	
}

- (void)unsupported
{
    //[[NSException exceptionWithName:@"Unsupported" reason:@"See SDLocationManager.h, as this is deprecated." userInfo:nil] raise];    
}

-(BOOL)hasReceivedLocationUpdate
{
	return [[NSUserDefaults standardUserDefaults] boolForKey: kSDLocationManagerHasReceivedLocationUpdateDefaultsKey];
}

- (void)setDelegate:(id<CLLocationManagerDelegate>)delegate { [self unsupported]; }
- (void)startUpdatingLocation { [self unsupported]; }
- (void)stopUpdatingLocation { [self unsupported]; }
- (void)startUpdatingHeading { [self unsupported]; }
- (void)stopUpdatingHeading { [self unsupported]; }

- (void)timeoutHandler
{
	timeoutTimer = nil;
	
	//SDLog(@"SDLocationManager - Timeout triggered!");
	
	// if we have a location, pass it along...
	if (self.location)
	{
        CLLocation *location = self.location;
        [delegates callSelector:@selector(locationManager:didUpdateToLocation:fromLocation:) argumentAddresses:(__bridge void *)(self), location, location];
		//if (delegate && [delegate respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)])
		//	[delegate locationManager:self didUpdateToLocation:self.location fromLocation:self.location];
	}
	else
	{
		// otherwise, lets simulate a failure...
        NSError *error = [NSError errorWithDomain:kCLErrorDomain code:0 userInfo:nil];
        [delegates callSelector:@selector(locationManager:didFailWithError:) argumentAddresses:(__bridge void *)(self), error];
		//if (delegate && [delegate respondsToSelector:@selector(locationManager:didFailWithError:)])
		//	[delegate locationManager:self didFailWithError:[NSError errorWithDomain:kCLErrorDomain code:0 userInfo:nil]];
	}
}

- (void)internalStart
{
	// make ourselves a timestamp to compare against.
	timestamp = [NSDate date];
	
	if ([delegates count] > 0)
		[super setDelegate:self];	
	else
		[super setDelegate:nil];	
}

- (void)internalStop
{
	[timeoutTimer invalidate];
	timeoutTimer = nil;
	
	timestamp = nil;

	[super setDelegate:nil];
}

- (void)startUpdatingLocationWithDelegate:(id<SDLocationManagerDelegate>)delegate
{
    [delegates addObject:delegate];
    if (!isUpdatingLocation)
    {
        isUpdatingLocation = YES;
        [self internalStart];
        [super startUpdatingLocation];
    }
}

- (void)stopUpdatingLocationWithDelegate:(id<SDLocationManagerDelegate>)delegate
{
    [delegates removeObject:delegate];
    if ([delegates count] == 0 && isUpdatingLocation)
    {
        isUpdatingLocation = NO;
        [self internalStop];
        [super stopUpdatingLocation];
    }
}

- (void)startUpdatingHeadingWithDelegate:(id<SDLocationManagerDelegate>)delegate
{
	[self internalStart];
	[super startUpdatingHeading];
}

- (void)stopUpdatingHeadingWithDelegate:(id<SDLocationManagerDelegate>)delegate
{
	[self internalStop];
	[super stopUpdatingHeading];
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
		
		//Ensure this is set as well. This BOOL differs slightly from 'gotFirstLocationUpdate' and is handled separately as such:
		[[NSUserDefaults standardUserDefaults] setBool: YES forKey: kSDLocationManagerHasReceivedLocationUpdateDefaultsKey];
		
        // timeout in 60 (or whatever they set it to) seconds.
        timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(timeoutHandler) userInfo:nil repeats:NO];
    }
    
	SDLog(@"newLocation = %@", newLocation);
	SDLog(@"desiredAccuracy = %f", self.desiredAccuracy);
	if ([newLocation.timestamp timeIntervalSinceDate:timestamp] < 0)
	{
		SDLog(@"SDLocationManager: this location was cached.");
        [delegates callSelector:@selector(locationManager:didUpdateToInaccurateLocation:fromLocation:) argumentAddresses:(__bridge void *)(self), newLocation, oldLocation];
        //if (delegate && [delegate respondsToSelector:@selector(locationManager:didUpdateToInaccurateLocation:fromLocation:)])
        //    [delegate locationManager:self didUpdateToInaccurateLocation:newLocation fromLocation:oldLocation];
		return; // this one is cached, lets wait for a good one.
	}
	
	// if the accuracy is within what we're looking for, OR.. we got the same accuracy multiple times.. continue on..
	if ((newLocation.horizontalAccuracy >= actualDesiredAccuracy) || (newLocation.horizontalAccuracy > oldLocation.horizontalAccuracy))
	{
		SDLog(@"SDLocationManager: this location didn't meet the accuracy requirements (%f).", newLocation.horizontalAccuracy);
		//return; // the accuracy isn't good enough, wait some more...
        [delegates callSelector:@selector(locationManager:didUpdateToInaccurateLocation:fromLocation:) argumentAddresses:(__bridge void *)(self), newLocation, oldLocation];
        //if (delegate && [delegate respondsToSelector:@selector(locationManager:didUpdateToInaccurateLocation:fromLocation:)])
        //    [delegate locationManager:self didUpdateToInaccurateLocation:newLocation fromLocation:oldLocation];
        return;
	}
	
	SDLog(@"SDLocationManager: location obtained.");
    //[delegates callSelector:_cmd argumentAddresses:(__bridge void *)(self), newLocation, oldLocation];
    // the above callSelector was crashing, so this loop is a work-around until Brandon finds a solution
    NSArray *delegatesCopy = [delegates copy];
    for (id<SDLocationManagerDelegate> aDelegate in delegatesCopy)
    {
        if ([aDelegate respondsToSelector:_cmd])
        {
            [aDelegate locationManager:self didUpdateToLocation:newLocation fromLocation:oldLocation];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
	if ([newHeading.timestamp timeIntervalSinceDate:timestamp] < 0)
		return; // this one is cached, lets wait for a good one.
	
    [delegates callSelector:_cmd argumentAddresses:(__bridge void *)(self), newHeading];
	//if (delegate && [delegate respondsToSelector:_cmd])
	//	[delegate locationManager:self didUpdateHeading:newHeading];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	// we're masking out didFail unless they've said NO to the "allow" dialog.
	if ([error.domain isEqualToString:kCLErrorDomain] && error.code == kCLErrorDenied)
	{
        [delegates callSelector:_cmd argumentAddresses:(__bridge void *)(self), error];
		//if (delegate && [delegate respondsToSelector:_cmd])
		//	[delegate locationManager:self didFailWithError:error];
	}	
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [delegates callSelector:_cmd argumentAddresses:(__bridge void *)(self), region];
	//if (delegate && [delegate respondsToSelector:_cmd])
	//	[delegate locationManager:self didEnterRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [delegates callSelector:_cmd argumentAddresses:(__bridge void *)(self), region];
	//if (delegate && [delegate respondsToSelector:_cmd])
	//	[delegate locationManager:self didExitRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    [delegates callSelector:_cmd argumentAddresses:(__bridge void *)(self), region, error];
	//if (delegate && [delegate respondsToSelector:_cmd])
	//	[delegate locationManager:self monitoringDidFailForRegion:region withError:error];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    [self unsupported];
    return FALSE;
	//if (delegate && [delegate respondsToSelector:_cmd])
	//	return [delegate locationManagerShouldDisplayHeadingCalibration:self];
	//return FALSE;
}

@end
