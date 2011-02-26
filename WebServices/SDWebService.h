//
//  SDWebService.h
//
//  Created by brandon on 2/14/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SDWebServiceCompletionBlock)(int responseCode, NSString *response, NSError **error);


@interface SDWebService : NSObject
{
	NSDictionary *serviceSpecification;
}

- (id)initWithSpecification:(NSString *)specificationName;
- (BOOL)performRequestWithMethod:(NSString *)requestName routeReplacements:(NSDictionary *)replacements completion:(SDWebServiceCompletionBlock)completionBlock;

@end
