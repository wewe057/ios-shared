//
//  SDMockService.m
//
//  
//
//  Created by Steven Woolgar on 06/27/2013.
//  Copyright 2011-2013 SetDirection. All rights reserved.
//

#import "SDMockService.h"

#ifdef DEBUG

#import "SDWebService.h"

@implementation SDMockRequestResult

+ (SDMockRequestResult *)objectForResult:(SDWebServiceResult)result
                              identifier:(NSString *)identifier
                                 request:(NSURLRequest *)request
{
    SDMockRequestResult *object = [[SDMockRequestResult alloc] init];
    object.result = result;
    object.identifier = identifier;
    object.request = request;
    return object;
}

@end

@interface SDMockService()

@property (nonatomic, strong) NSMutableDictionary *normalRequests;
@property (nonatomic, assign) NSUInteger requestCount;
@property (nonatomic, strong) NSDictionary *serviceSpecification;
@property (nonatomic, strong) NSHTTPCookieStorage *cookieStorage;

@end

@implementation SDMockService

#pragma mark - Singleton bits

+ (instancetype)sharedInstance
{
	static dispatch_once_t oncePred;
	static id sSharedInstance = nil;
	dispatch_once( &oncePred, ^
    {
        sSharedInstance = [[[self class] alloc] init];
    } );
	return sSharedInstance;
}

- (instancetype)initWithSpecification:(NSString *)specificationName
{
	self = [super init];

    if (self != nil)
    {
        NSString *specFile = [[NSBundle bundleForClass:[self class]] pathForResource:specificationName ofType:@"plist"];
        _serviceSpecification = [NSDictionary dictionaryWithContentsOfFile:specFile];
        if (!_serviceSpecification)
        {
            [NSException raise:@"SDException" format:@"Unable to load the specifications file %@.plist", specificationName];
        }
    }

	return self;
}

- (instancetype)initWithSpecification:(NSString *)specificationName host:(NSString *)defaultHost path:(NSString *)defaultPath
{
	self = [self initWithSpecification:specificationName];

    if (self != nil)
    {
    }

	return self;
}

- (instancetype)copy
{
    [[NSException exceptionWithName:@"SDException" reason:@"Do NOT copy the web service singleton" userInfo:nil] raise];
    return nil;
}

+ (instancetype)copyWithZone:(NSZone *)zone
{
    [[NSException exceptionWithName:@"SDException" reason:@"Do NOT copy the web service singleton" userInfo:nil] raise];
    return nil;
}

#pragma mark - Reachability

- (BOOL)isReachableToHost:(NSString *)hostName showError:(BOOL)showError
{
//    return [[SDReachability reachabilityWithHostname:hostName] isReachable];
    return YES;
}

- (BOOL)isReachable:(BOOL)showError
{
//    return [[SDReachability reachabilityForInternetConnection] isReachable];
    return YES;
}

#pragma mark - Cache

