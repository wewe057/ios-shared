//
//  SDGeocoder.h
//
//  Created by brandon on 2/23/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class SDGeocoder;

// delegate protocol

@protocol SDGeocoderDelegate

- (void)geocoder:(SDGeocoder *)geocoder didFailWithError:(NSError *)error;
- (void)geocoder:(SDGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark;

@end


// main interface


@interface SDGeocoder : NSObject
{
	NSURLConnection *connection;
	NSString *apiKeyString;
	NSString *query;
	NSMutableData *jsonData;
	NSObject<SDGeocoderDelegate> *delegate;
	MKPlacemark *placemark;
	NSHTTPURLResponse *response;
}

@property (nonatomic, readonly, getter = isQuerying) BOOL querying;
@property (nonatomic, readonly) MKPlacemark *placemark;
@property (nonatomic, assign) id<SDGeocoderDelegate> delegate;
@property (nonatomic, readonly) NSString *query;

- (id)initWithQuery:(NSString *)queryString apiKey:(NSString *)apiKey;
- (void)start;
- (void)cancel;

@end
