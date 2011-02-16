//
//  MKMapView+SDExtensions.m
//  walmart
//
//  Created by brandon on 2/16/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import "MKMapView+SDExtensions.h"


@implementation MKMapView(SDExtensions)

- (SDAnnotation *) getClosestAnnotationToLocation:(CLLocation *)location andSelect:(BOOL)inSelect
{
	NSArray *annotations = self.annotations;
	if ([annotations count] < 1)
		return nil;
	
	SDAnnotation *result = nil;
	CLLocationDistance shortestDistance = INT_MAX;
	
	for (SDAnnotation* annotation in annotations)
	{
		CLLocation *endPoint = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
		CLLocationDistance thisDistance = [location distanceFromLocation:endPoint];
		if ((thisDistance < shortestDistance) &&
			(location.coordinate.latitude != annotation.coordinate.latitude) &&
			(location.coordinate.longitude != annotation.coordinate.longitude))
		{
			shortestDistance = thisDistance;
			result = annotation;
		}
		[endPoint release];
	}
	
	if (inSelect && result)
		self.selectedAnnotations = [NSArray arrayWithObject:result];	
	
	return result;
}

- (SDAnnotation *) getNextClosestAnnotation:(SDAnnotation *)referenceAnnotation andSelect:(BOOL)inSelect
{
	CLLocation *location = [[[CLLocation alloc] initWithLatitude:referenceAnnotation.coordinate.latitude longitude:referenceAnnotation.coordinate.longitude] autorelease];
	return [self getClosestAnnotationToLocation:location andSelect:inSelect];
}

- (NSArray *) getAnnotationsByDistanceToLocation:(CLLocation *)location
{
	NSMutableArray *result = [[NSMutableArray new] autorelease];
	SDAnnotation *annotation = [self getClosestAnnotationToLocation:location andSelect:NO];
	if (annotation)
		[result addObject:annotation];
	
	while (annotation)
	{
		annotation = [self getNextClosestAnnotation:annotation andSelect:NO];
		if (annotation)
			[result addObject:annotation];
	}
	
	return result;
}

#ifndef degreesToRadians
double degreesToRadians(double degrees)
{
	return (M_PI / 180) * degrees;
}

double radiansToDegrees(double radians)
{
	return (180 / M_PI) * radians;
}
#endif

- (CLLocationCoordinate2D) centerCoordinateForAnnotations:(NSArray *)annotationArray
{
	double totalD = 0;
	double x = 0, y = 0, z = 0;
	
	for (SDAnnotation *annotation in annotationArray)
	{
		if ([annotation isKindOfClass:[MKUserLocation class]])
			continue;
		
		CLLocationCoordinate2D coord = annotation.coordinate;
		double latitude = degreesToRadians(coord.latitude);
		double longitude = degreesToRadians(coord.longitude);
		
		double cx, cy, cz, cd;
		cx = cos(latitude) * cos(longitude);
		cy = cos(latitude) * sin(longitude);
		cz = sin(latitude);
		cd = 1.0; // days in a given location, unused.
		
		totalD += cd;
		
		x += (cx * cd);
		y += (cy * cd);
		z += (cz * cd);
	}
	
	x = x / totalD;
	y = y / totalD;
	z = z / totalD;
	
	CLLocationCoordinate2D newCenter = {0, 0};
	newCenter.longitude = radiansToDegrees(atan2(y, x));
	double hyp = sqrt(x * x + y * y);
	newCenter.latitude = radiansToDegrees(atan2(z, hyp));
	
	return newCenter;
}

