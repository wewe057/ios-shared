//
//  SDSearchSuggestionsDataSource.h
//  asda
//
//  Created by Andrew Finnell on 4/16/14.
//  Copyright (c) 2014 Asda. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SDSearchSuggestionsCompletion)(NSArray *searchSuggestions);

@protocol SDSearchSuggestionsDataSource <NSObject>

- (void) searchSuggestionsForString:(NSString *)searchString completion:(SDSearchSuggestionsCompletion)block;
- (NSArray *) recentSearchStrings;
- (void) clearRecentSearches;
- (void) addRecentSearchString:(NSString *)string;

@end
