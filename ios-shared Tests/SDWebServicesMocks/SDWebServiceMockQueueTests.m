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

- (void)testSingleMockResponseWithAutoPop;
{
    XCTestExpectation *firstWebServiceExpectation = [self expectationWithDescription:@"firstWebServiceExpectation"];

    NSString *testResponseFilename = @"SDWebServiceMockTest_bundleA.json";
    NSString *testResponseFilepath = [self.bundle pathForResource:testResponseFilename ofType:nil];
    NSData *checkData = [NSData dataWithContentsOfFile:testResponseFilepath];
    [self.webService pushMockResponseFile:testResponseFilename bundle:self.bundle];
    [self.webService performRequestWithMethod:@"testGETNoRouteParams"
                                      headers:nil
                            routeReplacements:nil
                          dataProcessingBlock:^id(NSURLResponse *response, NSInteger responseCode, NSData *responseData, NSError *error) {
                              XCTAssertEqualObjects(checkData, responseData, @"mock should supply data from mock response pushed above");
                              [firstWebServiceExpectation fulfill];
                              return nil;
                          } uiUpdateBlock:^(id dataObject, NSError *error) {
                          }];

    XCTestExpectation *secondWebServiceExpectation = [self expectationWithDescription:@"secondWebServiceExpectation"];
    [self.webService performRequestWithMethod:@"testGETNoRouteParams"
                                      headers:nil
                            routeReplacements:nil
                          dataProcessingBlock:^id(NSURLResponse *response, NSInteger responseCode, NSData *responseData, NSError *error) {
                              XCTAssertEqual(0, [responseData length], @"mock should NOT supply data from mock response pushed above");
                              [secondWebServiceExpectation fulfill];
                              return nil;
                          } uiUpdateBlock:^(id dataObject, NSError *error) {
                          }];
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        NSLog(@"waitForExpectationsWithTimeout: %@", error);
    }];
}

@end
