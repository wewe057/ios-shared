//
//  SDTableViewSectionController.h
//  walmart
//
//  Created by Steve Riggins & Woolie on 1/2/14.
//  Copyright (c) 2014 Walmart. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SDTableViewSectionController;

//__________________________________________________________________________
// This protocol supplies section controllers to the SDTableViewSectionController
// And handles delegate methods

@protocol SDTableViewSectionControllerDelegate <NSObject>

@required

/**
 *  Return the array of controllers for the sections of the given table view
 *
 *  @param tableView The table view the controller needs controllers for
 *
 *  @return An array of objects that conform to SDTableViewSectionProtocol
 */
- (NSArray *)controllersForTableView:(UITableView *)tableView;

@optional

/**
 *  A section controller is asking you to push a view controller
 *
 *  @param sectionController The section controller making the request
 *  @param viewController    The view controller the section controller wants pushed
 *  @param animated          YES if the section controller wants the push animated
 */
- (void)sectionController:(SDTableViewSectionController *)sectionController pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

/**
 *  A section controller is asking you to present a view controller
 *
 *  @param sectionController The section controller making the request
 *  @param viewController    The view controller the section controller wants presented
 *  @param animated          YES if the section controller wants the presentation animated
 *  @param completion        A completion block to call when presentation is complete
 */
- (void)sectionController:(SDTableViewSectionController *)sectionController presentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;

/**
 *  A section controller is asking you to dismiss the current view controller
 *
 *  @param sectionController The section controller making the request
 *  @param animated          YES if the section controller wants the dismiss animated
 *  @param completion        A completion block to call when presentation is complete
 */
- (void)sectionController:(SDTableViewSectionController *)sectionController dismissViewControllerAnimated: (BOOL)animated completion: (void (^)(void))completion;
@end

//________________________________________________________________________________________
// This protocol declares the data and delegate interface for section controllers

@protocol SDTableViewSectionDelegate <NSObject>

// "DataSource" methods
@required

- (NSInteger)numberOfRowsForSectionController:(SDTableViewSectionController *)sectionController;
- (UITableViewCell *)sectionController:(SDTableViewSectionController *)sectionController cellForRow:(NSInteger)row;

@optional

- (NSString *)sectionControllerTitleForHeader:(SDTableViewSectionController *)sectionController;

// "Delegate" methods
@optional
- (void)sectionController:(SDTableViewSectionController *)sectionController didSelectRow:(NSInteger)row;

// Variable height support
- (CGFloat)sectionController:(SDTableViewSectionController *)sectionController heightForRow:(NSInteger)row;
@end

//__________________________________________________________________________
// This class manages sections and sending messages to its
// sectionDataSource and sectionDelegate

@interface SDTableViewSectionController : NSObject

- (instancetype) initWithTableView:(UITableView *)tableView;

@property (nonatomic, weak)             id <SDTableViewSectionControllerDelegate>  delegate;
@property (nonatomic, weak, readonly)   UITableView                                 *tableView;

/**
 *  Array of objects conforming to SDTableViewSectionProtocol
 */
@property (nonatomic, strong, readonly) NSArray                                     *sectionControllers;

/**
 *  Asks the section controller's delegate to push this view controller.  Use this method
 *  to push the view controller instead of trying to push it yourself
 *
 *  @param viewController UIViewController to push
 *  @param animated       YES if should be animated
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

/**
 *  Asks the section controller's delegate to present this view controller.  Use this method
 *  to present the view controller instead of trying to present it yourself
 *
 *  @param viewController UIViewController to present
 *  @param animated       YES if should be animated
 *  @param completion     completion block to call when done
 */
- (void)presentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;

/**
 *  Asks the section controller's delegate to dismiss the currently presented view controller.  Use this method
 *  instead of trying to present it yourself
 *
 *  @param animated   YES if should be animated
 *  @param completion completion block to call when done
 */
- (void)dismissViewControllerAnimated: (BOOL)animated completion: (void (^)(void))completion;
@end

