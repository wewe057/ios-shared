//
//  SDWebService.h
//
//  Created by brandon on 2/14/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <Foundation/Foundation.h>
// this comes from ASI-HTTP
#import "Reachability.h"

typedef void (^SDWebServiceCompletionBlock)(int responseCode, NSString *response, NSError **error);

enum
{
    SDWebServiceErrorNoConnection = 0,
    // all other errors come from ASI-HTTP
};

@interface SDWebService : NSObject
{
	NSDictionary *serviceSpecification;
    NSMutableArray *serviceCookies;
    NSMutableDictionary *queues;
}

@property (nonatomic, retain) NSMutableArray *serviceCookies;

- (id)initWithSpecification:(NSString *)specificationName;
- (BOOL)performRequestWithMethod:(NSString *)requestName routeReplacements:(NSDictionary *)replacements completion:(SDWebServiceCompletionBlock)completionBlock;
- (BOOL)responseIsValid:(NSString *)response;

@end
