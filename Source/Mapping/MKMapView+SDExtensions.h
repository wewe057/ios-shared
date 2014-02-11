//
//  MKMapView+SDExtensions.h
//  SetDirection
//
//  Created by brandon on 2/16/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

@import CoreLocation;
@import MapKit;

typedef NSObject<MKAnnotation> SDAnnotation;

@interface MKMapView(SDExtensions)

- (void)setRegionThatFits:(MKCoordinateRegion)region animated:(BOOL)animated;

- (SDAnnotation *)getClosestAnnotationToLocation:(CLLocation *)location andSelect:(BOOL)inSelect;
- (SDAnnotation *)getNextClosestAnnotation:(SDAnnotation *)referenceAnnotation andSelect:(BOOL)inSelect;

- (NSArray *) annotationsByDistanceToLocation:(CLLocation *)location;

- (CLLocationCoordinate2D)centerCoordinateForAnnotations:(NSArray *)annotationArray;
- (void) recenterMapForAnnotations:(NSArray *)annotationArray withLocation:(CLLocation *)location;
- (void) recenterAroundLocation:(CLLocation *)location showAnnotations:(NSArray *)annotationArray;

- (NSSet *)visibleAnnotations;
- (NSArray *)userAnnotations;

@end

// helper functions
double radiusToMeters(double radius);
double degreesToRadians(double degrees);
double radiansToDegrees(double radians);

