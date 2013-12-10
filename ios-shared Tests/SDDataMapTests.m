//
//  SDDataMapTests.m
//  ios-shared
//
//  Created by Brandon Sneed on 12/9/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SDModelObject.h"
#import "RxRefillsModel.h"

#pragma mark - Test Support

@interface MyObject : SDModelObject

@property (nonatomic, strong) NSArray *blah1;
@property (nonatomic, strong) NSString *blah2;
@property (nonatomic, strong) MyObject *blah3;
@property (nonatomic, strong) MyObject *blah4;
@property (nonatomic, strong) NSNumber *blah5;
@property (nonatomic, strong) NSDictionary *blah6;
@property (nonatomic, assign) NSInteger blah7;
@property (nonatomic, strong) NSString *subBlah8;

@end

@implementation MyObject

- (void)setBlah4:(id)data
{
    _blah4 = data;
}

- (NSDictionary *)mappingDictionaryForData:(id)data
{
    return @{@"blah2": @"blah2"};
}

- (BOOL)validModel
{
    return YES;
}

@end

#pragma mark - Tests

@interface SDDataMapTests : XCTestCase

@end

@implementation SDDataMapTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testKeyPathExists
{
    MyObject *dummyObject1 = [[MyObject alloc] init];
    MyObject *dummyObject2 = [[MyObject alloc] init];
    
    dummyObject1.blah3 = dummyObject2;
    
    XCTAssert([dummyObject1 keyPathExists:@"blah2"], @"it says blah2 doesn't exist and it does!");
    XCTAssert([dummyObject1 keyPathExists:@"blah3.blah2"], @"it says blah3.blah2 doesn't exist and it does!");
    XCTAssert(![dummyObject1 keyPathExists:@"blah3blah2"], @"it says blah3blah2 exists and it doesn't!");
}

- (void)testBasicMappingNamesMatch
{
    MyObject *dummyObject = [[MyObject alloc] init];
    NSDictionary *dummyDictionary = @{@"blah2" : @"correctValue"};
    
    NSDictionary *mappingDictionary = @{@"blah2" : @"blah2"};
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:dummyDictionary toObject:dummyObject];
    
    XCTAssertTrue([dummyObject.blah2 isEqualToString:@"correctValue"], @"dummyObject doesn't the correct value for blah2!");
}

- (void)testBasicMappingNamesDontMatch
{
    MyObject *dummyObject = [[MyObject alloc] init];
    NSDictionary *dummyDictionary = @{@"blah2" : @"correctValue"};
    
    NSDictionary *mappingDictionary = @{@"blah2" : @"subBlah8"};
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:dummyDictionary toObject:dummyObject];
    
    XCTAssertTrue([dummyObject.subBlah8 isEqualToString:@"correctValue"], @"dummyObject doesn't the correct value for subBlah8!");
}

- (void)testTypeConversionNSStringToNSInteger
{
    MyObject *dummyObject = [[MyObject alloc] init];
    NSDictionary *dummyDictionary = @{@"blah7" : @"1337"};
    
    NSDictionary *mappingDictionary = @{@"blah7" : @"blah7"};
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:dummyDictionary toObject:dummyObject];
    
    XCTAssertTrue((dummyObject.blah7 == 1337), @"dummyObject doesn't have the correct value for blah7!");
}

- (void)testTypeConversionNSStringToNSNumber
{
    MyObject *dummyObject = [[MyObject alloc] init];
    NSDictionary *dummyDictionary = @{@"blah5" : @"1337"};
    
    NSDictionary *mappingDictionary = @{@"blah5" : @"blah5"};
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:dummyDictionary toObject:dummyObject];
    
    XCTAssertTrue((dummyObject.blah5.integerValue == 1337), @"dummyObject doesn't have the correct value for blah5!");
    XCTAssertTrue([dummyObject.blah5 isKindOfClass:[NSNumber class]], @"dummyObject.blah5 isn't an NSNumber!");
}

