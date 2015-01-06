//
//  SDURLRouter.m
//  ios-shared
//
//  Created by Andrew Finnell on 12/11/14.
//  Copyright (c) 2014 Set Direction. All rights reserved.
//

#import "SDURLRouter.h"
#import "SDURLRouterEntry.h"
#import "SDURLRouteHandler.h"

@interface SDBlockURLRouteHandler : NSObject <SDURLRouteHandler>

- (instancetype) initWithBlock:(SDURLRouteHandlerBlock)block;
- (instancetype) initWithRegexBlock:(SDURLRouteHandlerBlock)block;

@end

@interface SDURLRouter()

@property (nonatomic, strong) NSMutableArray *entries;

@end

@implementation SDURLRouter

- (instancetype) init
{
    self = [super init];
    if ( self != nil )
    {
        _entries = [NSMutableArray array];
    }
    return self;
}

- (void) addRegexRoute:(NSRegularExpression *)routeRegex withHandler:(id<SDURLRouteHandler>)handler
{
    [self.entries addObject:[[SDURLRouterEntry alloc] initWithRouteRegex:routeRegex handler:handler]];
}

- (void) addRegexRoute:(NSRegularExpression *)routeRegex withBlock:(SDURLRouteHandlerBlock)block
{
    [self addRegexRoute:routeRegex withHandler:[[SDBlockURLRouteHandler alloc] initWithRegexBlock:block]];
}

- (void) addRoute:(NSString *)route withHandler:(id<SDURLRouteHandler>)handler
{
    [self.entries addObject:[[SDURLRouterEntry alloc] initWithRoute:route handler:handler]];
}

- (void) addRoute:(NSString *)route withBlock:(SDURLRouteHandlerBlock)block
{
    [self addRoute:route withHandler:[[SDBlockURLRouteHandler alloc] initWithBlock:block]];
}

- (BOOL) routeURL:(NSURL *)url
{
    BOOL handled = NO;
    for (SDURLRouterEntry *entry in self.entries)
    {
        SDURLMatchResult *matchResult = [entry matchesURL:url];
        if (matchResult.isMatch)
        {
            [entry handleURL:url withMatchResult:matchResult];
            handled = YES;
            break;
        }
    }
    return handled;
}

@end

@implementation SDBlockURLRouteHandler {
    SDURLRouteHandlerBlock _block;
    SDURLRouteHandlerBlock _regexBlock;
}

- (instancetype) initWithBlock:(SDURLRouteHandlerBlock)block
{
    self = [super init];
    if ( self != nil )
    {
        _block = [block copy];
    }
    return self;
}

- (instancetype) initWithRegexBlock:(SDURLRouteHandlerBlock)block
{
    self = [super init];
    if ( self != nil )
    {
        _block = [block copy];
    }
    return self;
}

- (void) handleURL:(NSURL *)url withMatchResult:(SDURLMatchResult *)matchResult
{
    if ( _block != nil )
    {
        _block(url, matchResult);
    }
    else if ( _regexBlock != nil )
    {
        _regexBlock(url, matchResult);
    }
}

@end