- (void) recenterMapForAnnotations:(NSArray *)annotationArray withLocation:(CLLocation *)location
{
	CLLocationCoordinate2D maxCoord = {-90.0f, -180.0f};
	CLLocationCoordinate2D minCoord = {90.0f, 180.0f};
	
	// i wouldn't have to do this crap if MKAnnotation were an actual object type.
	CLLocationCoordinate2D coord = location.coordinate;
	
	if(coord.latitude > maxCoord.latitude)
		maxCoord.latitude = coord.latitude;
	if(coord.longitude > maxCoord.longitude)
		maxCoord.longitude = coord.longitude;
	
	if(coord.latitude < minCoord.latitude)
		minCoord.latitude = coord.latitude;
	if(coord.longitude < minCoord.longitude)
		minCoord.longitude = coord.longitude;
	
	for(SDAnnotation *annotation in annotationArray)
	{
		if ([annotation isKindOfClass:[MKUserLocation class]])
			continue;
		
		coord = annotation.coordinate;
		
		if(coord.latitude > maxCoord.latitude)
			maxCoord.latitude = coord.latitude;
		if(coord.longitude > maxCoord.longitude)
			maxCoord.longitude = coord.longitude;
		
		if(coord.latitude < minCoord.latitude)
			minCoord.latitude = coord.latitude;
		if(coord.longitude < minCoord.longitude)
			minCoord.longitude = coord.longitude;
	}
	MKCoordinateRegion region = {{0.0f, 0.0f}, {0.0f, 0.0f}};
	
	region.center.longitude = (minCoord.longitude + maxCoord.longitude) / 2.0;
	region.center.latitude = (minCoord.latitude + maxCoord.latitude) / 2.0;
	region.span.longitudeDelta = maxCoord.longitude - minCoord.longitude;
	region.span.latitudeDelta = maxCoord.latitude - minCoord.latitude;
	
	[self setRegion:region animated:YES];
}

- (void) recenterAroundLocation:(CLLocation *)location showAnnotations:(NSArray *)annotationArray
{
	CLLocationCoordinate2D maxCoord = {-90.0f, -180.0f};
	CLLocationCoordinate2D minCoord = {90.0f, 180.0f};
	
	// i wouldn't have to do this crap if MKAnnotation were an actual object type.
	CLLocationCoordinate2D coord = location.coordinate;
	
	if(coord.latitude > maxCoord.latitude)
		maxCoord.latitude = coord.latitude;
	if(coord.longitude > maxCoord.longitude)
		maxCoord.longitude = coord.longitude;
	
	if(coord.latitude < minCoord.latitude)
		minCoord.latitude = coord.latitude;
	if(coord.longitude < minCoord.longitude)
		minCoord.longitude = coord.longitude;
	
	for(SDAnnotation *annotation in annotationArray)
	{
		if ([annotation isKindOfClass:[MKUserLocation class]])
			continue;
		
		coord = annotation.coordinate;
		
		if(coord.latitude > maxCoord.latitude)
			maxCoord.latitude = coord.latitude;
		if(coord.longitude > maxCoord.longitude)
			maxCoord.longitude = coord.longitude;
		
		if(coord.latitude < minCoord.latitude)
			minCoord.latitude = coord.latitude;
		if(coord.longitude < minCoord.longitude)
			minCoord.longitude = coord.longitude;
	}
	MKCoordinateRegion region = {{0.0f, 0.0f}, {0.0f, 0.0f}};
	
	region.center.longitude = location.coordinate.longitude;//(minCoord.longitude + maxCoord.longitude) / 2.0;
	region.center.latitude = location.coordinate.latitude;//(minCoord.latitude + maxCoord.latitude) / 2.0;
	region.span.longitudeDelta = (maxCoord.longitude - minCoord.longitude) * 1.2;
	region.span.latitudeDelta = (maxCoord.latitude - minCoord.latitude) * 1.2;
	
	[self setRegion:region animated:YES];
}

- (NSSet *) visibleAnnotations;
{
	const MKCoordinateRegion theRegion = self.region;
	
	NSMutableSet *theVisibleAnnotations = [NSMutableSet set];
	
	for (id <MKAnnotation> theAnnotation in self.annotations)
	{
		CLLocationCoordinate2D theCoordinate = theAnnotation.coordinate;
		
		if (theCoordinate.latitude < theRegion.center.latitude - theRegion.span.latitudeDelta)
			continue;
		if (theCoordinate.latitude > theRegion.center.latitude + theRegion.span.latitudeDelta)
			continue;
		if (theCoordinate.longitude < theRegion.center.longitude - theRegion.span.longitudeDelta)
			continue;
		if (theCoordinate.longitude > theRegion.center.longitude + theRegion.span.longitudeDelta)
			continue;
		
		[theVisibleAnnotations addObject:theAnnotation];
	}
	
	return theVisibleAnnotations;
}

// returns a filtered version of self.annotations
- (NSArray *)userAnnotations
{
	NSArray *annotations = [self.annotations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class != %@", [MKUserLocation class]]];
	return annotations;
}

@end