- (void)testTypeConversionNSNumberToNSString
{
    MyObject *dummyObject = [[MyObject alloc] init];
    NSDictionary *dummyDictionary = @{@"blah2" : @1337};
    
    NSDictionary *mappingDictionary = @{@"blah2" : @"blah2"};
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:dummyDictionary toObject:dummyObject];
    
    XCTAssertTrue(([dummyObject.blah2 isEqualToString:@"1337"]), @"dummyObject doesn't have the correct value for blah2!");
    XCTAssertTrue([dummyObject.blah2 isKindOfClass:[NSString class]], @"dummyObject.blah2 isn't an NSString!");
}

- (void)testTypeConversionNSIntegerToNSString
{
    MyObject *dummyObject = [[MyObject alloc] init];
    dummyObject.blah7 = 1337;
    NSMutableDictionary *dummyDictionary = [NSMutableDictionary dictionary];
    
    NSDictionary *mappingDictionary = @{@"blah7" : @"blah7"};
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:dummyObject toObject:dummyDictionary];
    
    id value = [dummyDictionary objectForKey:@"blah7"];
    XCTAssertTrue([value isKindOfClass:[NSNumber class]], @"value isn't an NSNumber!");
    XCTAssertTrue(([value integerValue] == 1337), @"value doesn't have the correct value for blah7!");
}

- (void)testTypeConversionToModelsArray
{
    MyObject *dummyObject = [[MyObject alloc] init];
    
    NSArray *blah1 = @[@1, @2, @3];
    
    NSDictionary *dummyDictionary = @{@"blah1" : blah1};
    
    NSDictionary *mappingDictionary = @{@"blah1" : @"(NSArray<NSString>)blah1"};
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:dummyDictionary toObject:dummyObject];
    
    XCTAssertTrue((dummyObject.blah1.count == 3), @"dummyObject doesn't have 3 items like it should!");
    
    NSString *item = [dummyObject.blah1 objectAtIndex:1];
    XCTAssertTrue([item isKindOfClass:[NSString class]], @"blah1's sub items aren't of the NSString type!");
    XCTAssertTrue(item.integerValue == 2, @"item's value should be 2!");
}

- (void)testObjectArrayToDictionary
{
    NSMutableDictionary *dummyObject = [NSMutableDictionary dictionary];
    
    NSArray *blah1 = @[@"test1", @"test2", @"test3"];
    
    NSDictionary *dummyDictionary = @{@"blah1" : blah1};
    
    NSDictionary *mappingDictionary = @{@"blah1" : @"(NSArray<NSString>)blah1"};
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:dummyDictionary toObject:dummyObject];
    
    NSArray *output = (NSArray *)[dummyObject objectForKey:@"blah1"];
    XCTAssertTrue((output.count == 3), @"dummyObject doesn't have 3 items like it should!");
}

- (void)testDictionaryWithArrayToDictionaryWithModelObjects
{
    NSMutableDictionary *dummyObject = [NSMutableDictionary dictionary];
    NSDictionary *object1 = @{@"blah2": @"object1"};
    NSDictionary *object2 = @{@"blah2": @"object2"};
    NSDictionary *object3 = @{@"blah2": @"object3"};
    
    NSArray *blah1 = @[object1, object2, object3];
    
    NSDictionary *dummyDictionary = @{@"blah1" : blah1};
    
    NSDictionary *mappingDictionary = @{@"blah1" : @"(NSArray<MyObject>)blah1"};
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:dummyDictionary toObject:dummyObject];
    
    NSArray *output = (NSArray *)[dummyObject objectForKey:@"blah1"];
    XCTAssertTrue((output.count == 3), @"dummyObject doesn't have 3 items like it should!");
    XCTAssertTrue([[output objectAtIndex:0] isKindOfClass:[MyObject class]], @"The items in the output array aren't of MyObject!");
}

