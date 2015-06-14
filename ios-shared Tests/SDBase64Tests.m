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
@property (nonatomic, copy) NSData *blahblahblahData;
@property (nonatomic, copy) NSString *blahblahblahString;
@property (nonatomic, copy) NSString *blahblahblahEncodedString;
@property (nonatomic, copy) NSData *emailData;
@property (nonatomic, copy) NSString *emailString;
@property (nonatomic, copy) NSString *emailEncodedString;
@end

@implementation SDBase64Tests

- (void)setUp
{
    [super setUp];
    
    self.blahblahblahString = @"blahblahblah";
    self.blahblahblahData = [self.blahblahblahString dataUsingEncoding:NSUTF8StringEncoding];
    self.blahblahblahEncodedString = @"YmxhaGJsYWhibGFo";
    
    self.emailString = @"someEmailAddress2015&&@walmart.com";
    self.emailData = [self.emailString dataUsingEncoding:NSUTF8StringEncoding];
    self.emailEncodedString = @"c29tZUVtYWlsQWRkcmVzczIwMTUmJkB3YWxtYXJ0LmNvbQ==";
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBasicStringEncodeDecode
{
    NSString *dummyString = @"blahblahblah";
    NSString *base64String = [dummyString encodeToBase64String];
    
    XCTAssertNotEqualObjects(base64String,dummyString, @"The strings should not match!");
    
    NSString *decodedString = [base64String decodeBase64ToString];
    XCTAssertEqualObjects(decodedString ,dummyString, @"The strings should match!");
}

- (void)testEncodeToBase64DataBlah
{
    NSData *base64EncodedBlah = [self.blahblahblahData encodeToBase64Data];
    NSString *base64String = [[NSString alloc] initWithData:base64EncodedBlah encoding:NSUTF8StringEncoding];
    
    XCTAssertEqualObjects(base64String, self.blahblahblahEncodedString, @"Strings do not match");
}

- (void)testEncodeToBase64DataEmail
{
    NSData *base64EncodedEmail = [self.emailData encodeToBase64Data];
    NSString *base64String = [[NSString alloc] initWithData:base64EncodedEmail encoding:NSUTF8StringEncoding];
    
    XCTAssertEqualObjects(base64String, self.emailEncodedString, @"Strings do not match");
}




@end
