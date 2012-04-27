//
//  NSURLCacheWalmartExtensions.m
//  walmart
//
//  Created by Steven Riggins on 4/27/12.
//  Copyright (c) 2012 Walmart. All rights reserved.
//

#import "SDURLCacheWalmartExtensions.h"

@implementation SDURLCache(SDURLCacheWalmartExtensions)

// YES if url is in the cache and valid (ie non-expired
- (BOOL)isCachedAndValid:(NSURLRequest*)request
{
	return NO;
}	

// Makes sure the response is not expired, otherwise nil
- (NSCachedURLResponse*)validCachedResponseForRequest:(NSURLRequest *)request
{
	return nil; // Valid cached response not found
}


@end
