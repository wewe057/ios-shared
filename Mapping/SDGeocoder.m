//
//  SDGeocoder.m
//
//  Created by brandon on 2/23/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import "SDGeocoder.h"

@interface SDGeocoder(private)
+ (NSDictionary *)addressBookDictionary:(NSDictionary *)placemarkDictionary coordinates:(CLLocationCoordinate2D *)coords;
- (void)closeConnection;
@end


@implementation SDGeocoder

@synthesize querying;
@synthesize placemark;
@synthesize delegate;
@synthesize query;

- (id)initWithQuery:(NSString *)queryString apiKey:(NSString *)apiKey
{
	self = [super init];
	
	query = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(nil, (__bridge CFStringRef)queryString, nil, (CFStringRef)@"/?+!", kCFStringEncodingUTF8);
	apiKeyString = apiKey;
	jsonData = [[NSMutableData alloc] init];
	
	return self;
}

- (void)dealloc
{
	[self closeConnection];
	
	
}

- (BOOL)isQuerying
{
	if (connection)
		return YES;
	return NO;
}

- (void)start
{
    if ([[SDReachability reachabilityForInternetConnection] isReachable])
    {
        NSString *requestString = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=json&oe=utf8&sensor=false&key=%@", query, apiKeyString];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestString] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
        connection = [NSURLConnection connectionWithRequest:request delegate:self];
    }
    else
    {
        // we ain't got no connection Lt. Dan.
        if (delegate && [delegate respondsToSelector:@selector(geocoder:didFailWithError:)])
            [delegate geocoder:self didFailWithError:[NSError errorWithDomain:@"SDGeocoderError" code:SDGeocoderErrorNoConnection userInfo:nil]];
    }
}

- (void)cancel
{
	[self closeConnection];
}

- (void)closeConnection
{
	if (connection)
	{
		[connection cancel];
		connection = nil;
		response = nil;
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (response)
	{
		if (response.statusCode != 200)
		{
			if (delegate && [delegate respondsToSelector:@selector(gecoder:didFailWithError:)])
				[delegate geocoder:self didFailWithError:[NSError errorWithDomain:@"SDGeocoderError" code:response.statusCode userInfo:nil]];
			return;
		}
		
		NSError *error = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
		if (error)
		{
			if (delegate && [delegate respondsToSelector:@selector(geocoder:didFailWithError:)])
				[delegate geocoder:self didFailWithError:error];
			return;
		}
		
		CLLocationCoordinate2D coords = {0, 0};
		NSDictionary *addressDict = [SDGeocoder addressBookDictionary:dictionary coordinates:&coords];
		if (!addressDict)
		{
			if (delegate && [delegate respondsToSelector:@selector(geocoder:didFailWithError:)])
				[delegate geocoder:self didFailWithError:[NSError errorWithDomain:@"SDGeocoderError" code:SDGeocoderErrorBadData userInfo:nil]];
			return;
		}
		
		placemark = [[MKPlacemark alloc] initWithCoordinate:coords addressDictionary:addressDict];
		if (!addressDict)
		{
			if (delegate && [delegate respondsToSelector:@selector(geocoder:didFailWithError:)])
				[delegate geocoder:self didFailWithError:[NSError errorWithDomain:@"SDGeocoderError" code:SDGeocoderErrorBadData userInfo:nil]];
			return;
		}
		
		if (delegate && [delegate respondsToSelector:@selector(geocoder:didFindPlacemark:)])
			[delegate geocoder:self didFindPlacemark:placemark];		
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[jsonData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)theResponse
{
	response = theResponse;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if (delegate && [delegate respondsToSelector:@selector(gecoder:didFailWithError:)])
		[delegate geocoder:self didFailWithError:error];
	[self closeConnection];
}

+ (NSDictionary *)addressBookDictionary:(NSDictionary *)placemarkDictionary coordinates:(CLLocationCoordinate2D *)coords
{
	// if you're dealing with an app meant to work outside the US, you might want to make sure
	// the result dictionary's format is correct.  it seems very US specific to me, and i can't find
	// any documentation on the format, so i reversed it from MKReverseGeocoder.
	
	NSMutableDictionary *result = [NSMutableDictionary new];
	
	NSArray *topLevel = [placemarkDictionary objectForKey:@"Placemark"];
	if (!topLevel)
		return nil;
	NSDictionary *first = [topLevel objectAtIndex:0];
	if (first)
		[result setObject:[NSArray arrayWithObject:[first objectForKey:@"address"]] forKey:@"FormattedAddressLines"];
	
	NSDictionary *point = [first objectForKey:@"Point"];
	NSArray *coordinates = [point objectForKey:@"coordinates"];
	if (coordinates && point)
	{
		coords->latitude = [[coordinates objectAtIndex:1] doubleValue];
		coords->longitude = [[coordinates objectAtIndex:0] doubleValue];
	}	
	
	NSDictionary *addressDetails = [first objectForKey:@"AddressDetails"];
	NSDictionary *country = [addressDetails objectForKey:@"Country"];
	if (country)
	{
        NSString *countryName = [country objectForKey:@"CountryName"];
		[result setObject:countryName ? countryName:@"" forKey:@"Country"];
		[result setObject:[country objectForKey:@"CountryNameCode"] forKey:@"CountryCode"];
	}
	
	NSDictionary *adminArea = [country objectForKey:@"AdministrativeArea"];
	if (adminArea)
		[result setObject:[adminArea objectForKey:@"AdministrativeAreaName"] forKey:@"State"];
	
	NSDictionary *locality = [adminArea objectForKey:@"Locality"];
	if (locality == nil)
		@try { locality = [adminArea valueForKeyPath:@"SubAdministrativeArea.Locality"]; } @catch (NSException * e) {}
	
	if (locality) 
		[result setObject:[locality objectForKey:@"LocalityName"] forKey:@"City"];
	
	NSDictionary *postalCode = [locality objectForKey:@"PostalCode"];
	if (postalCode)
		[result setObject:[postalCode objectForKey:@"PostalCodeNumber"] forKey:@"ZIP"];
	
	NSDictionary *thoroughFare = [locality objectForKey:@"Thoroughfare"];
	if (thoroughFare)
		[result setObject:[thoroughFare objectForKey:@"ThoroughfareName"] forKey:@"Street"];
	
	return result;
}

@end
