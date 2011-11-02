//
//  SDGeocoder.h
//
//  Created by brandon on 2/23/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
// this is coming from ASI-HTTP
#import "Reachability.h"

enum
{
    SDGeocoderErrorNoConnection = 0,
    SDGeocoderErrorBadData = 1,
};

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
	NSObject<SDGeocoderDelegate> *__unsafe_unretained delegate;
	MKPlacemark *placemark;
	NSHTTPURLResponse *response;
}

@property (nonatomic, readonly, getter = isQuerying) BOOL querying;
@property (nonatomic, readonly) MKPlacemark *placemark;
@property (nonatomic, unsafe_unretained) NSObject<SDGeocoderDelegate> *delegate;
@property (nonatomic, strong, readonly) NSString *query;

- (id)initWithQuery:(NSString *)queryString apiKey:(NSString *)apiKey;
- (void)start;
- (void)cancel;

@end
