//
//  SDBase64Tests.m
//  ios-shared
//
//  Created by Brandon Sneed on 2/11/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SDBase64.h"

@interface SDBase64Tests : XCTestCase

@end

@implementation SDBase64Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testLibResolvLoad
{
    NSString *dummyData = @"blahblahblah";
    NSString *base64data = [dummyData encodeToBase64String];
    
    XCTAssertTrue(![base64data isEqualToString:@"blahblahblah"], @"The strings should not match!");
}

@end
