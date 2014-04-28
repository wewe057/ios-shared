//
//  SDLocationManager.m
//
//  Created by brandon on 2/11/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

@import CoreLocation;

#import "SDLocationManager.h"
#import "NSArray+SDExtensions.h"


NSString *kSDLocationManagerHasReceivedLocationUpdateDefaultsKey = @"SDLocationManagerHasReceivedLocationUpdate";


@interface SDLocationManagerDelegateRegistration : NSObject
@property (nonatomic, strong) id<SDLocationManagerDelegate> delegate;
@property (nonatomic) CLLocationAccuracy desiredAccuracy;
@end
@implementation SDLocationManagerDelegateRegistration
- (NSUInteger) hash {
    return [self.delegate hash];
}
- (BOOL) isEqual:(id)object {
    if (NO == [object isKindOfClass:[self class]]) {
        return NO;
    }
    return self.delegate == [(SDLocationManagerDelegateRegistration *)object delegate];
}
@end


@interface SDLocationManager ()
@property (nonatomic, strong) NSMutableSet *delegateRegistrations;
@property (nonatomic, readonly) NSArray *delegates;
@property (nonatomic, readonly) CLLocationAccuracy highestDesiredAccuracy;
@end


@implementation SDLocationManager
{
    BOOL _isUpdatingLocation;
    BOOL _isUpdatingHeading;

	NSTimer *_timeoutTimer;
	NSDate *_timestamp;
    BOOL _gotFirstLocationUpdate;
}



#pragma mark - Properties



@synthesize timeout;

@dynamic hasReceivedLocationUpdate;
-(BOOL)hasReceivedLocationUpdate
{
	return [[NSUserDefaults standardUserDefaults] boolForKey: kSDLocationManagerHasReceivedLocationUpdateDefaultsKey];
}

@dynamic delegates;
- (NSArray *) delegates {
    NSSet *delegates = [_delegateRegistrations valueForKey:@"delegate"];
    return [delegates allObjects];
}

@dynamic highestDesiredAccuracy;
- (CLLocationAccuracy) highestDesiredAccuracy {
    CLLocationAccuracy desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    for (SDLocationManagerDelegateRegistration *registration in _delegateRegistrations) {
        if (registration.desiredAccuracy < desiredAccuracy) {
            desiredAccuracy = registration.desiredAccuracy;
        }
    }
    return desiredAccuracy;
}


#pragma mark - Object



+ (SDLocationManager *) instance {
    static SDLocationManager *sdLocationManagerInstance = nil;
    static dispatch_once_t locationManagerInitToken;
    dispatch_once(&locationManagerInitToken, ^{
        if (nil == sdLocationManagerInstance) {
            sdLocationManagerInstance = [self new];
        }
    });
	return sdLocationManagerInstance;
}

- (id)init
{
	self = [super init];
	
	timeout = 60;
    _delegateRegistrations = [[NSMutableSet alloc] init];
	
	return self;
}

- (void)dealloc
{
    
	[_timeoutTimer invalidate];
	_timeoutTimer = nil;
	
}




#pragma mark - Internal




- (void)timeoutHandler
{
	_timeoutTimer = nil;
	
	// if we have a location, pass it along...
	if (self.location)
	{
        CLLocation *location = self.location;
        [self.delegates makeObjectsPerformSelector:@selector(locationManager:didUpdateToLocation:fromLocation:) argumentAddresses:(void *)&self, &location, &location];
	}
	else
	{
		// otherwise, lets simulate a failure...
        NSError *error = [NSError errorWithDomain:kCLErrorDomain code:0 userInfo:nil];
        [self.delegates makeObjectsPerformSelector:@selector(locationManager:didFailWithError:) argumentAddresses:(void *)&self, &error];
	}
}

