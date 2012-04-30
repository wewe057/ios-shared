//
//  SDURLConnection
//  ServiceTest
//
//  Created by Brandon Sneed on 11/3/11.
//  Copyright (c) 2011 SetDirection. All rights reserved.
//

#import "SDURLConnection.h"
#import "NSString+SDExtensions.h"
#import <libkern/OSAtomic.h>

@interface SDURLResponseCompletionDelegate : NSObject
{
@public
    SDURLConnectionResponseBlock responseHandler;
@private
	NSMutableData *responseData;
	NSHTTPURLResponse *httpResponse;
    BOOL shouldCache;
    BOOL isRunning;
}

@property (atomic, assign) BOOL isRunning;

- (id)initWithResponseHandler:(SDURLConnectionResponseBlock)newHandler
                  shouldCache:(BOOL)cache;

@end

@implementation SDURLResponseCompletionDelegate

@synthesize isRunning;

- (id)initWithResponseHandler:(SDURLConnectionResponseBlock)newHandler shouldCache:(BOOL)cache
{
    if (self = [super init])
	{
        responseHandler = [newHandler copy];
        shouldCache = cache;
		responseData = [NSMutableData dataWithCapacity:0];
        self.isRunning = YES;
    }
	
    return self;
}

- (void)dealloc
{
    responseHandler = nil;
    responseData = nil;
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
    self.isRunning = NO;
}

- (void)connection:(SDURLConnection *)connection didReceiveData:(NSData *)data
{
	[responseData appendData:data];
}

- (void)connectionDidFinishLoading:(SDURLConnection *)connection
{
    responseHandler(connection, httpResponse, responseData, nil);
    responseHandler = nil;
    self.isRunning = NO;
}

- (NSCachedURLResponse *)connection:(SDURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    NSCachedURLResponse *realCache = [[NSCachedURLResponse alloc] initWithResponse:cachedResponse.response data:responseData userInfo:nil storagePolicy:NSURLCacheStorageAllowed];
    return shouldCache ? realCache : nil;
}

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

- (void)cancel
{
    self->pseudoDelegate.isRunning = NO;
    [super cancel];
}

+ (SDURLConnection *)sendAsynchronousRequest:(NSURLRequest *)request shouldCache:(BOOL)cache withResponseHandler:(SDURLConnectionResponseBlock)handler
{
    if (!handler)
        @throw @"sendAsynchronousRequest must be given a handler!";
    
    SDURLResponseCompletionDelegate *delegate = [[SDURLResponseCompletionDelegate alloc] initWithResponseHandler:[handler copy] shouldCache:cache];
    SDURLConnection *connection = [[SDURLConnection alloc] initWithRequest:request delegate:delegate startImmediately:NO];
    if (!connection)
        SDLog(@"Unable to create a connection!");
    
	// To keep the smooth scrolling on the iPhone app Shelf w/o affecting iPad
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
        [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    [connection start];
    
    return connection;
}

@end