//
//  SDWebServiceMockResponseRequestMapping.m
//  ios-shared
//
//  Created by Douglas Sjoquist on 12/15/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "SDWebServiceMockResponseRequestMapping.h"

@interface SDWebServiceMockResponseRequestMapping()
@property (nonatomic,copy) NSString *pathPattern;
@property (nonatomic,copy) NSDictionary *queryParameterPatterns;
@end

@implementation SDWebServiceMockResponseRequestMapping

- (instancetype)initWithPatternsForPath:(NSString *) pathPattern
                        queryParameters:(NSDictionary *) queryParameterPatterns
{
    if ((self = [super init]))
    {
        _pathPattern = [pathPattern copy];
        _queryParameterPatterns = [queryParameterPatterns copy];
    }
    return self;
}

- (BOOL) matchesRequest:(NSURLRequest *) request
{
    BOOL result = YES;
    if ([self.pathPattern length] > 0)
    {
        NSRange range = [request.URL.path rangeOfString:self.pathPattern];
        if (range.location == NSNotFound)
        {
            result = NO;
        }
    }
    if (result && ([self.queryParameterPatterns count] > 0))
    {
        NSMutableDictionary *unmatchedQueryParameterPatterns = [self.queryParameterPatterns mutableCopy];
        NSArray *queryItems = [request.URL.query componentsSeparatedByString:@"&"];
        // all queryParameterPatterns must match something unique for mapping to match
        for (NSString *queryItem in queryItems)
        {
            NSArray *querySubitems = [queryItem componentsSeparatedByString:@"="];
            NSString *queryParameter = querySubitems[0];
            NSString *queryValue = ([querySubitems count] > 1) ? querySubitems[1] : nil;

            NSString *checkValue = unmatchedQueryParameterPatterns[queryParameter];
            if (checkValue != nil)
            {
                NSRange range = [queryValue rangeOfString:checkValue];
                if (range.location != NSNotFound)
                {
                    // found parameter whose value does match the pattern
                    [unmatchedQueryParameterPatterns removeObjectForKey:queryParameter];
                }
            }
        }
        if ([unmatchedQueryParameterPatterns count] > 0) {
            result = NO;
        }

    }
    return result;
}

@end