- (void)internalStart
{
	// make ourselves a timestamp to compare against.
	_timestamp = [NSDate date];
	
	if ([_delegateRegistrations count] > 0)
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

- (void) registerDelegate:(id<SDLocationManagerDelegate>)delegate forDesiredAccuracy:(CLLocationAccuracy)accuracy {
    SDLocationManagerDelegateRegistration *delegateRegistration = [SDLocationManagerDelegateRegistration new];
    delegateRegistration.delegate = delegate;

    CLLocationAccuracy desiredAccuracy = accuracy;

    // Removing this does break past expectations but do we want to do this for every delegate?

//    // actually set it somewhat below what we want.  this insures we get something under what we asked for.
//    desiredAccuracy -= 600;
//    if (desiredAccuracy < 10) {
//        desiredAccuracy = kCLLocationAccuracyBest;
//    }

    delegateRegistration.desiredAccuracy = desiredAccuracy;
    [_delegateRegistrations addObject:delegateRegistration];
}

- (void) deregisterDelegate:(id<SDLocationManagerDelegate>)delegate {
    SDLocationManagerDelegateRegistration *existingRegistration = [[_delegateRegistrations objectsPassingTest:^BOOL(SDLocationManagerDelegateRegistration *obj, BOOL *stop) {
        return obj.delegate == delegate;
    }] anyObject];
    if (existingRegistration) {
        [_delegateRegistrations removeObject:existingRegistration];
    }
}



#pragma mark - Public Interface



- (BOOL)isLocationAllowed
{
    if (self.authorizationStatus == kCLAuthorizationStatusAuthorized || self.authorizationStatus == kCLAuthorizationStatusNotDetermined)
        return YES;
    return NO;
}

- (BOOL)startUpdatingLocationWithDelegate:(id<SDLocationManagerDelegate>)delegate desiredAccuracy:(CLLocationAccuracy)accuracy
{
    [self registerDelegate:delegate forDesiredAccuracy:accuracy];
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
    [self deregisterDelegate:delegate];
    if ([_delegateRegistrations count] == 0 && _isUpdatingLocation)
    {
        _isUpdatingLocation = NO;
        [self internalStop];
        [super stopUpdatingLocation];
    }
}

- (void)stopUpdatingLocationForAllDelegates
{
    NSArray *delegates = self.delegates;
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
        [self.delegates makeObjectsPerformSelector:@selector(locationManager:didUpdateToInaccurateLocation:fromLocation:) argumentAddresses:(void *)&self, &newLocation, &oldLocation];
		return; // this one is cached, lets wait for a good one.
	}
	
	// if the accuracy isn't within what we're looking for, OR.. we got the same accuracy multiple times.. continue on..
	if ((newLocation.horizontalAccuracy >= self.highestDesiredAccuracy) || (newLocation.horizontalAccuracy > oldLocation.horizontalAccuracy))
	{
		SDLog(@"SDLocationManager: this location didn't meet the accuracy requirements (%f).", newLocation.horizontalAccuracy);
		//return; // the accuracy isn't good enough, wait some more...
        [self.delegates makeObjectsPerformSelector:@selector(locationManager:didUpdateToInaccurateLocation:fromLocation:) argumentAddresses:(void *)&self, &newLocation, &oldLocation];
        return;
	}
	
	SDLog(@"SDLocationManager: location obtained.");
    [self.delegates makeObjectsPerformSelector:_cmd argumentAddresses:(void *)&self, &newLocation, &oldLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
	if ([newHeading.timestamp timeIntervalSinceDate:_timestamp] < 0)
		return; // this one is cached, lets wait for a good one.
	
    [self.delegates makeObjectsPerformSelector:_cmd argumentAddresses:(void *)&self, &newHeading];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	// we're masking out didFail unless they've said NO to the "allow" dialog.
	if ([error.domain isEqualToString:kCLErrorDomain] && error.code == kCLErrorDenied)
        [self.delegates makeObjectsPerformSelector:_cmd argumentAddresses:(void *)&self, &error];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self.delegates makeObjectsPerformSelector:_cmd argumentAddresses:(void *)&self, &region];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self.delegates makeObjectsPerformSelector:_cmd argumentAddresses:(void *)&self, &region];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    [self.delegates makeObjectsPerformSelector:_cmd argumentAddresses:(void *)&self, &region, &error];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    [self unsupported:_cmd];
    return FALSE;
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self.delegates makeObjectsPerformSelector:_cmd argumentAddresses:(void *)&self, &status];
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        [self stopUpdatingLocationForAllDelegates];
    }
}




#pragma mark - Unsupported CLLocationManager Methods


- (void)setDelegate:(id<CLLocationManagerDelegate>)delegate { [self unsupported:_cmd]; }
- (void)startUpdatingLocation { [self unsupported:_cmd]; }
- (void)stopUpdatingLocation { [self unsupported:_cmd]; }
- (void)startUpdatingHeading { [self unsupported:_cmd]; }
- (void)stopUpdatingHeading { [self unsupported:_cmd]; }
- (void)setDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy { [self unsupported:_cmd]; }


- (void)unsupported:(SEL)sel {
	NSLog(@"Deprecated method called on SDLocationManager instance (%@ - %@)",self,NSStringFromSelector(sel));
    //[[NSException exceptionWithName:@"Unsupported" reason:@"See SDLocationManager.h, as this is deprecated." userInfo:nil] raise];
}



@end
