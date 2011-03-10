//
//  SDWebService.m
//
//  Created by brandon on 2/14/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import "SDWebService.h"
#import "ASIHTTPRequest.h"

@implementation SDWebService

- (id)initWithSpecification:(NSString *)specificationName
{
	self = [super init];
	
	NSString *specFile = [[NSBundle mainBundle] pathForResource:specificationName ofType:@"plist"];
	serviceSpecification = [[NSDictionary dictionaryWithContentsOfFile:specFile] retain];
	if (!serviceSpecification)
		[NSException raise:@"SDException" format:@"Unable to load the specifications file %@.plist", specificationName];
	
	return self;
}

- (void)dealloc
{
	[serviceSpecification release];
	[super dealloc];
}

- (BOOL)performRequestWithMethod:(NSString *)requestName routeReplacements:(NSDictionary *)replacements completion:(SDWebServiceCompletionBlock)completionBlock
{
    if (![[Reachability reachabilityForInternetConnection] isReachable])
    {
        // we ain't got no connection Lt. Dan
        NSError *error = [NSError errorWithDomain:@"SDWebServiceError" code:SDWebServiceErrorNoConnection userInfo:nil];
        completionBlock(0, nil, &error);
        return NO;
    }
    
	// construct the URL based on the specification.
	NSURL *baseURL = [NSURL URLWithString:[serviceSpecification objectForKey:@"baseURL"]];
	NSDictionary *requestList = [serviceSpecification objectForKey:@"requests"];
	NSDictionary *requestDetails = [requestList objectForKey:requestName];
	NSString *routeFormat = [requestDetails objectForKey:@"routeFormat"];
	NSString *method = [requestDetails objectForKey:@"method"];
	NSDictionary *routeReplacements = [requestDetails objectForKey:@"routeReplacement"];
	
	
	// TODO: Need to put some error handling here in case the plist is jacked up...
	
	// end TODO
	
	
	// combine the contents of routeReplacements and the passed in replacements to form
	// a complete name and value list.
	NSArray *keyList = [replacements allKeys];
	NSMutableDictionary *actualReplacements = [routeReplacements mutableCopy];
	for (NSString *key in keyList)
	{
		// this takes all the data provided in replacements and overwrites any default
		// values specified in the plist.
		NSObject *value = [replacements objectForKey:key];
		[actualReplacements setObject:value forKey:key];
	}
	
	// now lets take that final list and apply it to the route format.
	keyList = [actualReplacements allKeys];
	NSString *route = routeFormat;
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
			route = [route stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}", key] withString:value];
	}
	
	// there are some unparsed parameters which means either the plist is wrong, or the caller 
	// gave us a list of replacements that weren't sufficient to continue on.
	if ([route rangeOfString:@"{"].location != NSNotFound)
	{
		[NSException raise:@"SDException" format:@"Unable to create request.  The URL still contains replacement markers: %@", route];
	}
	
	// build the url and put it here...
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseURL, route]];
	SDLog(@"outgoing request = %@", url);
	[actualReplacements release];
	
	__block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	request.delegate = self;
	request.requestMethod = method;
	
	// setup the completion blocks.  we call the same block because failure means
	// different things with different APIs.  pass along the info we've gathered
	// to the handler, and let it decide.  if its an HTTP failure, that'll get
	// passed along as well.
	[request setCompletionBlock:^{
		NSString *responseString = [request responseString];
		NSError *error = nil;
		completionBlock([request responseStatusCode], responseString, &error);
	}];
	[request setFailedBlock:^{
		NSString *responseString = [request responseString];
		NSError *error = [request error];
		completionBlock([request responseStatusCode], responseString, &error);		
	}];
	
	[request startAsynchronous];
	return YES;
}

@end
