//
//  SDWebServiceMockResponseRequestMapping.h
//  ios-shared
//
//  Created by Douglas Sjoquist on 12/15/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDWebServiceMockResponseRequestMapping : NSObject

- (instancetype)initWithPatternsForPath:(NSString *) pathPattern
                        queryParameters:(NSDictionary *) queryParameterPatterns;

- (BOOL) matchesRequest:(NSURLRequest *) request;

@end
