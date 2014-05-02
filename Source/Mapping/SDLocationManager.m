//
//  SDLocationManager.m
//
//  Created by brandon on 2/11/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

@import CoreLocation;

#import "SDLocationManager.h"
#import "NSArray+SDExtensions.h"

#import <objc/message.h>

#define kDebugSDLocationManager 0


NSString *kSDLocationManagerHasReceivedLocationUpdateDefaultsKey = @"SDLocationManagerHasReceivedLocationUpdate";


@interface SDLocationManagerDelegateRegistration : NSObject
@property (nonatomic, strong) id<SDLocationManagerDelegate> delegate;
@property (nonatomic) CLLocationAccuracy desiredAccuracy;
@property (nonatomic) CLLocationDistance distanceFilter;
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
- (NSString *) description {
    return [NSString stringWithFormat:@"%@ delegate = %@; desiredAccuracy = %@; distanceFilter = %@",[super description],self.delegate,@(self.desiredAccuracy),@(self.distanceFilter)];
}
@end


@interface SDLocationManager ()
@property (nonatomic, strong) NSMutableSet *delegateRegistrations;
@property (nonatomic, strong) dispatch_queue_t delegatesAccessQueue;
@property (nonatomic, readonly) NSArray *delegates;
@property (nonatomic, readonly) CLLocationAccuracy greatestDesiredAccuracy;
@property (nonatomic, readonly) CLLocationDistance finestDistanceFilter;
@property (nonatomic, readonly) CLAuthorizationStatus authorizationStatus;
@property (nonatomic, strong) CLLocation *previousLocation;
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


@dynamic isLocationAllowed;
- (BOOL)isLocationAllowed {
    if (self.authorizationStatus == kCLAuthorizationStatusAuthorized || self.authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        return YES;
    }
    return NO;
}

@synthesize timeout;

@dynamic hasReceivedLocationUpdate;
-(BOOL)hasReceivedLocationUpdate
{
	return [[NSUserDefaults standardUserDefaults] boolForKey: kSDLocationManagerHasReceivedLocationUpdateDefaultsKey];
}

@dynamic delegates;
- (NSArray *) delegates {
    __block NSSet *delegates = nil;
    dispatch_sync(_delegatesAccessQueue, ^{
        delegates = [_delegateRegistrations valueForKey:@"delegate"];
    });
    return [delegates allObjects];
}

@dynamic greatestDesiredAccuracy;
- (CLLocationAccuracy) greatestDesiredAccuracy {
    CLLocationAccuracy greatestDesiredAccuracy = kCLLocationAccuracyThreeKilometers;
    for (SDLocationManagerDelegateRegistration *registration in _delegateRegistrations) {
        if (registration.desiredAccuracy < greatestDesiredAccuracy) {
            greatestDesiredAccuracy = registration.desiredAccuracy;
            if (greatestDesiredAccuracy <= kCLLocationAccuracyBest) {
                break;
            }
        }
    }
    return greatestDesiredAccuracy;
}

@dynamic finestDistanceFilter;
- (CLLocationDistance) finestDistanceFilter {
    CLLocationDistance finestDistanceFilter = DBL_MAX;
    for (SDLocationManagerDelegateRegistration *registration in _delegateRegistrations) {
        if (registration.distanceFilter < finestDistanceFilter) {
            finestDistanceFilter = registration.distanceFilter;
            if (finestDistanceFilter == kCLDistanceFilterNone) {
                break;
            }
        }
    }
    return finestDistanceFilter;
}

@dynamic authorizationStatus;
- (CLAuthorizationStatus)authorizationStatus {
    return [CLLocationManager authorizationStatus];
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
    _delegatesAccessQueue = dispatch_queue_create("com.sd.SDLocationManager.delegatesAccessQueue", DISPATCH_QUEUE_CONCURRENT);

	return self;
}

- (void)dealloc
{
    
	[_timeoutTimer invalidate];
	_timeoutTimer = nil;
	
}



#pragma mark - Public Interface




