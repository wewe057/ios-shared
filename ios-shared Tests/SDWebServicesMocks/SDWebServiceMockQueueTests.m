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
@property (nonatomic,strong) NSBundle *bundle;
@end

@implementation SDWebServiceMockQueueTests

- (void)setUp;
{
    [super setUp];

    self.bundle = [NSBundle bundleForClass:[self class]];

    self.webService = [[SDWebService alloc] initWithSpecification:@"SDWebServiceMockTests" host:@"testhost" path:@"/"];
    self.webService.maxConcurrentOperationCount = 1; // to ensure predictable testing
}

- (void)testDefaultAutoPop;
{
    XCTAssertTrue(self.webService.autoPopMocks);
}

- (void) checkWebService:(SDWebService *) webService
         withBlock:(void (^)(NSData *responseData, NSError *error)) block;
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"webService request completed"];
    [self.webService performRequestWithMethod:@"testGETNoRouteParams"
                                      headers:nil
                            routeReplacements:nil
                          dataProcessingBlock:^id(NSURLResponse *response, NSInteger responseCode, NSData *responseData, NSError *error) {
                              block(responseData, error);
                              [expectation fulfill];
                              return nil;
                          } uiUpdateBlock:nil];
}

- (void)testSingleMockResponseWithAutoPop;
{
    NSString *testResponseFilename = @"SDWebServiceMockTest_bundleA.json";
    NSString *testResponseFilepath = [self.bundle pathForResource:testResponseFilename ofType:nil];
    NSData *checkData = [NSData dataWithContentsOfFile:testResponseFilepath];
    [self.webService pushMockResponseFile:testResponseFilename bundle:self.bundle];

    [self checkWebService:self.webService
                withBlock:^(NSData *responseData, NSError *error) {
                    XCTAssertEqualObjects(checkData, responseData, @"mock should supply data from mock response pushed above");
                }];

    [self checkWebService:self.webService
                withBlock:^(NSData *responseData, NSError *error) {
                    XCTAssertEqual(0, [responseData length], @"mock should NOT supply data from mock response pushed above");
                }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testSingleMockResponseWithNoAutoPop;
{
    NSString *testResponseFilename = @"SDWebServiceMockTest_bundleA.json";
    NSString *testResponseFilepath = [self.bundle pathForResource:testResponseFilename ofType:nil];
    NSData *checkData = [NSData dataWithContentsOfFile:testResponseFilepath];
    [self.webService pushMockResponseFile:testResponseFilename bundle:self.bundle];

    self.webService.autoPopMocks = NO;
    
    [self checkWebService:self.webService
                withBlock:^(NSData *responseData, NSError *error) {
                    XCTAssertEqualObjects(checkData, responseData, @"mock should supply data from mock response pushed above");
                }];

    [self checkWebService:self.webService
                withBlock:^(NSData *responseData, NSError *error) {
                    XCTAssertEqualObjects(checkData, responseData, @"mock should supply data from mock response pushed above");
                }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testSingleMockResponseWithManualPop;
{
    NSString *testResponseFilename = @"SDWebServiceMockTest_bundleA.json";
    NSString *testResponseFilepath = [self.bundle pathForResource:testResponseFilename ofType:nil];
    NSData *checkData = [NSData dataWithContentsOfFile:testResponseFilepath];
    [self.webService pushMockResponseFile:testResponseFilename bundle:self.bundle];

    [self checkWebService:self.webService
                withBlock:^(NSData *responseData, NSError *error) {
                    XCTAssertEqualObjects(checkData, responseData, @"mock should supply data from mock response pushed above");
                }];

    [self.webService popMockResponseFile];

    [self checkWebService:self.webService
                withBlock:^(NSData *responseData, NSError *error) {
                    XCTAssertEqual(0, [responseData length], @"mock should NOT supply data from mock response pushed above");
                }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

@end
