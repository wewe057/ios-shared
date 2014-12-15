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

NSString * const kTest_rootPath = @"/";
NSString * const kTest_partialPath = @"path1";
NSString * const kTest_pathA = @"/path1/path2";
NSString * const kTest_pathB = @"/path2/path1";
NSString * const kTest_query = @"?param1=a&param2=b";

NSString * const kTest_urlString_nil = nil;
NSString * const kTest_urlString_bareNoQuery = @"http://example.com";
NSString * const kTest_urlString_rootNoQuery = @"http://example.com/";
NSString * const kTest_urlString_fullANoQuery = @"http://example.com/path1/path2";
NSString * const kTest_urlString_fullBNoQuery = @"http://example.com/path2/path1";
NSString * const kTest_urlString_bareWithQuery = @"http://example.com?param1=a&param2=b";
NSString * const kTest_urlString_rootWithQuery = @"http://example.com/?param1=a&param2=b";
NSString * const kTest_urlString_fullAWithQuery = @"http://example.com/path1/path2?param1=a&param2=b";
NSString * const kTest_urlString_fullBWithQuery = @"http://example.com/path2/path1?param1=a&param2=b";

#define expect(E,M,U) \
{ \
    NSURL *url = [NSURL URLWithString:U]; \
    BOOL actual = [M matchesRequest:[NSURLRequest requestWithURL:url]]; \
    if (E) \
    { \
        XCTAssertTrue(actual, @"expect mapping (%@) to match URL (%@)", M, U); \
    } \
    else \
    { \
        XCTAssertFalse(actual, @"expect mapping (%@) to NOT match URL (%@)", M, U); \
    } \
}


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
    SDWebServiceMockResponseRequestMapping *mapping = [[SDWebServiceMockResponseRequestMapping alloc] initWithPath:nil exactMatchPath:NO queryParameters:nil exactMatchQueryValues:NO];
    expect(YES,mapping,kTest_urlString_nil);
    expect(YES,mapping,kTest_urlString_bareNoQuery);
    expect(YES,mapping,kTest_urlString_rootNoQuery);
    expect(YES,mapping,kTest_urlString_fullANoQuery);
    expect(YES,mapping,kTest_urlString_fullBNoQuery);
    expect(YES,mapping,kTest_urlString_bareWithQuery);
    expect(YES,mapping,kTest_urlString_rootWithQuery);
    expect(YES,mapping,kTest_urlString_fullAWithQuery);
    expect(YES,mapping,kTest_urlString_fullBWithQuery);
}

- (void)testRootPathExactMatch
{
    SDWebServiceMockResponseRequestMapping *mapping = [[SDWebServiceMockResponseRequestMapping alloc] initWithPath:kTest_rootPath exactMatchPath:YES queryParameters:nil exactMatchQueryValues:NO];
    expect(NO,mapping,kTest_urlString_nil);
    expect(NO,mapping,kTest_urlString_bareNoQuery);
    expect(YES,mapping,kTest_urlString_rootNoQuery);
    expect(NO,mapping,kTest_urlString_fullANoQuery);
    expect(NO,mapping,kTest_urlString_fullBNoQuery);
    expect(NO,mapping,kTest_urlString_bareWithQuery);
    expect(YES,mapping,kTest_urlString_rootWithQuery);
    expect(NO,mapping,kTest_urlString_fullAWithQuery);
    expect(NO,mapping,kTest_urlString_fullBWithQuery);
}

- (void)testRootPathPattern
{
    SDWebServiceMockResponseRequestMapping *mapping = [[SDWebServiceMockResponseRequestMapping alloc] initWithPath:kTest_rootPath exactMatchPath:NO queryParameters:nil exactMatchQueryValues:NO];
    expect(NO,mapping,kTest_urlString_nil);
    expect(NO,mapping,kTest_urlString_bareNoQuery);
    expect(YES,mapping,kTest_urlString_rootNoQuery);
    expect(YES,mapping,kTest_urlString_fullANoQuery);
    expect(YES,mapping,kTest_urlString_fullBNoQuery);
    expect(NO,mapping,kTest_urlString_bareWithQuery);
    expect(YES,mapping,kTest_urlString_rootWithQuery);
    expect(YES,mapping,kTest_urlString_fullAWithQuery);
    expect(YES,mapping,kTest_urlString_fullBWithQuery);
}