- (BOOL)startUpdatingLocationWithDelegate:(id<SDLocationManagerDelegate>)delegate desiredAccuracy:(CLLocationAccuracy)accuracy {
    return [self startUpdatingLocationWithDelegate:delegate desiredAccuracy:accuracy distanceFilter:kCLDistanceFilterNone];
}

- (BOOL)startUpdatingLocationWithDelegate:(id<SDLocationManagerDelegate>)delegate desiredAccuracy:(CLLocationAccuracy)accuracy distanceFilter:(CLLocationDistance)distanceFilter {
    [self registerDelegate:delegate forDesiredAccuracy:accuracy distanceFilter:distanceFilter];
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

- (BOOL) startMonitoringForSignificantLocationChangesWithDelegate:(id<SDLocationManagerDelegate>)delegate {
	//TODO: implement this in such a way that if any delegate is interested in more active updates this stays off, but comes on when other delegates have resigned their interest
	[self unsupported:_cmd];
	return NO;
}

- (void) stopMonitoringSignificantLocationChangesWithDelegate:(id<SDLocationManagerDelegate>)delegate {
	//TODO: implement this so that it turns off location updates unless other delegates are also interested in this service
	[self unsupported:_cmd];
}

- (void) stopMonitoringSignificantLocationChangesForAllDelegates {
	//TODO: implement this so that any delegate that is soley interested in this service is removed, but those interested in active updates are left observing
	[self unsupported:_cmd];
}


#pragma mark - Internal




- (void)timeoutHandler
{
	_timeoutTimer = nil;

	// if we have a location, pass it along...
	if (self.location)
	{
        CLLocation *location = self.location;
        NSArray *locations = @[location];
        [self.delegates makeObjectsPerformSelector:@selector(locationManager:didUpdateLocations:) argumentAddresses:(void *)&self, &locations];
        //REMOVE: when all usages of the now deprecated locationManager:didUpdateToLocation:fromLocation: are cleared.
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

- (void) registerDelegate:(id<SDLocationManagerDelegate>)delegate forDesiredAccuracy:(CLLocationAccuracy)accuracy distanceFilter:(CLLocationDistance)distanceFilter {
    dispatch_barrier_async(_delegatesAccessQueue, ^{
        SDLocationManagerDelegateRegistration *delegateRegistration = [SDLocationManagerDelegateRegistration new];
        delegateRegistration.delegate = delegate;

        CLLocationAccuracy desiredAccuracy = accuracy;

        //???: This is a carry-over from past implmentations where there was only one accuracy setting, do we want to do this for every delegate? Seems weird to set accuracy so much lower than what was requested ..
        //    // actually set it somewhat below what we want.  this insures we get something under what we asked for.
        //    desiredAccuracy -= 600;
        //    if (desiredAccuracy < 10) {
        //        desiredAccuracy = kCLLocationAccuracyBest;
        //    }

        delegateRegistration.desiredAccuracy = desiredAccuracy;
        delegateRegistration.distanceFilter = distanceFilter;
        [_delegateRegistrations addObject:delegateRegistration];

        [super setDesiredAccuracy:self.greatestDesiredAccuracy];
        [super setDistanceFilter:self.finestDistanceFilter];
    });
}

- (void) deregisterDelegate:(id<SDLocationManagerDelegate>)delegate {
    dispatch_barrier_async(_delegatesAccessQueue, ^{
        SDLocationManagerDelegateRegistration *existingRegistration = [[_delegateRegistrations objectsPassingTest:^BOOL(SDLocationManagerDelegateRegistration *obj, BOOL *stop) {
            return obj.delegate == delegate;
        }] anyObject];
        if (existingRegistration) {
            [_delegateRegistrations removeObject:existingRegistration];
        }
        self.desiredAccuracy = self.greatestDesiredAccuracy;
        self.distanceFilter = self.finestDistanceFilter;
    });
}




#pragma mark CoreLocationManager delegates


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];
    CLLocation *oldLocation = nil;
    if ([locations count] > 1) {
        oldLocation = locations[[locations count]-2];
    }
    else {
        oldLocation = _previousLocation;
    }
    _previousLocation = newLocation;

    if ( ! _gotFirstLocationUpdate ) {
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
	if ([newLocation.timestamp timeIntervalSinceDate:_timestamp] < 0) {
		SDLog(@"SDLocationManager: this location was cached.");
        [self.delegates makeObjectsPerformSelector:@selector(locationManager:didUpdateToInaccurateLocation:fromLocation:) argumentAddresses:(void *)&self, &newLocation, &oldLocation];
		return; // this one is cached, lets wait for a good one.
	}
	
    // If the new location is less accurate than the previous one, continue ..

	if (newLocation.horizontalAccuracy > oldLocation.horizontalAccuracy) {
		SDLog(@"SDLocationManager: this location was less accurate than the previous location (%f).", newLocation.horizontalAccuracy);
		//return; // the accuracy isn't good enough, wait some more...
        [self.delegates makeObjectsPerformSelector:@selector(locationManager:didUpdateToInaccurateLocation:fromLocation:) argumentAddresses:(void *)&self, &newLocation, &oldLocation];
        return;
	}

    // Because each delegate now sets its own accuracy requirements we need to test each one against the new location's accuracy; some may be interested in less accurate updates.
    // Notice we aren't checking distanceFilter per delegate. This is because finer distance filters won't prevent delivery to a delegate (they will increase it).
    for (SDLocationManagerDelegateRegistration *registration in _delegateRegistrations) {
        CLLocationAccuracy desiredAccuracy = registration.desiredAccuracy;
        if (newLocation.horizontalAccuracy >= desiredAccuracy) {
            SDLog(@"SDLocationManager: this location didn't meet the accuracy requirements (%f) for delegate %@.", newLocation.horizontalAccuracy, registration.delegate);
            [registration.delegate locationManager:self didUpdateToInaccurateLocation:newLocation fromLocation:oldLocation];
        }
        else {
            SDLog(@"SDLocationManager: location obtained for delegate %@",registration.delegate);
            [registration.delegate locationManager:self didUpdateLocations:locations];
            //REMOVE: when all usages of the now deprecated locationManager:didUpdateToLocation:fromLocation: are cleared.
            if ([registration.delegate respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)]) {
                objc_msgSend/* avoid deprecation warnings */(registration.delegate,@selector(locationManager:didUpdateToLocation:fromLocation:),newLocation,oldLocation);
            }
        }
    }
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
- (void)setDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy { [self unsupported:_cmd]; }
- (void)setDistanceFilter:(CLLocationDistance)distanceFilter { [self unsupported:_cmd]; }


//!!!: No longer masking these because it turns out other CLLocationManager methods call these from their implementations. They are still marked deprecated as a way of dsicouraging people from calling them.
- (void)startUpdatingLocation { [super startUpdatingLocation];[self unsupported:_cmd]; }
- (void)stopUpdatingLocation { [super stopUpdatingLocation];[self unsupported:_cmd]; }
- (void)startUpdatingHeading { [super startUpdatingHeading];[self unsupported:_cmd]; }
- (void)stopUpdatingHeading { [super stopUpdatingHeading];[self unsupported:_cmd]; }
- (void)startMonitoringSignificantLocationChanges { [super startMonitoringSignificantLocationChanges];[self unsupported:_cmd]; }
- (void)stopMonitoringSignificantLocationChanges { [super stopMonitoringSignificantLocationChanges];[self unsupported:_cmd]; }

- (void)unsupported:(SEL)sel {
#if kDebugSDLocationManager
	NSLog(@"Deprecated method called on SDLocationManager instance (%@ - %@)",self,NSStringFromSelector(sel));
    NSLog(@"%@",[NSThread callStackSymbols]);
#endif
    //[[NSException exceptionWithName:@"Unsupported" reason:@"See SDLocationManager.h, as this is deprecated." userInfo:nil] raise];
}


@end
