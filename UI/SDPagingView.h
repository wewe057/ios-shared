//
//  SDPagingView
//  Photos
//
//  Created by Brandon Sneed on 5/10/13.
//  Copyright (c) 2013 walmart. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDPagingView;

@protocol SDPagingViewDataSource <NSObject>
@required
/**
 Returns the number of views to be shown as pages in the paging view.
 */
- (NSInteger)numberOfViewsInPagingView:(SDPagingView *)pagingView;
/**
 Supplies a UIView to be used as a page in the paging view.
 */
- (UIView *)viewForPagingView:(SDPagingView *)pagingView;
/**
 Update the view as it's content has changed and it is being reused.
 */
- (void)pagingView:(SDPagingView *)pagingView updateView:(UIView *)view atIndex:(NSInteger)index;

@optional
/**
 The view became the center/active view or page in the paging view.
 */
- (void)pagingView:(SDPagingView *)pagingView viewBecameCenter:(UIView *)view atIndex:(NSInteger)index;
@end


@interface SDPagingView : UIView<UIScrollViewDelegate>

/**
 Datasource.  Must conform to SDPagingViewDataSource protocol.
 */
@property (nonatomic, weak) IBOutlet id<SDPagingViewDataSource> dataSource;
/**
 The spacing between pages.  The default is 20.
 */
@property (nonatomic, assign) CGFloat spaceBetweenPages;
/**
 Get or set the current page without animation.
 */
@property (nonatomic, assign) NSInteger currentPage;

/**
 Reloads the contents of the paging view.
 */
- (void)reloadData;
/**
 Sets the current page with optional animation.
 */
- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated;

@end
