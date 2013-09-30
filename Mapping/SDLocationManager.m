//
//  SDLocationManager.m
//
//  Created by brandon on 2/11/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import "SDLocationManager.h"
#import "NSArray+SDExtensions.h"

NSString *kSDLocationManagerHasReceivedLocationUpdateDefaultsKey = @"SDLocationManagerHasReceivedLocationUpdate";

@implementation SDLocationManager
{
    BOOL _isUpdatingLocation;
    BOOL _isUpdatingHeading;
    NSMutableArray *_delegates;

	NSTimer *_timeoutTimer;
	NSDate *_timestamp;
	CLLocationAccuracy _actualDesiredAccuracy;
    BOOL _gotFirstLocationUpdate;
}

@synthesize timeout;
@synthesize hasReceivedLocationUpdate;

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
    _delegates = [[NSMutableArray alloc] init];
	
	return self;
}

- (void)dealloc
{
    
	[_timeoutTimer invalidate];
	_timeoutTimer = nil;
	
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
	_timeoutTimer = nil;
	
	// if we have a location, pass it along...
	if (self.location)
	{
        CLLocation *location = self.location;
        [_delegates makeObjectsPerformSelector:@selector(locationManager:didUpdateToLocation:fromLocation:) argumentAddresses:(void *)&self, &location, &location];
	}
	else
	{
		// otherwise, lets simulate a failure...
        NSError *error = [NSError errorWithDomain:kCLErrorDomain code:0 userInfo:nil];
        [_delegates makeObjectsPerformSelector:@selector(locationManager:didFailWithError:) argumentAddresses:(void *)&self, &error];
	}
}

- (void)internalStart
{
	// make ourselves a timestamp to compare against.
	_timestamp = [NSDate date];
	
	if ([_delegates count] > 0)
		[super setDelegate:self];	
	else
		[super setDelegate:nil];	
}

- (void)internalStop
{
	[_timeoutTimer invalidate];
	_timeoutTimer = nil;
	
	_timestamp = nil;

	[super setDelegate:nil];
}

- (CLAuthorizationStatus)authorizationStatus
{
    return [CLLocationManager authorizationStatus];
}

- (BOOL)isLocationAllowed
{
    if (self.authorizationStatus == kCLAuthorizationStatusAuthorized || self.authorizationStatus == kCLAuthorizationStatusNotDetermined)
        return YES;
    return NO;
}

- (BOOL)startUpdatingLocationWithDelegate:(id<SDLocationManagerDelegate>)delegate
{
    [_delegates addObject:delegate];
    if (!_isUpdatingLocation)
    {
        _isUpdatingLocation = YES;
        [self internalStart];

        if ([self isLocationAllowed])
        {
            [super startUpdatingLocation];
        }
        else
        {
            [self locationManager:self didFailWithError:[NSError errorWithDomain:kCLErrorDomain code:kCLErrorDenied userInfo:nil]];
            [self stopUpdatingLocationWithDelegate:delegate];
            return NO;
        }
    }

    return YES;
}

- (void)stopUpdatingLocationWithDelegate:(id<SDLocationManagerDelegate>)delegate
{
    [_delegates removeObject:delegate];
    if ([_delegates count] == 0 && _isUpdatingLocation)
    {
        _isUpdatingLocation = NO;
        [self internalStop];
        [super stopUpdatingLocation];
    }
}

- (void)stopUpdatingLocationForAllDelegates
{
    NSArray *delegates = [_delegates copy];
    for (id delegate in delegates) {
        [self stopUpdatingLocationWithDelegate:delegate];
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
	_actualDesiredAccuracy = anAccuracy;
	// actually set it somewhat below what we want.  this insures we get something under what we asked for.
	anAccuracy -= 600;
	if (anAccuracy < 10)
		anAccuracy = kCLLocationAccuracyBest;
	[super setDesiredAccuracy:anAccuracy];
}

#pragma mark CoreLocationManager delegates

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if ( ! _gotFirstLocationUpdate )
    {
        // dont start the timeout until we got the first location change, which should only happen after the user said YES to
        // Apple's built-in prompt to use current location, or if use of location was pre-approved in a previous run. And once
        // approved, this should always get called at least once, so we should never have a case of waiting forever to get here
        _gotFirstLocationUpdate = YES;
		
		//Ensure this is set as well. This BOOL differs slightly from 'gotFirstLocationUpdate' and is handled separately as such:
		[[NSUserDefaults standardUserDefaults] setBool: YES forKey: kSDLocationManagerHasReceivedLocationUpdateDefaultsKey];
		
        // timeout in 60 (or whatever they set it to) seconds.
        _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(timeoutHandler) userInfo:nil repeats:NO];
    }
    
	SDLog(@"newLocation = %@", newLocation);
	SDLog(@"desiredAccuracy = %f", self.desiredAccuracy);
	if ([newLocation.timestamp timeIntervalSinceDate:_timestamp] < 0)
	{
		SDLog(@"SDLocationManager: this location was cached.");
        [_delegates makeObjectsPerformSelector:@selector(locationManager:didUpdateToInaccurateLocation:fromLocation:) argumentAddresses:(void *)&self, &newLocation, &oldLocation];
		return; // this one is cached, lets wait for a good one.
	}
	
	// if the accuracy is within what we're looking for, OR.. we got the same accuracy multiple times.. continue on..
	if ((newLocation.horizontalAccuracy >= _actualDesiredAccuracy) || (newLocation.horizontalAccuracy > oldLocation.horizontalAccuracy))
	{
		SDLog(@"SDLocationManager: this location didn't meet the accuracy requirements (%f).", newLocation.horizontalAccuracy);
		//return; // the accuracy isn't good enough, wait some more...
        [_delegates makeObjectsPerformSelector:@selector(locationManager:didUpdateToInaccurateLocation:fromLocation:) argumentAddresses:(void *)&self, &newLocation, &oldLocation];
        return;
	}
	
	SDLog(@"SDLocationManager: location obtained.");
    [_delegates makeObjectsPerformSelector:_cmd argumentAddresses:(void *)&self, &newLocation, &oldLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
	if ([newHeading.timestamp timeIntervalSinceDate:_timestamp] < 0)
		return; // this one is cached, lets wait for a good one.
	
    [_delegates makeObjectsPerformSelector:_cmd argumentAddresses:(void *)&self, &newHeading];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	// we're masking out didFail unless they've said NO to the "allow" dialog.
	if ([error.domain isEqualToString:kCLErrorDomain] && error.code == kCLErrorDenied)
        [_delegates makeObjectsPerformSelector:_cmd argumentAddresses:(void *)&self, &error];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [_delegates makeObjectsPerformSelector:_cmd argumentAddresses:(void *)&self, &region];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [_delegates makeObjectsPerformSelector:_cmd argumentAddresses:(void *)&self, &region];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    [_delegates makeObjectsPerformSelector:_cmd argumentAddresses:(void *)&self, &region, &error];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    [self unsupported];
    return FALSE;
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        [self stopUpdatingLocationForAllDelegates];
    }
}

@end
