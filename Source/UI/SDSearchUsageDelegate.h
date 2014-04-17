//
//  SDSearchUsageDelegate.h
//  asda
//
//  Created by Andrew Finnell on 4/16/14.
//  Copyright (c) 2014 Asda. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SDNavigationBarSearchField;

@protocol SDSearchUsageDelegate <NSObject>

- (void) searchUserTappedSearchField:(SDNavigationBarSearchField *)field;
- (void) searchTypedInWithTerm:(NSString *)term;
- (void) searchSuggestionWithTerm:(NSString *)term;
- (void) searchRecentWithTerm:(NSString *)term;

@end
