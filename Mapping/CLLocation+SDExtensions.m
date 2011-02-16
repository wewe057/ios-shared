//
//  CLLocation+SDExtensions.m
//  walmart
//
//  Created by brandon on 2/16/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import "CLLocation+SDExtensions.h"


@implementation CLLocation(SDExtensions)

+ (CLLocation *)locationWithCoordinates:(CLLocationCoordinate2D)coordinates
{
	CLLocation *location = [[[CLLocation alloc] initWithLatitude:coordinates.latitude longitude:coordinates.longitude] autorelease];
	return location;
}

@end
