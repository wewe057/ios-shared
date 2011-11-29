//
//  SDURLConnection
//  ServiceTest
//
//  Created by Brandon Sneed on 11/3/11.
//  Copyright (c) 2011 SetDirection. All rights reserved.
//

#import "SDURLConnection.h"
#import "NSString+SDExtensions.h"

@interface SDURLResponseCompletionDelegate : NSObject
{
    SDURLConnectionResponseBlock responseHandler;
	NSMutableData *responseData;
	NSHTTPURLResponse *httpResponse;
    BOOL shouldCache;
}

- (id)initWithResponseHandler:(SDURLConnectionResponseBlock)newHandler
                  shouldCache:(BOOL)cache;

@end

@implementation SDURLResponseCompletionDelegate

- (id)initWithResponseHandler:(SDURLConnectionResponseBlock)newHandler shouldCache:(BOOL)cache
{
    if (self = [super init])
	{
        responseHandler = [newHandler copy];
        shouldCache = NO;
		responseData = [[NSMutableData alloc] initWithCapacity:1024];
    }
	
    return self;
}

- (void)dealloc
{
    responseHandler = nil;
}

#pragma mark NSURLConnection delegate

- (void)connection:(SDURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	httpResponse = (NSHTTPURLResponse *)response;
	[responseData setLength:0];	
}

- (void)connection:(SDURLConnection *)connection didFailWithError:(NSError *)error
{
    responseHandler(connection, nil, responseData, error);
    responseHandler = nil;
}

- (void)connection:(SDURLConnection *)connection didReceiveData:(NSData *)data
{
	[responseData appendData:data];
}

- (void)connectionDidFinishLoading:(SDURLConnection *)connection
{
    responseHandler(connection, httpResponse, responseData, nil);
	responseHandler = nil;
	 
	[connection cancel];	
}

/*- (NSCachedURLResponse *)connection:(SDURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return shouldCache ? cachedResponse : nil;
}*/

@end

#pragma mark -

@implementation SDURLConnection

@synthesize requestName;
@dynamic identifier;

- (void)dealloc
{
    requestName = nil;
	idendifier = nil;
}

- (NSString *)getIdentifier
{
	if (idendifier)
		return idendifier;
	
	idendifier = [NSString stringWithNewUUID];
	return idendifier;
}

+ (SDURLConnection *)sendAsynchronousRequest:(NSURLRequest *)request shouldCache:(BOOL)cache withResponseHandler:(SDURLConnectionResponseBlock)handler
{
    SDURLResponseCompletionDelegate *delegate = [[SDURLResponseCompletionDelegate alloc] initWithResponseHandler:handler shouldCache:cache];
    SDURLConnection *connection = [[SDURLConnection alloc] initWithRequest:request delegate:delegate startImmediately:YES];
	
    delegate = nil;
	
    return connection;
}

@end