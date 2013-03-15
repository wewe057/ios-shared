//
//  SDGeocoder.h
//
//  Created by brandon on 2/23/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Reachability.h"

enum
{
    SDGeocoderErrorNoConnection = 0,
    SDGeocoderErrorBadData = 1,
};

@class SDGeocoder;

// delegate protocol
__deprecated__("Use CLGeocoder instead.")
@protocol SDGeocoderDelegate

- (void)geocoder:(SDGeocoder *)geocoder didFailWithError:(NSError *)error;
- (void)geocoder:(SDGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark;

@end


// main interface

__deprecated__("Use CLGeocoder instead.")
@interface SDGeocoder : NSObject
{
	NSURLConnection *connection;
	NSString *apiKeyString;
	NSString *query;
	NSMutableData *jsonData;
	NSObject<SDGeocoderDelegate> *__weak delegate;
	MKPlacemark *placemark;
	NSHTTPURLResponse *response;
}

@property (nonatomic, readonly, getter = isQuerying) BOOL querying;
@property (nonatomic, readonly) MKPlacemark *placemark;
@property (nonatomic, weak) NSObject<SDGeocoderDelegate> *delegate;
@property (nonatomic, strong, readonly) NSString *query;

- (id)initWithQuery:(NSString *)queryString apiKey:(NSString *)apiKey;
- (void)start;
- (void)cancel;

@end
