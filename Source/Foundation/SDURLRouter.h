//
//  SDURLRouter.h
//  ios-shared
//
//  Created by Andrew Finnell on 12/11/14.
//  Copyright (c) 2014 Set Direction. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SDURLRouteHandler;

typedef void (^SDURLRouteHandlerBlock)(NSURL *url, NSDictionary *parameters);
typedef void (^SDURLRegexRouteHandlerBlock)(NSURL *url, NSArray *matches);

@interface SDURLRouter : NSObject

- (void) addRoute:(NSString *)route withHandler:(id<SDURLRouteHandler>)handler;
- (void) addRoute:(NSString *)route withBlock:(SDURLRouteHandlerBlock)block;
- (void) addRegexRoute:(NSRegularExpression *)routeRegex withHandler:(id<SDURLRouteHandler>)handler;
- (void) addRegexRoute:(NSRegularExpression *)routeRegex withBlock:(SDURLRegexRouteHandlerBlock)block;

- (BOOL) routeURL:(NSURL *)url;

@end
