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

@protocol SDTableViewSectionControllerDataSource <NSObject>

@required

/**
 *  Return the array of controllers for the sections of the given table view
 *
 *  @param tableView The table view the controller needs controllers for
 *
 *  @return An array of objects that conform to SDTableViewSectionProtocol
 */
- (NSArray *)controllersForTableView:(UITableView *)tableView;
@end

//________________________________________________________________________________________
// This protocol declares the data and delegate interface for section controllers

@protocol SDTableViewSectionProtocol <NSObject>

@required

- (NSInteger)numberOfRowsForSectionController:(SDTableViewSectionController *)sectionController;
- (UITableViewCell *)sectionController:(SDTableViewSectionController *)sectionController cellForRow:(NSInteger)row;

@optional

- (NSString *)sectionControllerTitleForHeader:(SDTableViewSectionController *)sectionController;
@end

//__________________________________________________________________________
// This class manages sections and sending messages to its
// sectionDataSource and sectionDelegate

@interface SDTableViewSectionController : NSObject

- (instancetype) initWithTableView:(UITableView *)tableView;

@property (nonatomic, weak)             id <SDTableViewSectionControllerDataSource>  dataSource;
@property (nonatomic, weak, readonly)   UITableView                                 *tableView;

/**
 *  Array of objects conforming to SDTableViewSectionProtocol
 */
@property (nonatomic, strong, readonly) NSArray                                     *sectionControllers;

@end

