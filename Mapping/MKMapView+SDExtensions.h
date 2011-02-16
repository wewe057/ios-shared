//
//  MKMapView+SDExtensions.h
//  walmart
//
//  Created by brandon on 2/16/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

typedef NSObject<MKAnnotation> SDAnnotation;

@interface MKMapView(SDExtensions)

- (SDAnnotation *) getClosestAnnotationToLocation:(CLLocation *)location andSelect:(BOOL)inSelect;
- (SDAnnotation *) getNextClosestAnnotation:(SDAnnotation *)referenceAnnotation andSelect:(BOOL)inSelect;
- (NSArray *) getAnnotationsByDistanceToLocation:(CLLocation *)location;

- (CLLocationCoordinate2D) centerCoordinateForAnnotations:(NSArray *)annotationArray;
- (void) recenterMapForAnnotations:(NSArray *)annotationArray withLocation:(CLLocation *)location;
- (void) recenterAroundLocation:(CLLocation *)location showAnnotations:(NSArray *)annotationArray;

- (NSSet *) visibleAnnotations;
- (NSArray *)userAnnotations;

@end