- (void)testPathAExactMatch
{
    SDWebServiceMockResponseRequestMapping *mapping = [[SDWebServiceMockResponseRequestMapping alloc] initWithPath:kTest_pathA exactMatchPath:YES queryParameters:nil exactMatchQueryValues:NO];
    expect(NO,mapping,kTest_urlString_nil);
    expect(NO,mapping,kTest_urlString_bareNoQuery);
    expect(NO,mapping,kTest_urlString_rootNoQuery);
    expect(YES,mapping,kTest_urlString_fullANoQuery);
    expect(NO,mapping,kTest_urlString_fullBNoQuery);
    expect(NO,mapping,kTest_urlString_bareWithQuery);
    expect(NO,mapping,kTest_urlString_rootWithQuery);
    expect(YES,mapping,kTest_urlString_fullAWithQuery);
    expect(NO,mapping,kTest_urlString_fullBWithQuery);
}

- (void)testPathAPattern
{
    SDWebServiceMockResponseRequestMapping *mapping = [[SDWebServiceMockResponseRequestMapping alloc] initWithPath:kTest_pathA exactMatchPath:NO queryParameters:nil exactMatchQueryValues:NO];
    expect(NO,mapping,kTest_urlString_nil);
    expect(NO,mapping,kTest_urlString_bareNoQuery);
    expect(NO,mapping,kTest_urlString_rootNoQuery);
    expect(YES,mapping,kTest_urlString_fullANoQuery);
    expect(NO,mapping,kTest_urlString_fullBNoQuery);
    expect(NO,mapping,kTest_urlString_bareWithQuery);
    expect(NO,mapping,kTest_urlString_rootWithQuery);
    expect(YES,mapping,kTest_urlString_fullAWithQuery);
    expect(NO,mapping,kTest_urlString_fullBWithQuery);
}

- (void)testPartialPathExactMatch
{
    SDWebServiceMockResponseRequestMapping *mapping = [[SDWebServiceMockResponseRequestMapping alloc] initWithPath:kTest_partialPath exactMatchPath:YES queryParameters:nil exactMatchQueryValues:NO];
    expect(NO,mapping,kTest_urlString_nil);
    expect(NO,mapping,kTest_urlString_bareNoQuery);
    expect(NO,mapping,kTest_urlString_rootNoQuery);
    expect(NO,mapping,kTest_urlString_fullANoQuery);
    expect(NO,mapping,kTest_urlString_fullBNoQuery);
    expect(NO,mapping,kTest_urlString_bareWithQuery);
    expect(NO,mapping,kTest_urlString_rootWithQuery);
    expect(NO,mapping,kTest_urlString_fullAWithQuery);
    expect(NO,mapping,kTest_urlString_fullBWithQuery);
}

- (void)testPartialPathPattern
{
    SDWebServiceMockResponseRequestMapping *mapping = [[SDWebServiceMockResponseRequestMapping alloc] initWithPath:kTest_partialPath exactMatchPath:NO queryParameters:nil exactMatchQueryValues:NO];
    expect(NO,mapping,kTest_urlString_nil);
    expect(NO,mapping,kTest_urlString_bareNoQuery);
    expect(NO,mapping,kTest_urlString_rootNoQuery);
    expect(YES,mapping,kTest_urlString_fullANoQuery);
    expect(YES,mapping,kTest_urlString_fullBNoQuery);
    expect(NO,mapping,kTest_urlString_bareWithQuery);
    expect(NO,mapping,kTest_urlString_rootWithQuery);
    expect(YES,mapping,kTest_urlString_fullAWithQuery);
    expect(YES,mapping,kTest_urlString_fullBWithQuery);
}

@end
