//
//  SDURLConnection
//  ServiceTest
//
//  Created by Brandon Sneed on 11/3/11.
//  Copyright (c) 2011 SetDirection. All rights reserved.
//

#import "SDURLConnection.h"
#import "NSString+SDExtensions.h"
#import "SDURLCache.h"
#import <libkern/OSAtomic.h>

#define USE_THREADED_URLCONNECTION 1

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
		responseData = [[NSMutableData alloc] initWithCapacity:1024];
        self.isRunning = YES;
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
#if USE_THREADED_URLCONNECTION
    dispatch_async(dispatch_get_main_queue(), ^{
#endif
        responseHandler(connection, nil, responseData, error);
        responseHandler = nil;
        self.isRunning = NO;
#if USE_THREADED_URLCONNECTION
    });
#endif
}

- (void)connection:(SDURLConnection *)connection didReceiveData:(NSData *)data
{
	[responseData appendData:data];
}

- (void)connectionDidFinishLoading:(SDURLConnection *)connection
{
#if USE_THREADED_URLCONNECTION
    dispatch_async(dispatch_get_main_queue(), ^{
#endif
        responseHandler(connection, httpResponse, responseData, nil);
        responseHandler = nil;
        self.isRunning = NO;
#if USE_THREADED_URLCONNECTION
    });
#endif
}

- (NSCachedURLResponse *)connection:(SDURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return shouldCache ? cachedResponse : nil;
}

@end

#pragma mark -

@implementation SDURLConnection

@synthesize requestName;
@dynamic identifier;

+ (void)load
{
	@autoreleasepool 
	{
		NSString *cachePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"NSURLCache"];
		SDURLCache *urlCache = [[SDURLCache alloc] initWithMemoryCapacity:1024 * 1024 diskCapacity:1024 * 1024 * 300 diskPath:cachePath];
		[NSURLCache setSharedURLCache:urlCache];
	}

}

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
    if (!handler)
        @throw @"sendAsynchronousRequest must be given a handler!";
    
#if USE_THREADED_URLCONNECTION
    
    __block SDURLResponseCompletionDelegate *delegate = [[SDURLResponseCompletionDelegate alloc] initWithResponseHandler:[handler copy] shouldCache:cache];
    __block SDURLConnection *connection = [[SDURLConnection alloc] initWithRequest:request delegate:delegate startImmediately:NO];
    if (!connection)
        SDLog(@"Unable to create a connection!");
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{        
        
        [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [connection start];
        
        while (delegate.isRunning)
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        
        [connection unscheduleFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        if (delegate->responseHandler)
            SDLog(@"Response handler not called!");
    });
    
#else
    
    SDURLResponseCompletionDelegate *delegate = [[SDURLResponseCompletionDelegate alloc] initWithResponseHandler:[handler copy] shouldCache:cache];
    SDURLConnection *connection = [[SDURLConnection alloc] initWithRequest:request delegate:delegate startImmediately:NO];
    if (!connection)
        SDLog(@"Unable to create a connection!");
    [connection start];
    
#endif
    
    return connection;
}

@end