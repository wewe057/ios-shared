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

/**
 *  A section controller is asking you to push a view controller
 *
 *  @param sectionController The section controller making the request
 *  @param viewController    The view controller the section controller wants pushed
 *  @param animated          YES if the section controller wants the push animated
 */
- (void)sectionController:(SDTableViewSectionController *)sectionController pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
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
 *  to push the view controller instead of trying to push it yourself to keep the design clean
 *
 *  @param viewController UIViewController to push
 *  @param animated       YES if should be animated
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end

