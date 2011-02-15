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
	serviceSpecification = [NSDictionary dictionaryWithContentsOfFile:specFile];
	if (!serviceSpecification)
		[NSException raise:@"SDException" format:@"Unable to load the specifications file %@.plist", specificationName];
	
	return self;
}

- (void)dealloc
{
	[serviceSpecification release];
	[super dealloc];
}

- (BOOL)performRequestWithMethod:(NSString *)requestName parameters:(NSDictionary *)parameters completion:(SDWebServiceCompletionBlock)completionBlock
{
	// construct the URL based on the specification.
	NSURL *baseURL = [NSURL URLWithString:[serviceSpecification objectForKey:@"baseURL"]];
	NSDictionary *requestList = [serviceSpecification objectForKey:@"requests"];
	NSDictionary *requestDetails = [requestList objectForKey:requestName];
	NSDictionary *requestParams = [requestDetails objectForKey:@"queryParameters"];
	
	// combine the contents of queryParameters and the passed in parameters to form
	// a complete name and value list.
	NSArray *defaultParams = [parameters allKeys];
	NSMutableDictionary *actualParams = [requestParams mutableCopy];
	for (NSString *key in defaultParams)
	{
		NSDictionary *paramDetail = [requestParams objectForKey:key];
		NSObject *defaultValue = [paramDetail objectForKey:@"defaultValue"];
	}
	
	// build the url and put it here...
	NSURL *url = nil;
	
	__block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	
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
		NSError *error = nil;
		completionBlock([request responseStatusCode], responseString, &error);		
	}];
	
	
	[request startAsynchronous];
}

@end
