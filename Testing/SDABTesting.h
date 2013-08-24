//
//  SDABTesting.h
//  ios-shared
//
//  Created by Brandon Sneed on 8/24/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SDABTestingBlock)();
typedef void (^SDABTestingDataBlock)(NSDictionary *jsonData);
typedef void (^SDABTestingAnalyticsBlock)(NSString *keyName, NSString *keyData);

@interface SDABTesting : NSObject

+ (void)setAnalyticsBlock:(SDABTestingAnalyticsBlock)block;

+ (void)testForKey:(NSString *)keyName A:(SDABTestingBlock)aBlock B:(SDABTestingBlock)bBlock;
+ (void)testForKey:(NSString *)keyName data:(NSDictionary *)data A:(SDABTestingDataBlock)aBlock B:(SDABTestingDataBlock)bBlock;

+ (void)testForKey:(NSString *)keyName dependencyKey:(NSString *)depencencyKeyName A:(SDABTestingBlock)aBlock B:(SDABTestingBlock)bBlock;
+ (void)testForKey:(NSString *)keyName dependencyKey:(NSString *)depencencyKeyName data:(NSDictionary *)data A:(SDABTestingDataBlock)aBlock B:(SDABTestingDataBlock)bBlock;

+ (void)goalReached:(NSString *)keyName;

@end
