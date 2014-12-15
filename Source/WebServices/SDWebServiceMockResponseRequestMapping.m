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

- (NSString *) description
{
    NSMutableString *result = [NSMutableString stringWithString:NSStringFromClass([self class])];
    if ([self.pathPattern length] > 0) {
        [result appendFormat:@"\npathPattern: %@", self.pathPattern];
    }
    if ([self.queryParameterPatterns count] > 0) {
        [result appendString:@"\nqueryParameterPatterns"];
        [self.queryParameterPatterns enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [result appendFormat:@"\n  %@=%@", key, obj];
        }];
    }
    return result;
}

- (BOOL) matchesRequest:(NSURLRequest *) request
{
    BOOL result = NO;
    if (request.URL == nil)
    {
        result = (self.pathPattern == nil);
    }
    else
    {
        if ([self.pathPattern length] == 0)
        {
            result = (request.URL != nil) && ([request.URL.path length] == 0);
        }
        else
        {
            NSRange range = [request.URL.path rangeOfString:self.pathPattern];
            result = (range.location != NSNotFound);
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
