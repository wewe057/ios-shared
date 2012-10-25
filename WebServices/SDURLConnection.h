//
//  SDURLConnection.h
//  ServiceTest
//
//  Created by Brandon Sneed on 11/3/11.
//  Copyright (c) 2011 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SDURLConnection;
@class SDURLConnectionAsyncDelegate;

typedef void (^SDURLConnectionResponseBlock)(SDURLConnection *connection, NSURLResponse *response, NSData *responseData, NSError *error);

@interface SDURLConnection : NSURLConnection

+ (NSInteger)maxConcurrentAsyncConnections;
+ (void)setMaxConcurrentAsyncConnections:(NSInteger)maxCount;

+ (SDURLConnection *)sendAsynchronousRequest:(NSURLRequest *)request shouldCache:(BOOL)cache withResponseHandler:(SDURLConnectionResponseBlock)handler;

@end
