//
//  SDSpanParserTests.m
//  ios-shared
//
//  Created by Cody Garvin on 10/1/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SDSpanParser.h"

@interface SDSpanParserTests : XCTestCase

@end

typedef NS_ENUM(NSUInteger, SRSpanMatchType)
{
    SRSpanMatchTypeOpen = 0,
    SRSpanMatchTypeClose
};

@interface SRSpanMatch : NSObject
@property (nonatomic, assign, readonly) NSRange               classRange;
@property (nonatomic, assign, readonly) NSRange               spanRange;
@property (nonatomic, assign, readonly) SRSpanMatchType       type;
+ (NSArray *)matchesIn:(NSString *)string;
- (NSRange)properRangeForSpanWithClassOnString:(NSString *)string;
@end

@interface SRSTestHelper : NSObject
+ (NSString *)stringForMockFile:(NSString *)mockfile;
@end

@implementation SRSTestHelper

+ (NSString *)stringForMockFile:(NSString *)mockfile
{
    NSString *mockString = nil;
    
    NSString *safeFilename = [mockfile lastPathComponent];
    NSString *finalPath = [[NSBundle bundleForClass:[self class]] pathForResource:safeFilename ofType:nil];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *mockData = nil;
    
    if (finalPath && [fileManager fileExistsAtPath:finalPath])
    {
        SDLog(@"*** Using mock data file '%@'", safeFilename);
        mockData = [NSData dataWithContentsOfFile:finalPath];
        mockString = [mockData stringRepresentation];
    }
    else
        SDLog(@"*** Unable to find mock file '%@'", safeFilename);
    
    return mockString;
}


@end

@implementation SDSpanParserTests
{
    SDSpanParser *spanParser;
}


- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testParseWithStyles
{
    
}

- (void)testProperRangeForSpanWithClassOnString
{
    
}

- (void)testMatchesInBasic
{
    NSString *stringToTest = [SRSTestHelper stringForMockFile:@"SpanTest_basic.txt"];
    NSArray *verifyArray = [SRSpanMatch matchesIn:stringToTest];
    NSInteger totalOpened = 0;
    NSInteger totalClosed = 0;
    for (SRSpanMatch *result in verifyArray)
    {
        if (result.type == SRSpanMatchTypeOpen)
        {
            ++totalOpened;
        }
        else
        {
            ++totalClosed;
        }
    }
    
    XCTAssertTrue(totalOpened == totalClosed, @"The total SRSpanMatch elements should be the same");

}

- (void)testMatchesInMissingClass
{
    NSString *stringToTest = [SRSTestHelper stringForMockFile:@"SpanTest_missingclass.txt"];
    NSArray *verifyArray = [SRSpanMatch matchesIn:stringToTest];
    NSInteger totalOpened = 0;
    NSInteger totalClosed = 0;
    for (SRSpanMatch *result in verifyArray)
    {
        if (result.type == SRSpanMatchTypeOpen)
        {
            ++totalOpened;
        }
        else
        {
            ++totalClosed;
        }
    }
    
    XCTAssertTrue(totalOpened == totalClosed, @"The total SRSpanMatch elements should be the same");
    
}

- (void)testMatchesInMissingClose
{
    NSString *stringToTest = [SRSTestHelper stringForMockFile:@"SpanTest_missingclose.txt"];
    NSArray *verifyArray = [SRSpanMatch matchesIn:stringToTest];
    NSInteger totalOpened = 0;
    NSInteger totalClosed = 0;
    for (SRSpanMatch *result in verifyArray)
    {
        if (result.type == SRSpanMatchTypeOpen)
        {
            ++totalOpened;
        }
        else
        {
            ++totalClosed;
        }
    }
    
    XCTAssertTrue(totalOpened > totalClosed, @"The total SRSpanMatch elements should not be the same, there should be an extra open");
    
}

@end
