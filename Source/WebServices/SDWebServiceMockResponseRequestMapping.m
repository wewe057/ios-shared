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
@property (nonatomic,assign) BOOL exactMatchPath;
@property (nonatomic,copy) NSDictionary *queryParameterPatterns;
@property (nonatomic,assign) BOOL exactMatchQueryValues;
@end

@implementation SDWebServiceMockResponseRequestMapping

- (instancetype)initWithPath:(NSString *) pathPattern
              exactMatchPath:(BOOL) exactMatchPath
             queryParameters:(NSDictionary *) queryParameterPatterns
       exactMatchQueryValues:(BOOL) exactMatchQueryValues
{
    if ((self = [super init]))
    {
        _pathPattern = [pathPattern copy];
        _exactMatchPath = exactMatchPath;
        _queryParameterPatterns = [queryParameterPatterns copy];
        _exactMatchQueryValues = exactMatchQueryValues;
    }
    return self;
}

- (NSString *) description
{
    NSMutableString *result = [NSMutableString stringWithString:NSStringFromClass([self class])];
    if ([self.pathPattern length] > 0) {
        [result appendFormat:@"\npathPattern: %@", self.pathPattern];
        if (self.exactMatchPath)
        {
            [result appendString:@" (exact match)"];
        }
        else
        {
            [result appendString:@" (pattern match)"];
        }
    }
    if ([self.queryParameterPatterns count] > 0) {
        [result appendString:@"\nqueryParameterPatterns"];
        if (self.exactMatchQueryValues)
        {
            [result appendString:@" (exact matches)"];
        }
        else
        {
            [result appendString:@" (pattern matches)"];
        }
        [self.queryParameterPatterns enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [result appendFormat:@"\n  %@=%@", key, obj];
        }];
    }
    return result;
}

- (BOOL) pattern:(NSString *) pattern matchesValue:(NSString *) value exactly:(BOOL) exactly
{
    BOOL result = NO;
    if ([pattern length] == 0)
    {
        // specifying exact match for empty pattern means the value should be nil/empty
        result = exactly ? ([value length] == 0) : YES;
    }
    else
    {
        if (exactly)
        {
            result = [pattern isEqualToString:value];
        }
        else if ([value length] == 0)
        {
            result = NO;
        }
        else
        {
            NSRange range = [value rangeOfString:pattern];
            result = (range.location != NSNotFound);
        }
    }
    return result;
}

- (BOOL) matchesRequest:(NSURLRequest *) request
{
    BOOL result = [self pattern:self.pathPattern matchesValue:request.URL.path exactly:self.exactMatchPath];

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
                if ([self pattern:checkValue matchesValue:queryValue exactly:self.exactMatchQueryValues])
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
