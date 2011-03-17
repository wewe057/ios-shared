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
    NSMutableArray *searchHistory;
    NSArray *filteredHistory;
    NSString *filterString;
    UITableView *recentSearchTableView;
    NSUInteger maximumCount;
    NSArray *alternateResults;
    id selectedItem;
}

@property (nonatomic, retain) NSString *userDefaultsKey;
@property (nonatomic, assign) NSUInteger maximumCount;
@property (nonatomic, retain) NSString *filterString;
@property (nonatomic, retain) NSArray *alternateResults;
@property (nonatomic, retain, readonly) id selectedItem;

- (void)addStringToHistory:(NSString *)string;

@end

// This is pretty janky, but apple does it, so why not...
@interface UIViewController (SDSearchDisplayControllerSupport)
@property(nonatomic, readonly, retain) SDSearchDisplayController *searchDisplayController;
@end

