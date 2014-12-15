//
//  SDWebServiceMockResponseRequestMappingTests.m
//  ios-shared
//
//  Created by Douglas Sjoquist on 12/15/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "SDWebServiceMockResponseRequestMapping.h"

@interface SDWebServiceMockResponseRequestMappingTests : XCTestCase
@end

@implementation SDWebServiceMockResponseRequestMappingTests

- (void) expect:(BOOL) expect forMapping:(SDWebServiceMockResponseRequestMapping *) mapping urlString:(NSString *) urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    BOOL actual = [mapping matchesRequest:[NSURLRequest requestWithURL:url]];
    if (expect)
    {
        XCTAssertTrue(actual, @"expect mapping (%@) to match URL (%@)", mapping, urlString);
    }
    else
    {
        XCTAssertFalse(actual, @"expect mapping (%@) to NOT match URL (%@)", mapping, urlString);
    }
}

- (void)testEmptyMapping
{
    SDWebServiceMockResponseRequestMapping *mapping = [[SDWebServiceMockResponseRequestMapping alloc] initWithPatternsForPath:nil queryParameters:nil];
    [self expect:YES forMapping:mapping urlString:nil];
    [self expect:YES forMapping:mapping urlString:@"http://example.com"];
    [self expect:YES forMapping:mapping urlString:@"https://example.com"];
    [self expect:YES forMapping:mapping urlString:@"http://example.com?param1=a&param2=b"];
    [self expect:YES forMapping:mapping urlString:@"http://example.com/path1/path2?param1=a&param2=b"];
}

@end
