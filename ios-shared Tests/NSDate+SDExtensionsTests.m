//
//  NSDate+SDExtensionsTests.m
//  ios-shared
//
//  Created by Peter Marks on 4/15/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface NSDateTests : XCTestCase
{
}

@end

@implementation NSDateTests

- (void)testDateAtBeginningOfMonthForDate
{
    NSDate *taxDay = [NSDate dateFromRFC822String:@"2014-04-15T07:00:00-0000"];
    NSDate *aprilFoolsDay = [NSDate dateFromRFC822String:@"2014-04-01T07:00:00-0000"];
    NSDate *convertedFirstDayOfMonth = [NSDate dateAtBeginningOfMonthForDate:taxDay];
    XCTAssertTrue([convertedFirstDayOfMonth isEqualToDate:aprilFoolsDay]);
}

@end