- (void)testDictionaryWithArrayToDictionaryWithModelObjects_oldStyle
{
    NSMutableDictionary *dummyObject = [NSMutableDictionary dictionary];
    NSDictionary *object1 = @{@"blah2": @"object1"};
    NSDictionary *object2 = @{@"blah2": @"object2"};
    NSDictionary *object3 = @{@"blah2": @"object3"};
    
    NSArray *blah1 = @[object1, object2, object3];
    
    NSDictionary *dummyDictionary = @{@"blah1" : blah1};
    
    NSDictionary *mappingDictionary = @{@"blah1" : @"<MyObject>blah1"};
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:dummyDictionary toObject:dummyObject];
    
    NSArray *output = (NSArray *)[dummyObject objectForKey:@"blah1"];
    XCTAssertTrue((output.count == 3), @"dummyObject doesn't have 3 items like it should!");
    XCTAssertTrue([[output objectAtIndex:0] isKindOfClass:[MyObject class]], @"The items in the output array aren't of MyObject!");
}

- (void)testModelObjectToDictionary
{
    MyObject *inputObject = [[MyObject alloc] init];
    inputObject.blah2 = @"output output.";
    
    NSMutableDictionary *outputObject = [NSMutableDictionary dictionary];
    
    NSDictionary *mappingDictionary = @{@"blah2" : @"<NSString>blah2"};
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:inputObject toObject:outputObject];
    
    NSString *output = (NSString *)[outputObject objectForKey:@"blah2"];
    XCTAssertTrue([output isEqualToString:@"output output."], @"dummyObject doesn't have 3 items like it should!");
}

- (void)testDictionaryToSelector
{
    NSDictionary *inputObject = @{@"blah2": @"hello"};
    
    MyObject *outputObject = [[MyObject alloc] init];
    
    NSDictionary *mappingDictionary = @{@"blah2" : @"@selector(setSubBlah8:)"};
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:inputObject toObject:outputObject];
    
    XCTAssertTrue([outputObject.subBlah8 isEqualToString:@"hello"], @"dummyObject doesn't have 3 items like it should!");
}

- (void)testModelsStaticImport
{
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"json1" ofType:@"txt"];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    
    NSDictionary *fileDictionary = [fileData JSONDictionary];
    
    RxRefillsModel *refillsObject = [[RxRefillsModel alloc] init];
    [[SDDataMap map] mapObject:fileDictionary toObject:refillsObject];
    
    NSDictionary *dictionary = [refillsObject dictionaryRepresentation];
    NSLog(@"dictionary = %@", dictionary);
    
    XCTAssertTrue([refillsObject.patient.lastName isEqualToString:@"PHARMA2"], @"The patient field didn't get set properly!");
    XCTAssertTrue([((RxOrderModel *)[refillsObject.orders objectAtIndex:0]).drug isEqualToString:@"ALPRAZOLAM 0.5MG    TAB"], @"The orders array didn't get set properly!");
}

- (void)testModelsStaticImportAndExport
{
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"json1" ofType:@"txt"];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    
    NSDictionary *fileDictionary = [fileData JSONDictionary];
    
    RxRefillsModel *refillsObject = [[RxRefillsModel alloc] init];
    [[SDDataMap map] mapObject:fileDictionary toObject:refillsObject];
    
    NSMutableDictionary *newDictionary = [NSMutableDictionary dictionary];
    [[SDDataMap map] mapObject:refillsObject toObject:newDictionary];
    
    NSArray *rxFillItems = [newDictionary valueForKey:@"RxFill"];
    NSDictionary *patientNameDict = [newDictionary valueForKey:@"patientName"];
    NSString *lastName = [patientNameDict valueForKey:@"lastName"];
    NSDictionary *orderInfo = [rxFillItems objectAtIndex:0];
    NSString *order = [orderInfo valueForKey:@"drug"];
    
    XCTAssertTrue((rxFillItems.count == 6), @"RxFill in newDictionary doesn't have 6 items like it should!");
    XCTAssertTrue([lastName isEqualToString:@"PHARMA2"], @"patientName in newDictionary didn't come out properly!");
    XCTAssertTrue([order isEqualToString:@"ALPRAZOLAM 0.5MG    TAB"], @"the first order in RxFill didn't come out properly!");
}

@end
