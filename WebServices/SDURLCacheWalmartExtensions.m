//
//  SDURLCacheWalmartExtensions.m
//  walmart
//
//  Created by Steven Riggins on 1/25/12.
//  Copyright (c) 2012 Walmart. All rights reserved.
//

#import "SDURLCacheWalmartExtensions.h"

@implementation SDURLCache(SDURLCacheWalmartExtensions)

// YES if url is in the cache and valid (ie non-expired
- (BOOL)isCachedAndValid:(NSURLRequest*)request
{
	if ([(SDURLCache *)[SDURLCache sharedURLCache] isCached:request.URL])
    {
        NSURLCache *urlCache = [NSURLCache sharedURLCache];
        NSCachedURLResponse *response = [urlCache cachedResponseForRequest:request];
        if (response && response.response && response.data)
        {
			NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)[response response];
			if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]])
			{
				NSDate *expirationDate = [SDURLCache expirationDateFromHeaders:[httpResponse allHeaderFields] withStatusCode:[httpResponse statusCode]];
				if ([expirationDate timeIntervalSinceNow] > 0)
				{
					return YES;
				}
			}
		}
	}
	return NO;
}	

// Makes sure the response is not expired, otherwise nil
- (NSCachedURLResponse*)validCachedResponseForRequest:(NSURLRequest *)request
{
	if ([(SDURLCache *)[SDURLCache sharedURLCache] isCached:request.URL])
    {
        NSURLCache *urlCache = [NSURLCache sharedURLCache];
        NSCachedURLResponse *response = [urlCache cachedResponseForRequest:request];
        if (response && response.response && response.data)
        {
			NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)[response response];
			if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]])
			{
				NSDate *expirationDate = [SDURLCache expirationDateFromHeaders:[httpResponse allHeaderFields] withStatusCode:[httpResponse statusCode]];
				if ([expirationDate timeIntervalSinceNow] > 0)
				{
					return response;
				}
			}
		}
    }
	return nil; // Valid cached response not found
}


@end
