//
//  SDTableViewSectionController.m
//  walmart
//
//  Created by Steve Riggins & Woolie on 1/2/14.
//  Copyright (c) 2014 Walmart. All rights reserved.
//

#import "SDTableViewSectionController.h"

@interface SDTableViewSectionController () <UITableViewDataSource, UITableViewDelegate>
{
    // Private flags
    BOOL _sectionsImplementHeightForRow;
    BOOL _sectionsImplementTitleForHeader;
    BOOL _sectionsImplementViewForHeader;
}

@property (nonatomic, weak)   UITableView *tableView;
@property (nonatomic, strong) NSArray     *sectionControllers;
@end

@implementation SDTableViewSectionController

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    if (self)
    {
        _tableView = tableView;
        tableView.delegate = self;
        tableView.dataSource = self;
    }
    
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<SDTableViewSectionDelegate>sectionController = self.sectionControllers[(NSUInteger)section];
    if ([sectionController respondsToSelector:@selector(numberOfRowsForSectionController:)])
    {
        return [sectionController numberOfRowsForSectionController:self];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = (NSUInteger)indexPath.section;
    NSInteger row = indexPath.row;
    id<SDTableViewSectionDelegate>sectionController = self.sectionControllers[section];
    if ([sectionController respondsToSelector:@selector(sectionController:cellForRow:)])
    {
        UITableViewCell *cell = [sectionController sectionController:self cellForRow:row];
        return cell;
    }
    return nil;
}

// This is where we hook to ask our dataSource for the Array of controllers
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    @strongify(self.delegate, delegate);
    @strongify(self.tableView, strongTableView);
    if (tableView == strongTableView)
    {
        if ([delegate conformsToProtocol:@protocol(SDTableViewSectionControllerDelegate)])
        {
            self.sectionControllers = [delegate controllersForTableView:tableView];
            
            // Force caching of our flags and the table view's flags
            [self p_updateFlags];
            strongTableView.delegate = nil;
            strongTableView.dataSource = nil;
            strongTableView.delegate = self;
            strongTableView.dataSource = self;
            
            NSInteger sectionCount = (NSInteger)self.sectionControllers.count;
            return sectionCount;
        }
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id<SDTableViewSectionDelegate>sectionController = self.sectionControllers[(NSUInteger)section];
    if ([sectionController respondsToSelector:@selector(sectionControllerTitleForHeader:)])
    {
        return [sectionController sectionControllerTitleForHeader:self];
    }
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *result;
    id<SDTableViewSectionDelegate>sectionController = self.sectionControllers[section];
    if ([sectionController respondsToSelector:@selector(sectionControllerViewForHeader:)])
    {
        return [sectionController sectionControllerViewForHeader:self];
    }    
    return result;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    id<SDTableViewSectionDelegate>sectionController = self.sectionControllers[(NSUInteger)section];
    if ([sectionController respondsToSelector:@selector(sectionController:didSelectRow:)])
    {
        [sectionController sectionController:self didSelectRow:row];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    id<SDTableViewSectionDelegate>sectionController = self.sectionControllers[(NSUInteger)section];
    if ([sectionController respondsToSelector:@selector(sectionController:heightForRow:)])
    {
        return [sectionController sectionController:self heightForRow:row];
    }
    return 44; // Some default size so engineer sees a broken cell
}

#pragma mark - SectionController Methods

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    @strongify(self.delegate, delegate);
    if ([delegate conformsToProtocol:@protocol(SDTableViewSectionControllerDelegate)])
    {
        [delegate sectionController:self pushViewController:viewController animated:animated];
    }
}

- (void)presentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion
{
    @strongify(self.delegate, delegate);
    if ([delegate respondsToSelector:@selector(sectionController:presentViewController:animated:completion:)])
    {
        [delegate sectionController:self presentViewController:viewController animated:animated completion:completion];
    }
}

- (void)dismissViewControllerAnimated: (BOOL)animated completion: (void (^)(void))completion
{
    @strongify(self.delegate, delegate);
    if ([delegate respondsToSelector:@selector(sectionController:dismissViewControllerAnimated:completion:)])
    {
        [delegate sectionController:self dismissViewControllerAnimated:animated completion:completion];
    }
}

- (void)popViewControllerAnimated:(BOOL)animated
{
    @strongify(self.delegate, delegate);
    if ([delegate respondsToSelector:@selector(sectionController:popViewController:)])
    {
        [delegate sectionController:self popViewController:animated];
    }   
}

- (void)popToRootViewControllerAnimated:(BOOL)animated
{
    @strongify(self.delegate, delegate);
    if ([delegate respondsToSelector:@selector(sectionController:popToRootViewControllerAnimated:)])
    {
        [delegate sectionController:self popToRootViewControllerAnimated:animated];
    }
}

#pragma mark Private methods

- (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL result;
    if (aSelector == @selector(tableView:heightForRowAtIndexPath:))
    {
        result = _sectionsImplementHeightForRow;
    } else if (aSelector == @selector(tableView:titleForHeaderInSection:))
    {
        result = _sectionsImplementTitleForHeader;
    } else if (aSelector == @selector(tableView:viewForHeaderInSection:))
    {
        result = _sectionsImplementViewForHeader;
    }
    else
    {
        result = [super respondsToSelector:aSelector];
    }
    return result;
}


- (void)p_updateFlags
{
    _sectionsImplementHeightForRow = NO;
    _sectionsImplementTitleForHeader = NO;
    _sectionsImplementViewForHeader = NO;
    for (NSUInteger controllerIndex = 0; controllerIndex < self.sectionControllers.count; controllerIndex++)
    {
        id<SDTableViewSectionDelegate>sectionController = self.sectionControllers[controllerIndex];
        
        // OR (option) delegate methods
        // We need to handle this delegate if ANY of the sections implement these delegate methods
        _sectionsImplementTitleForHeader |= [sectionController respondsToSelector:@selector(sectionControllerTitleForHeader:)];
        _sectionsImplementViewForHeader |= [sectionController respondsToSelector:@selector(sectionControllerViewForHeader:)];
        
        // AND delegate methods
        // If one of the sections implements these delegate methods, then all must
        BOOL sectionsImplementHeightForRow = [sectionController respondsToSelector:@selector(sectionController:heightForRow:)];
        if (controllerIndex == 0)
        {
            _sectionsImplementHeightForRow = sectionsImplementHeightForRow;
        }
        else
        {
            NSAssert(_sectionsImplementHeightForRow == sectionsImplementHeightForRow, @"If one section implements sectionController:heightForRow:, then all sections must");
        }
    }
}

@end