- (void)clearCache
{
//    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

#pragma mark - Default processing blocks

+ (SDWebServiceDataCompletionBlock)defaultJSONProcessingBlock
{
    // refactor SDMockService so error's are passed around properly. -- BKS

    SDWebServiceDataCompletionBlock result = ^(NSURLResponse *response, NSInteger responseCode, NSData *responseData, NSError *error)
    {
        id dataObject = nil;
        if (responseData && responseData.length > 0)
            dataObject = [responseData JSONObject];
        return dataObject;
    };
    return result;
}

+ (SDWebServiceDataCompletionBlock)defaultMutableJSONProcessingBlock
{
    // Refactor SDMockService so error's are passed around properly. -- BKS

    SDWebServiceDataCompletionBlock result = ^(NSURLResponse *response, NSInteger responseCode, NSData *responseData, NSError *error)
    {
        id dataObject = nil;
        if (responseData && responseData.length > 0)
            dataObject = [responseData JSONObjectMutable:YES error:nil];
        return dataObject;
    };
    return result;
}

+ (SDWebServiceDataCompletionBlock)defaultArrayJSONProcessingBlock
{
    // refactor SDMockService so error's are passed around properly. -- BKS

    SDWebServiceDataCompletionBlock result = ^(NSURLResponse *response, NSInteger responseCode, NSData *responseData, NSError *error)
    {
        id dataObject = nil;
        if (responseData && responseData.length > 0)
            dataObject = [responseData JSONArray];
        return dataObject;
    };
    return result;
}

+ (SDWebServiceDataCompletionBlock)defaultMutableArrayJSONProcessingBlock
{
    // refactor SDWebService so error's are passed around properly. -- BKS

    SDWebServiceDataCompletionBlock result = ^(NSURLResponse *response, NSInteger responseCode, NSData *responseData, NSError *error)
    {
        id dataObject = nil;
        if (responseData && responseData.length > 0)
            dataObject = [responseData JSONMutableArray];
        return dataObject;
    };
    return result;

}

+ (SDWebServiceDataCompletionBlock)defaultDictionaryJSONProcessingBlock
{
    // refactor SDWebService so error's are passed around properly. -- BKS

    SDWebServiceDataCompletionBlock result = ^(NSURLResponse *response, NSInteger responseCode, NSData *responseData, NSError *error)
    {
        id dataObject = nil;
        if (responseData && responseData.length > 0)
            dataObject = [responseData JSONDictionary];
        return dataObject;
    };
    return result;
}

+ (SDWebServiceDataCompletionBlock)defaultMutableDictionaryJSONProcessingBlock
{
    // refactor SDWebService so error's are passed around properly. -- BKS

    SDWebServiceDataCompletionBlock result = ^(NSURLResponse *response, NSInteger responseCode, NSData *responseData, NSError *error)
    {
        id dataObject = nil;
        if (responseData && responseData.length > 0)
            dataObject = [responseData JSONMutableDictionary];
        return dataObject;
    };
    return result;

}

#pragma mark - Network activity

- (void)showNetworkActivityIfNeeded
{
    if (_requestCount > 0)
        [self showNetworkActivity];
}

- (void)hideNetworkActivityIfNeeded
{
    if (_requestCount <= 0)
    {
        _requestCount = 0;
        [self performSelector:@selector(hideNetworkActivity) withObject:nil afterDelay:0.5];
    }
}

- (void)incrementRequests
{
    _requestCount++;
    [self showNetworkActivityIfNeeded];
}

- (void)decrementRequests
{
	_requestCount--;
	[self hideNetworkActivityIfNeeded];
}

#pragma mark - URL building utilities

// Iterate through the string and look for {KEY}, replacing with the string value of that key from NSUserDefaults
- (NSString *)stringByReplacingPrefKeys:(NSString *)string
{
	// this allows for having a settings bundle for one to specify an alternate server for debug/qa/etc.
	BOOL doneReplacing = NO;

	while (!doneReplacing)
	{
		if ([string rangeOfString:@"{"].location != NSNotFound)
		{
			NSString *prefKey = nil;
			NSUInteger startPos = [string rangeOfString:@"{"].location + 1;
			NSUInteger endPos = [string rangeOfString:@"}"].location;
			NSRange range = NSMakeRange(startPos, endPos - startPos);
			prefKey = [string substringWithRange:range];
			NSString *prefValue = [[NSUserDefaults standardUserDefaults] objectForKey:prefKey];
			string = [string stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}", prefKey] withString:prefValue];
		}
        else
        {
			doneReplacing = YES;
        }
	}
	return string;
}

- (NSString *)baseSchemeInServiceSpecification
{
	NSString *baseScheme = self.serviceSpecification[@"baseScheme"];
	return baseScheme;
}

- (NSString *)baseHostInServiceSpecification
{
	NSString *baseHost = self.serviceSpecification[@"baseHost"];
	return baseHost;
}

- (NSString *)basePathInServiceSpecification
{
	NSString *basePath = self.serviceSpecification[@"basePath"];

	if (!basePath)
		basePath = @"/";

	return basePath;
}

- (NSString *)performReplacements:(NSDictionary *)replacements andUserReplacements:(NSDictionary *)userReplacements withFormat:(NSString *)routeFormat
{
    // combine the contents of routeReplacements and the passed in replacements to form
	// a complete name and value list.

	NSArray *keyList = [userReplacements allKeys];
	NSMutableDictionary *actualReplacements = [replacements mutableCopy];
    if (!actualReplacements)
        actualReplacements = [NSMutableDictionary dictionary];
	for (NSString *key in keyList)
	{
		// this takes all the data provided in replacements and overwrites any default
		// values specified in the plist.

		NSObject *value = userReplacements[key];
		actualReplacements[key] = value;
	}

	// now lets take that final list and apply it to the route format.

	keyList = [actualReplacements allKeys];
	NSString *result = routeFormat;
	for (NSString *key in keyList)
	{
		id object = actualReplacements[key];
		NSString *value = nil;

		// if its a string, assign it.

		if ([object isKindOfClass:[NSString class]])
        {
            value = object;
        }
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

    actualReplacements = nil;

    return result;
}

- (NSString *)responseFromData:(NSData *)data
{
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!responseString)
        responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    return responseString;
}

- (NSString *)buildBaseURLForScheme:(NSString *)baseScheme host:(NSString *)baseHost path:(NSString *)basePath details:(NSDictionary *)requestDetails replacements:(NSDictionary *)replacements
{
	NSString *baseURL;

	// **************************************************************
	// Scheme
    NSString *altBaseScheme = replacements[@"baseScheme"];
    if (altBaseScheme)
    {
        baseScheme = altBaseScheme;
    }
    else
    {
        // if this method has its own baseScheme use it instead.
        altBaseScheme = requestDetails[@"baseScheme"];
        if (altBaseScheme)
        {
            baseScheme = altBaseScheme;
        }
    }

	if (baseScheme && ([baseScheme rangeOfString:@"://"].location == NSNotFound))
	{
		baseScheme = [baseScheme stringByAppendingString:@"://"];
	}

	// **************************************************************
	// Host
	NSString *altBaseHost = replacements[@"baseHost"];
    if (altBaseHost)
    {
        baseHost = altBaseHost;
    }
    else
    {
        // if this method has its own baseHost use it instead.
        altBaseHost = requestDetails[@"baseHost"];
        if (altBaseHost)
        {
            baseHost = altBaseHost;
        }
    }

	// **************************************************************
	// Path
	NSString *altBasePath = replacements[@"basePath"];
    if (altBasePath)
    {
        basePath = altBasePath;
    }
    else
    {
        // if this method has its own basePath use it instead.
        altBasePath = requestDetails[@"basePath"];
        if (altBasePath)
        {
            basePath = altBasePath;
        }
    }

	if (!baseScheme)
		[NSException raise:@"SDException" format:@"Unable to create request.  Missing scheme."];

	if (!baseHost)
		[NSException raise:@"SDException" format:@"Unable to create request.  Missing host."];

	baseURL = [NSString stringWithFormat:@"%@%@%@",baseScheme,baseHost,basePath];

	return baseURL;
}

- (NSMutableURLRequest *)buildRequestForScheme:(NSString *)baseScheme
                                       headers:(NSDictionary *)headers
                                          host:(NSString *)baseHost
                                          path:(NSString *)basePath
                                       details:(NSDictionary *)requestDetails
                                  replacements:(NSDictionary *)replacements
{
    NSMutableURLRequest *request = nil;
	NSString *baseURL = nil;

    NSString *routeFormat = requestDetails[@"routeFormat"];
	NSString *method = requestDetails[@"method"];
	BOOL postMethod = [[method uppercaseString] isEqualToString:@"POST"];

    // Allowing for the dynamic specification of baseURL at runtime
    // (initially to accomodate the suggestions search)
    NSString *altBaseURL = replacements[@"baseURL"];
    if (altBaseURL) {
        baseURL = altBaseURL;
    }
    else {
        // if this method has its own baseURL use it instead.
        altBaseURL = requestDetails[@"baseURL"];
        if (altBaseURL) {
            baseURL = altBaseURL;
        }
    }

	// If there was no altBaseURL, then we need to build the baseURL
	if (!altBaseURL)
	{
		baseURL = [self buildBaseURLForScheme:baseScheme host:baseHost path:basePath details:requestDetails replacements:replacements];
	}

	// Look for {KEY} key ands replace them
	baseURL = [self stringByReplacingPrefKeys:baseURL];

    NSDictionary *routeReplacements = requestDetails[@"routeReplacement"];
    if (!routeReplacements)
        routeReplacements = [NSDictionary dictionary];
    NSString *route = [self performReplacements:routeReplacements andUserReplacements:replacements withFormat:routeFormat];

	// there are some unparsed parameters which means either the plist is wrong, or the caller
	// gave us a list of replacements that weren't sufficient to continue on.
	if ([route rangeOfString:@"{"].location != NSNotFound)
	{
		[NSException raise:@"SDException" format:@"Unable to create request.  The URL still contains replacement markers: %@", route];
	}

    // setup post data if we need to.
    NSString *postFormat = [requestDetails stringForKey:@"postFormat"];
    NSString *postParams = nil;
	id postObject = nil;
    if (postMethod)
    {
        if (postFormat)
        {
			if ([postFormat isEqualToString:@"JSON"])
			{
				// post data is raw JSON but can be NSString or NSData depending on implementation of calling method
				postObject = replacements[@"JSON"];
			}
            else
            if ([postFormat isEqualToString:@"SOAP"])
            {
                postObject = replacements[@"SOAP"];
            }
			else
			{
				// post data is in 'foo1={bar1}&foo2={bar2}...' form
				postParams = [self performReplacements:routeReplacements andUserReplacements:replacements withFormat:postFormat];
				// there are some unparsed parameters which means either the plist is wrong, or the caller
				// gave us a list of replacements that weren't sufficient to continue on.
				if ([postParams rangeOfString:@"{"].location != NSNotFound)
				{
					[NSException raise:@"SDException" format:@"Unable to create request.  The post params still contains replacement markers: %@", postParams];
				}
			}
        }
    }

	// build the url and put it here...
    NSString* escapedUrlString = [NSString stringWithFormat:@"%@%@", baseURL, route];
	NSURL *url = [NSURL URLWithString:escapedUrlString];

	SDLog(@"outgoing request = %@", url);

	request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:method];
	[request setHTTPShouldHandleCookies:YES];
	[request setHTTPShouldUsePipelining:NO];	// THIS WILL FUCK YOUR SHIT UP BRAH! 7 WAYS FROM SUNDAY!  In other words, this cannot be YES or our servers will return incorrect data
    // Service A's data will be returned for Service B, and vice-versa
#ifdef HUGE_SERVICES_TIMEOUT
	[request setTimeoutInterval:120];
#else
	[request setTimeoutInterval:_timeout];
#endif

    // find any applicable cookies and queue them up.
    NSArray *cookieNames = [requestDetails arrayForKey:@"cookieNames"];
    NSMutableArray *cookieArray = [[NSMutableArray alloc] initWithCapacity:cookieNames.count];
    for (NSString *cookieName in cookieNames)
    {
        NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"name == %@ && domain == %@", cookieName, url.host];
        NSArray *foundCookies = [[_cookieStorage cookies] filteredArrayUsingPredicate:namePredicate];

        if (foundCookies && foundCookies.count > 0)
            [cookieArray addObjectsFromArray:foundCookies];
    }

    // add those cookies to the request headers.
    if (cookieArray.count > 0)
    {
        NSDictionary *cookieHeaders = [NSHTTPCookie requestHeaderFieldsWithCookies:cookieArray];
        [request setAllHTTPHeaderFields:cookieHeaders];
    }

    // setup post method information.
    //
    if (postMethod)
    {
		id post = nil;
		if (postParams)
		{
			NSMutableString *mutablePost = [[NSMutableString alloc] init];
			//SDLog(@"request post: %@", postParams);
			NSArray *parameters = [postParams componentsSeparatedByString:@"&"];
			for (NSString *aParameter in parameters) {
				NSArray *keyVal = [aParameter componentsSeparatedByString:@"="];
				if ([keyVal count] == 2) {
					NSString *decodedKey = [keyVal objectAtIndex:0];			// Pass encoded values to NSURLConnection
					NSString *decodedValue = [keyVal objectAtIndex:1];
					[mutablePost appendFormat:@"%@=%@&", decodedKey, decodedValue];
				} else {
					[NSException raise:@"SDException" format:@"Unable to create request. Post param does not have proper key value pair: %@", keyVal];
				}
			}
			// Remove dangling '&' after simple sanity check
			if ([mutablePost length]) {
				mutablePost = [NSMutableString stringWithString:[mutablePost substringToIndex:[mutablePost length] - 1]];
			}
			post = mutablePost;
			[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		}
		else
        if ([postFormat isEqualToString:@"JSON"])
		{
			post = postObject;
			[request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
			[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
		}
        else
        if ([postFormat isEqualToString:@"SOAP"])
        {
            post = postObject;
            [request setValue:@"application/soap+xml" forHTTPHeaderField:@"Content-Type"];
        }
		if (post)
		{
            NSData *postData = nil;
            if ([post isKindOfClass:[NSData class]])
                // It's a kind of NSData
                postData = post;
            else
                // It's a kind of NSString
                postData = [post dataUsingEncoding:NSUTF8StringEncoding];

			[request setValue:[NSString stringWithFormat:@"%zd", [postData length]] forHTTPHeaderField:@"Content-Length"];
			[request setHTTPBody:postData];
		}
    }

    if (headers)
        [request setAllHTTPHeaderFields:headers];

    return request;
}

#pragma mark - Service execution

- (SDMockRequestResult *)performRequestWithMethod:(NSString *)requestName routeReplacements:(NSDictionary *)replacements dataProcessingBlock:(SDWebServiceDataCompletionBlock)dataProcessingBlock uiUpdateBlock:(SDWebServiceUICompletionBlock)uiUpdateBlock
{
    return [self performRequestWithMethod:requestName headers:nil routeReplacements:replacements dataProcessingBlock:dataProcessingBlock uiUpdateBlock:uiUpdateBlock shouldRetry:YES];
}

- (SDMockRequestResult *)performRequestWithMethod:(NSString *)requestName headers:(NSDictionary *)headers routeReplacements:(NSDictionary *)replacements dataProcessingBlock:(SDWebServiceDataCompletionBlock)dataProcessingBlock uiUpdateBlock:(SDWebServiceUICompletionBlock)uiUpdateBlock
{
    return [self performRequestWithMethod:requestName headers:headers routeReplacements:replacements dataProcessingBlock:dataProcessingBlock uiUpdateBlock:uiUpdateBlock shouldRetry:YES];
}

- (SDMockRequestResult *)performRequestWithMethod:(NSString *)requestName routeReplacements:(NSDictionary *)replacements dataProcessingBlock:(SDWebServiceDataCompletionBlock)dataProcessingBlock uiUpdateBlock:(SDWebServiceUICompletionBlock)uiUpdateBlock shouldRetry:(BOOL)shouldRetry;
{
    return [self performRequestWithMethod:requestName headers:nil routeReplacements:replacements dataProcessingBlock:dataProcessingBlock uiUpdateBlock:uiUpdateBlock shouldRetry:shouldRetry];
}

- (SDMockRequestResult *)performRequestWithMethod:(NSString *)requestName headers:(NSDictionary *)headers routeReplacements:(NSDictionary *)replacements dataProcessingBlock:(SDWebServiceDataCompletionBlock)dataProcessingBlock uiUpdateBlock:(SDWebServiceUICompletionBlock)uiUpdateBlock shouldRetry:(BOOL)shouldRetry;
{
    NSString *identifier = [NSString stringWithNewUUID];

	// construct the URL based on the specification.
	NSString *baseScheme = [self baseSchemeInServiceSpecification];
	NSString *baseHost = [self baseHostInServiceSpecification];
	NSString *basePath = [self basePathInServiceSpecification];
	NSDictionary *requestList = self.serviceSpecification[@"requests"];
	NSDictionary *requestDetails = requestList[requestName];

    NSMutableURLRequest *request = [self buildRequestForScheme:baseScheme headers:headers host:baseHost path:basePath details:requestDetails replacements:replacements];

    // get cache details
    NSNumber *cache = requestDetails[@"cache"];
//    NSNumber *cacheTTL = requestDetails[@"cacheTTL"];

    NSNumber *showNoConnectionAlertObj = requestDetails[@"showNoConnectionAlert"];
    BOOL showNoConnectionAlert = showNoConnectionAlertObj != nil ? [showNoConnectionAlertObj boolValue] : YES;
    if (![self isReachable:showNoConnectionAlert])
    {
        // we ain't got no connection Lt. Dan
        NSError *error = [NSError errorWithDomain:SDWebServiceError code:SDWebServiceErrorNoConnection userInfo:nil];
		if (uiUpdateBlock == nil)
			dataProcessingBlock(nil, 0, nil, error); // This mimicks SDWebService 1.0
        else
			uiUpdateBlock(nil, error);

        return [SDMockRequestResult objectForResult:SDWebServiceResultFailed identifier:nil request:request];
    }

    // setup caching
    if (cache && [cache boolValue])
        [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
	else
		[request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];

	// setup the completion blocks.  we call the same block because failure means
	// different things with different APIs.  pass along the info we've gathered
	// to the handler, and let it decide.  if its an HTTP failure, that'll get
	// passed along as well.

#if 0
	SDURLConnectionResponseBlock urlCompletionBlock = ^(SDURLConnection *connection, NSURLResponse *response, NSData *responseData, NSError *error)
    {
        // if the connection was cancelled, skip the retry bit.  this lets your block get called with nil data, etc.

        if ([error code] != NSURLErrorCancelled)
        {
            if ([error code] == NSURLErrorTimedOut)
            {
                [self serviceCallDidTimeoutForUrl:response.URL];

                if (shouldRetry)
                {
                    // remove it from the cache if its there.
                    NSURLCache *urlCache = [NSURLCache sharedURLCache];
                    if ([request isValid])
                        [urlCache removeCachedResponseForRequest:request];

                    SDMockRequestResult *newObject = [self performRequestWithMethod:requestName headers:headers routeReplacements:replacements dataProcessingBlock:dataProcessingBlock uiUpdateBlock:uiUpdateBlock shouldRetry:NO];

                    // do some sync/cleanup stuff here.
                    SDURLConnection *newConnection = normalRequests[newObject.identifier];

                    // If for some unknown reason the second performRequestWithMethod hits the cache, then we'll get a nil identifier, which means a nil newConnection
                    [dictionaryLock lock]; // NSMutableDictionary isn't thread-safe for writing.
                    if (newConnection)
                    {
                        [normalRequests setObject:newConnection forKey:identifier];
                        [normalRequests removeObjectForKey:newObject.identifier];
                    }
                    else
                    {
                        [normalRequests removeObjectForKey:identifier];
                    }
                    [dictionaryLock unlock];

                    [self decrementRequests];
                    return;
                }
            }
        }

        // remove from the requests lists
        [dictionaryLock lock]; // NSMutableDictionary isn't thread-safe for writing.
        [singleRequests removeObjectForKey:requestName];
        [normalRequests removeObjectForKey:identifier];
        [dictionaryLock unlock];

        // Saw at least one case where response was NSURLResponse, not NSHTTPURLResponse; Test case went away
        // So be defensive and return SDWTFResponseCode if we did not get a NSHTTPURLResponse
        NSInteger code = SDWTFResponseCode;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if ([response isKindOfClass:[NSHTTPURLResponse class]])
        {
            code = [httpResponse statusCode];
        }

        // handle redirects in a crappy way.. need to rework this to be done inside of SDURLConnection.
        if (code == 302)
        {
            [self will302RedirectToUrl:httpResponse.URL];
        }

        if (uiUpdateBlock == nil)
        {
            NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
            [mainQueue addOperationWithBlock:^
            {
                dataProcessingBlock(response, code, responseData, error);
            }];
        }
        else
        {
            [dataProcessingQueue addOperationWithBlock:^
            {
                id dataObject = nil;
                if (code != NSURLErrorCancelled)
                    dataObject = dataProcessingBlock(response, code, responseData, error);
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    uiUpdateBlock(dataObject, error);
                }];
            }];
        }

        [self decrementRequests];
	};

	NSURLCache *urlCache = [NSURLCache sharedURLCache];
	NSCachedURLResponse *cachedResponse = [urlCache validCachedResponseForRequest:request forTime:[cacheTTL unsignedLongValue] removeIfInvalid:YES];
	if (cache && cachedResponse && cachedResponse.response)
	{
		NSString *cachedString = [self responseFromData:cachedResponse.responseData];
		if (cachedString)
		{
			SDLog(@"***USING CACHED RESPONSE***");

			[self incrementRequests];

            urlCompletionBlock(nil, cachedResponse.response, cachedResponse.responseData, nil);

			return [SDMockRequestResult objectForResult:SDWebServiceResultCached identifier:nil request:request];
		}
	}

	[self incrementRequests];

	// see if this is a singleton request.

    BOOL singleRequest = NO;
	NSNumber *singleRequestNumber = requestDetails[@"singleRequest"];
    if (singleRequestNumber)
    {
        singleRequest = [singleRequestNumber boolValue];

        // if it is, lets cancel any with matching names.
        if (singleRequest)
        {
			SDURLConnection *existingConnection = singleRequests[requestName];
			if (existingConnection)
			{
				SDLog(@"Cancelling call.");
				[existingConnection cancel];
                [dictionaryLock lock]; // NSMutableDictionary isn't thread-safe for writing.
				[singleRequests removeObjectForKey:requestName];
                [dictionaryLock unlock];
				[self decrementRequests];
			}
        }
    }

	SDURLConnection *connection = [SDURLConnection sendAsynchronousRequest:request shouldCache:YES withResponseHandler:urlCompletionBlock];

    [dictionaryLock lock]; // NSMutableDictionary isn't thread-safe for writing.
    if (singleRequest)
        [singleRequests setObject:connection forKey:requestName];
    else
        [normalRequests setObject:connection forKey:identifier];
    [dictionaryLock unlock];

#endif
	return [SDMockRequestResult objectForResult:SDWebServiceResultSuccess identifier:identifier request:request];
}

- (void)cancelRequestForIdentifier:(NSString *)identifier
{
    SDURLConnection *connection = self.normalRequests[identifier];
    [connection cancel];
}

#pragma mark - Subclass should override these

- (void)serviceCallDidTimeoutForUrl:(NSURL*)url
{
	// override in subclass
}

- (void)showNetworkActivity
{
    // override in subclass.
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)hideNetworkActivity
{
    // override in subclass.
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)will302RedirectToUrl:(NSURL *)argUrl
{
	// Implement in service subclass for specific behavior
}

- (BOOL)handledError:(NSError *)error dataObject:(id)dataObject
{
    // do nothing.  override in subclass like so...

    /*
    SDWebServiceUICompletionBlock uiBlock = ^(id dataObject, NSError *error)
    {
        if ([self handledError:error dataObject:dataObject])
        {
            // do your *ERROR UI*
        }
        else
        {
            // do your *SUCCESS UI*

            // You may still need to do some error checking here.
            // Think of handledError: as kind of a global error handling for your app.
            // If this service call has possible error conditions that no other
            // service call would have, you'll want to look for those here as well.
        }
    }
     */

    return FALSE;
}

@end

#endif
