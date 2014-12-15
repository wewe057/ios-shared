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

- (void) addRoute:(NSString *)route withHandler:(id<SDURLRouteHandler>)handler
{
    [self.entries addObject:[[SDURLRouterEntry alloc] initWithRoute:route handler:handler]];
}

- (void) addRoute:(NSString *)route withBlock:(SDURLRouteHandlerBlock)block
{
    [self addRoute:route withHandler:[[SDBlockURLRouteHandler alloc] initWithBlock:block]];
}

- (void) routeURL:(NSURL *)url
{
    for (SDURLRouterEntry *entry in self.entries)
    {
        NSDictionary *parameters = [entry matchesURL:url];
        if (parameters != nil)
        {
            [entry handleURL:url withParameters:parameters];
            break;
        }
    }
}

@end

@implementation SDBlockURLRouteHandler {
    SDURLRouteHandlerBlock _block;
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

- (void) handleURL:(NSURL *)url withParameters:(NSDictionary *)parameters
{
    if ( _block != nil )
    {
        _block(url, parameters);
    }
}

@end
