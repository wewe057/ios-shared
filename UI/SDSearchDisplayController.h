//
//  SDSearchDisplayController.h
//  walmart
//
//  Created by brandon on 3/9/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SDSearchDisplayResultsProtocol <NSObject>
- (NSString *)displayName;
- (NSString *)name;
@end


@interface SDSearchDisplayController : UISearchDisplayController<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *masterList;
    NSMutableArray *searchHistory;
    NSArray *filteredHistory;
    NSString *filterString;
    UITableView *recentSearchTableView;
    NSUInteger maximumCount;
    NSArray *alternateResults;
    id selectedSearchItem;
}

@property (nonatomic, strong) NSString *userDefaultsKey;
@property (nonatomic, assign) NSUInteger maximumCount;
@property (nonatomic, strong) NSString *filterString;
@property (nonatomic, strong) NSArray *alternateResults;
@property (nonatomic, strong) id selectedSearchItem;

- (void)addStringToHistory:(NSString *)string;

@end

// This is pretty janky, but apple does it, so why not...
@interface UIViewController (SDSearchDisplayControllerSupport)
@property(nonatomic, readonly, retain) SDSearchDisplayController *searchDisplayController;
@end

