//
//  SDWebService.m
//
//  Created by brandon on 2/14/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import "SDWebService.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "ASINetworkQueue.h"
#import "NSString+SDExtensions.h"
#import "ASIFormDataRequest.h"

@interface SDHTTPRequest : ASIHTTPRequest
{
    NSString *requestName;
}
@property (nonatomic, retain) NSString *requestName;
@end


@implementation SDHTTPRequest

@synthesize requestName;

- (void)dealloc
{
    [requestName release];
    [super dealloc];
}

@end

@interface SDFormDataRequest : ASIFormDataRequest
{
    NSString *requestName;
}
@property (nonatomic, retain) NSString *requestName;
@end


@implementation SDFormDataRequest

@synthesize requestName;

- (void)dealloc
{
    [requestName release];
    [super dealloc];
}

@end


@implementation SDWebService

@synthesize serviceCookies;

- (id)initWithSpecification:(NSString *)specificationName
{
	self = [super init];
	
    queues = [[NSMutableDictionary alloc] init];
	NSString *specFile = [[NSBundle mainBundle] pathForResource:specificationName ofType:@"plist"];
	serviceSpecification = [[NSDictionary dictionaryWithContentsOfFile:specFile] retain];
	if (!serviceSpecification)
		[NSException raise:@"SDException" format:@"Unable to load the specifications file %@.plist", specificationName];
	
	return self;
}

- (void)dealloc
{
	[serviceSpecification release];
    [queues release];
	[super dealloc];
}

- (void)setServiceCookies:(NSMutableArray *)cookies
{
    [serviceCookies release];
    serviceCookies = nil;
    if (cookies)
        serviceCookies = [cookies retain];
}

- (BOOL)responseIsValid:(NSString *)response forRequest:(NSString *)requestName
{
    return YES;
}

- (NSString *)baseURLInServiceSpecification
{
	NSString *baseURL = [serviceSpecification objectForKey:@"baseURL"];
	
    // this allows for having a settings bundle for one to specify an alternate server for debug/qa/etc.
    if ([baseURL rangeOfString:@"{"].location != NSNotFound)
    {
        NSString *prefKey = nil;
        int startPos = [baseURL rangeOfString:@"{"].location + 1;
        int endPos = [baseURL rangeOfString:@"}"].location;
        NSRange range = NSMakeRange(startPos, endPos - startPos);
        prefKey = [baseURL substringWithRange:range];
        NSString *server = [[NSUserDefaults standardUserDefaults] objectForKey:prefKey];
        baseURL = [baseURL stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}", prefKey] withString:server];
    }
    
	return baseURL;
}

- (BOOL)isReachableToHost:(NSString *)hostName
{
    return [[Reachability reachabilityWithHostName:hostName] isReachable];
}

- (BOOL)isReachable
{
    return [[Reachability reachabilityForInternetConnection] isReachable];
}

- (void)will302RedirectToUrl:(NSURL *)argUrl
{
	// Implement in service subclass for specific behavior
}

