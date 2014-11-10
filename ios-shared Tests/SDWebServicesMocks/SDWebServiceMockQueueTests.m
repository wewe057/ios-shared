//
//  SDWebServiceMockQueueTests.m
//  ios-shared
//
//  Created by Douglas Sjoquist on 11/10/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SDWebService.h"

@interface SDWebServiceMockQueueTests : XCTestCase
@property (nonatomic,strong) SDWebService *webService;
@end

@implementation SDWebServiceMockQueueTests

- (void)setUp {
    [super setUp];

    self.webService = [[SDWebService alloc] initWithSpecification:@"SDWebServiceMockTests"];
    ... here...
}

- (void)tearDown {
    [super tearDown];
}

- (void)testM1 {
}

@end
