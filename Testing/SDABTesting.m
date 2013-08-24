//
//  SDABTesting.m
//  ios-shared
//
//  Created by Brandon Sneed on 8/24/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "SDABTesting.h"

@interface SDABTesting (Private)
@property (copy) SDABTestingAnalyticsBlock analyticsBlock;
@end

@implementation SDABTesting

+ (instancetype)sharedInstance
{
	static dispatch_once_t oncePred;
	static id sharedInstance = nil;
	dispatch_once(&oncePred, ^{ sharedInstance = [[[self class] alloc] init]; });
	return sharedInstance;
}

#pragma mark - Support methods

- (BOOL)boolForDefaultsKey:(NSString *)keyName
{
    NSNumber *value = [[NSUserDefaults standardUserDefaults] valueForKeyPath:[NSString stringWithFormat:@"SDABTesting.%@", keyName]];
    return value.boolValue;
}

- (void)setBool:(BOOL)value forDefaultsKey:(NSString *)keyName
{

}

#pragma mark - Public interface

+ (void)setAnalyticsBlock:(SDABTestingAnalyticsBlock)block
{

}

+ (void)testForKey:(NSString *)keyName A:(SDABTestingBlock)aBlock B:(SDABTestingBlock)bBlock
{

}

+ (void)testForKey:(NSString *)keyName data:(NSDictionary *)data A:(SDABTestingDataBlock)aBlock B:(SDABTestingDataBlock)bBlock
{

}

+ (void)testForKey:(NSString *)keyName dependencyKey:(NSString *)depencencyKeyName A:(SDABTestingBlock)aBlock B:(SDABTestingBlock)bBlock
{

}

+ (void)testForKey:(NSString *)keyName dependencyKey:(NSString *)depencencyKeyName data:(NSDictionary *)data A:(SDABTestingDataBlock)aBlock B:(SDABTestingDataBlock)bBlock
{

}

+ (void)goalReached:(NSString *)keyName
{

}

@end
