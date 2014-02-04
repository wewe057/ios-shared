//
//  SDTableViewSectionController.h
//  ios-shared

//
//  Created by Steve Riggins & Woolie on 1/2/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SECTIONCONTROLLER_MAX_HEIGHT MAXFLOAT

@class SDTableViewSectionController;

//____________________________________________________________________________________________
// SDTableViewSectionControllerDelegate is typically implemented by a UIViewController
// to provide the logic for how the table view should be laid out.

// The implementor of this protocol is required to supply an array of section controllers
// to the SDTableViewSectionController via the controllersForTableView: delegate method

// Optional delete methods add navigation support.  You should implement these methods
// If you want your view controller to support push/pop/modal navigation
// (Proxy these methods to your navigationController)

@protocol SDTableViewSectionControllerDelegate <NSObject>

@required

/**
 *  Return the array of controllers for the sections of the given table view
 *
 *  @param tableView The table view the controller needs controllers for
 *
 *  @return An array of objects that conform to SDTableViewSectionDelegate
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

/**
 *  A section controller is asking you to pop the current view controller
 *
 *  @param sectionController The section controller making the request
 *  @param animated          YES if the section controller wants the pop animated
 */
- (void)sectionController:(SDTableViewSectionController *)sectionController popViewController: (BOOL)animated;

/**
 *  A section controller is asking you to pop to the root view controller
 *
 *  @param sectionController The section controller making the request
 *  @param animated          YES if the section controller wants the pop animated
 */
- (void)sectionController:(SDTableViewSectionController *)sectionController popToRootViewControllerAnimated:(BOOL)animated;
@end

//________________________________________________________________________________________
// This protocol declares the data and delegate interface for section controllers

@protocol SDTableViewSectionDelegate <NSObject>

// "DataSource" methods
@required

/**
 *  Your section must return a unique identifier per instance
 */
@property (nonatomic, copy, readonly) NSString *identifier;

- (NSInteger)numberOfRowsForSectionController:(SDTableViewSectionController *)sectionController;
- (UITableViewCell *)sectionController:(SDTableViewSectionController *)sectionController cellForRow:(NSInteger)row;

@optional

/**
 *  Return a title for the header for this section
 *
 *  @param sectionController The section controller making the request
 *
 *  @return a title for the header for this section
 */
- (NSString *)sectionControllerTitleForHeader:(SDTableViewSectionController *)sectionController;

/**
 *  Return a view for the header for this section
 *
 *  @param sectionController The section controller making the request
 *
 *  @return a view for the header for this section
 */
- (UIView *)sectionControllerViewForHeader:(SDTableViewSectionController *)sectionController;

- (CGFloat)sectionControllerHeightForHeader:(SDTableViewSectionController *)sectionController;

// "Delegate" methods
@optional
- (void)sectionController:(SDTableViewSectionController *)sectionController didSelectRow:(NSInteger)row;

@optional
// Variable height support
// Required for now because of the current design
- (CGFloat)sectionController:(SDTableViewSectionController *)sectionController heightForRow:(NSInteger)row;

@optional
// Editing support
- (UITableViewCellEditingStyle)sectionController:(SDTableViewSectionController *)sectionController editingStyleForRow:(NSInteger)row;
- (void)sectionController:(SDTableViewSectionController *)sectionController commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRow:(NSInteger)row;
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

/**
 *  Asks the section controller's delegate to dismiss the currently pushed view controller.  Use this method
 *  instead of trying to present it yourself
 *
 *  @param animated YES if should be animated
 */
- (void)popViewControllerAnimated:(BOOL)animated;

/**
 *  Asks the section controller's delegate to pop to the root view controller.  Use this method
 *  instead of trying to present it yourself
 *
 *  @param animated YES if should be animated
 */
- (void)popToRootViewControllerAnimated:(BOOL)animated;

/**
 *  Returns the height of all sections above the given section
 *
 *  @param section   Calculate the height of sections above this section
 *  @param maxHeight Maximum height to calculate. Pass SECTIONCONTROLLER_MAX_HEIGHT to calculate the total height of all sections above this section
 *
 *  @return <#return value description#>
 */
- (CGFloat)heightAboveSection:(id<SDTableViewSectionDelegate>)section maxHeight:(CGFloat)maxHeight;

/**
 *  Returns the height of all sections below the given section
 *
 *  @param section   Calculate the height of sections below this section
 *  @param maxHeight Maximum height to calculate. Pass SECTIONCONTROLLER_MAX_HEIGHT to calculate the total height of all sections below this section
 *
 *  @return <#return value description#>
 */
- (CGFloat)heightBelowSection:(id<SDTableViewSectionDelegate>)section maxHeight:(CGFloat)maxHeight;

@end