- (void)clearCache
{
	[[ASIDownloadCache sharedCache] clearCachedResponsesForStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
}

- (NSString *)performReplacements:(NSDictionary *)replacements andUserReplacements:(NSDictionary *)userReplacements withFormat:(NSString *)routeFormat
{
    // combine the contents of routeReplacements and the passed in replacements to form
	// a complete name and value list.
	NSArray *keyList = [userReplacements allKeys];
	NSMutableDictionary *actualReplacements = [replacements mutableCopy];
	for (NSString *key in keyList)
	{
		// this takes all the data provided in replacements and overwrites any default
		// values specified in the plist.
		NSObject *value = [userReplacements objectForKey:key];
		[actualReplacements setObject:value forKey:key];
	}
	
	// now lets take that final list and apply it to the route format.
	keyList = [actualReplacements allKeys];
	NSString *result = routeFormat;
	for (NSString *key in keyList)
	{
		id object = [actualReplacements objectForKey:key];
		NSString *value = nil;
		// if its a string, assign it.
		if ([object isKindOfClass:[NSString class]])
			value = object;
		else
		{
			// if its not, run some tests to see what we can do...
			if ([object isKindOfClass:[NSNumber class]])
				value = [object stringValue];
			else
                if ([object respondsToSelector:@selector(stringValue)])
                    value = [object stringValue];
		}
		if (value)
			result = [result stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}", key] withString:[value escapedString]];
	}
    
    [actualReplacements release];
    
    return result;
}

- (BOOL)performRequestWithMethod:(NSString *)requestName routeReplacements:(NSDictionary *)replacements completion:(SDWebServiceCompletionBlock)completionBlock shouldRetry:(BOOL)shouldRetry
{
	// construct the URL based on the specification.
	NSString *baseURL = [serviceSpecification objectForKey:@"baseURL"];
	NSDictionary *requestList = [serviceSpecification objectForKey:@"requests"];
	NSDictionary *requestDetails = [requestList objectForKey:requestName];
	NSString *routeFormat = [requestDetails objectForKey:@"routeFormat"];
	NSString *method = [requestDetails objectForKey:@"method"];
	BOOL postMethod = [[method uppercaseString] isEqualToString:@"POST"];
    
    // Allowing for the dynamic specification of baseURL at runtime
    // (initially to accomodate the suggestions search)
    NSString *altBaseURL = [replacements objectForKey:@"baseURL"];
    if (altBaseURL) {
        baseURL = altBaseURL;
    }
    else {
        // if this method has its own baseURL use it instead.
        altBaseURL = [requestDetails objectForKey:@"baseURL"];
        if (altBaseURL) {
            baseURL = altBaseURL;
        }
    }
    
    // this allows for having a settings bundle for one to specify an alternate server for debug/qa/etc.
    if ([baseURL rangeOfString:@"{"].location != NSNotFound)
    {
        NSString *prefKey = nil;
        int startPos = [baseURL rangeOfString:@"{"].location + 1;
        int endPos = [baseURL rangeOfString:@"}"].location;
        NSRange range = NSMakeRange(startPos, endPos - startPos);
        prefKey = [baseURL substringWithRange:range];
        NSString *server = [[NSUserDefaults standardUserDefaults] objectForKey:prefKey];
        baseURL = [baseURL stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}", prefKey] withString:server];
    }
    
	NSString *hostName = [[NSURL URLWithString:baseURL] host];
    if (![self isReachable] || ![self isReachableToHost:hostName])
    {
        // we ain't got no connection Lt. Dan
        NSError *error = [NSError errorWithDomain:@"SDWebServiceError" code:SDWebServiceErrorNoConnection userInfo:nil];
        completionBlock(0, nil, &error);
        return NO;
    }
    
    // get cache details
    NSNumber *cache = [requestDetails objectForKey:@"cache"];
    NSNumber *cacheTTL = [requestDetails objectForKey:@"cacheTTL"];
    
    // see if this is a singleton request.
    NSNumber *singleRequestNumber = [requestDetails objectForKey:@"singleRequest"];
    BOOL singleRequest = NO;
    ASINetworkQueue *namedQueue = [queues objectForKey:requestName];
    if (singleRequestNumber)
    {
        singleRequest = [singleRequestNumber boolValue];
        
        // if it is, lets cancel any with matching names. there may be multiple, however unlikely.
        if (singleRequest)
        {
            [namedQueue cancelAllOperations];
            namedQueue = [[[ASINetworkQueue alloc] init] autorelease];
            [queues setObject:namedQueue forKey:requestName];
        }
    }
    
    NSDictionary *routeReplacements = [requestDetails objectForKey:@"routeReplacement"];
    NSString *route = [self performReplacements:routeReplacements andUserReplacements:replacements withFormat:routeFormat];
	
	// there are some unparsed parameters which means either the plist is wrong, or the caller 
	// gave us a list of replacements that weren't sufficient to continue on.
	if ([route rangeOfString:@"{"].location != NSNotFound)
	{
		[NSException raise:@"SDException" format:@"Unable to create request.  The URL still contains replacement markers: %@", route];
	}
	
    // setup post data if we need to.
    NSString *postParams = nil;
    if (postMethod)
    {
        NSString *postFormat = [requestDetails objectForKey:@"postFormat"];
        if (postFormat)
        {
            postParams = [self performReplacements:routeReplacements andUserReplacements:replacements withFormat:postFormat];
			
			// there are some unparsed parameters which means either the plist is wrong, or the caller 
			// gave us a list of replacements that weren't sufficient to continue on.
			if ([postParams rangeOfString:@"{"].location != NSNotFound)
			{
				[NSException raise:@"SDException" format:@"Unable to create request.  The post params still contains replacement markers: %@", postParams];
			}
        }
    }
    
	// build the url and put it here...
    NSString* escapedUrlString = [NSString stringWithFormat:@"%@%@", baseURL, route];
	NSURL *url = [NSURL URLWithString:escapedUrlString];
	SDLog(@"outgoing request = %@", url);
	
	__block ASIHTTPRequest *request = nil;
    if ([[method uppercaseString] isEqualToString:@"POST"])
    {
		request = [SDFormDataRequest requestWithURL:url];
	} else {
		request = [SDHTTPRequest requestWithURL:url];
	}
	request.delegate = self;
	request.requestMethod = method;
    request.useCookiePersistence = YES;
    request.numberOfTimesToRetryOnTimeout = 3;
    [request setShouldContinueWhenAppEntersBackground:YES];
#ifdef DEBUG
#warning "Ignoring SSL certifications while in DEBUG mode"
    request.timeOutSeconds = 300;
    [request setValidatesSecureCertificate:NO];
#else
    request.timeOutSeconds = 30;
#endif
    
    
    if (postMethod && postParams)
    {
        SDLog(@"request post: %@", postParams);
		SDFormDataRequest *postRequest = (SDFormDataRequest *)request;
		NSArray *parameters = [postParams componentsSeparatedByString:@"&"];
		for (NSString *aParameter in parameters) {
			NSArray *keyVal = [aParameter componentsSeparatedByString:@"="];
			if ([keyVal count] == 2) {
                NSString *decodedKey = [[keyVal objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSString *decodedValue = [[keyVal objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				[postRequest setPostValue:decodedValue forKey:decodedKey];
			} else {
				[NSException raise:@"SDException" format:@"Unable to create request. Post param does not have proper key value pair: %@", keyVal];
			}
		}
    }
    
    if (singleRequest)
    {
        if (namedQueue)
            [namedQueue addOperation:request];
    }
    
    // setup caching
    if (cache && [cache boolValue])
    {
        [request setDownloadCache:[ASIDownloadCache sharedCache]];
        if (cacheTTL)
            [request setSecondsToCache:[cacheTTL unsignedIntValue]];
        [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    }
    
    if (serviceCookies)
    {
        request.useCookiePersistence = NO;
        [request setRequestCookies:serviceCookies];
    }
	
    // set ourselves up to retry
    NSDictionary *replacementsCopy = [[replacements copy] autorelease];
    SDWebServiceCompletionBlock completionBlockCopy = [[completionBlock copy] autorelease];
    NSString *requestNameCopy = [[requestName copy] autorelease];
    
	// setup the completion blocks.  we call the same block because failure means
	// different things with different APIs.  pass along the info we've gathered
	// to the handler, and let it decide.  if its an HTTP failure, that'll get
	// passed along as well.
    
    SDWebService *blockSelf = self;
    
#ifdef DEBUG
    NSDate *startDate = [NSDate date];
#endif
    
	[request setCompletionBlock:^{
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];        
        NSString *responseString = [request responseString];
        NSError *error = nil;
        
#ifdef DEBUG
        SDLog(@"Service call took %lf seconds.", [[NSDate date] timeIntervalSinceDate:startDate]);
#endif
        //SDLog(@"request-headers = %@", [request requestHeaders]);
        //SDLog(@"response-headers = %@", [request responseHeaders]);
        if ([request didUseCachedResponse])
            SDLog(@"**** USING CACHED RESPONSE ***");
        
        if (![blockSelf responseIsValid:responseString forRequest:requestName] && shouldRetry)
        {
            [[ASIDownloadCache sharedCache] clearCachedResponsesForStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
            [blockSelf performRequestWithMethod:requestNameCopy routeReplacements:replacementsCopy completion:completionBlockCopy shouldRetry:NO];
        }
        else
        {
            int code = [request responseStatusCode];
            completionBlock(code, responseString, &error);
        }
        [request setFailedBlock:nil];
        [request setRequestRedirectedBlock:nil];
        [request setCompletionBlock:nil];
        [pool drain];
	}];
    
	[request setFailedBlock:^{
		NSString *responseString = [request responseString];
		NSError *error = [request error];
		completionBlock([request responseStatusCode], responseString, &error);
        [request setCompletionBlock:nil];
        [request setRequestRedirectedBlock:nil];
        [request setFailedBlock:nil];
	}];
	
	[request setRequestRedirectedBlock:^{
		if (([request responseStatusCode] == 302)) {
			[blockSelf will302RedirectToUrl:[request url]];
		}
	}];
	
    if (!singleRequest)
    {
        //[request startAsynchronous];
        ASINetworkQueue *queue = [ASINetworkQueue queue];
        [queue addOperation:request];
        [queue go];
    }
    else
        [namedQueue go];
	return YES;
}

- (BOOL)performRequestWithMethod:(NSString *)requestName routeReplacements:(NSDictionary *)replacements completion:(SDWebServiceCompletionBlock)completionBlock
{
    return [self performRequestWithMethod:requestName routeReplacements:replacements completion:completionBlock shouldRetry:YES];
}

- (BOOL)performRequestWithMethods:(NSArray *)requestNamesArray routeReplacements:(NSArray *)replacementsArray completion:(SDWebServiceGroupCompletionBlock)argGroupCompletionBlock
{
    if (![[Reachability reachabilityForInternetConnection] isReachable])
    {
        // we ain't got no connection Lt. Dan
        NSError *error = [NSError errorWithDomain:@"SDWebServiceError" code:SDWebServiceErrorNoConnection userInfo:nil];
        argGroupCompletionBlock(nil, nil, &error);
        return NO;
    }
    
	NSUInteger numRequests = [requestNamesArray count];
	NSUInteger numReplacements = [replacementsArray count];
	if (numRequests == 0 || (numRequests != numReplacements)) {
        NSError *error = [NSError errorWithDomain:@"SDWebServiceError" code:SDWebServiceErrorBadParams userInfo:nil];
        argGroupCompletionBlock(nil, nil, &error);
		return NO;
	}
	
	__block NSUInteger requestCount = numRequests;
	
	NSUInteger theIndex = 0;
	for (theIndex = 0; theIndex < numRequests; theIndex++) {
		[self performRequestWithMethod:[requestNamesArray objectAtIndex:theIndex] routeReplacements:[replacementsArray objectAtIndex:theIndex] completion:^(int responseCode, NSString *response, NSError **error) {
			requestCount--;
			if (requestCount == 0) {
				// TODO: Pass the codes and responses back to the completion block.
				argGroupCompletionBlock(nil, nil, NULL);
			}
		}];
	}
	
	return YES;
}


@end
