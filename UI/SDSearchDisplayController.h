//
//  SDSearchDisplayController.h
//  walmart
//
//  Created by brandon on 3/9/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDSearchDisplayController : UISearchDisplayController<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *searchHistory;
    NSArray *filteredHistory;
    NSString *filterString;
    UITableView *recentSearchTableView;
    NSUInteger maximumCount;
    NSMutableArray *alternateResults;
    BOOL useAlternateResultsToMatchFilter;
}

@property (nonatomic, retain) NSString *userDefaultsKey;
@property (nonatomic, assign) NSUInteger maximumCount;
@property (nonatomic, retain) NSString *filterString;
@property (nonatomic, assign) BOOL useAlternateResultsToMatchFilter;

- (void)addStringToHistory:(NSString *)string;
- (void)addArrayToHistory:(NSArray *)array;
- (void)addStringToAlternateResults:(NSString *)string;
- (void)addArrayToAlternateResults:(NSArray *)array;

@end

// This is pretty janky, but apple does it, so why not...
@interface UIViewController (SDSearchDisplayControllerSupport)
@property(nonatomic, readonly, retain) SDSearchDisplayController *searchDisplayController;
@end

