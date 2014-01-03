//
//  SDTableViewSectionController.m
//  walmart
//
//  Created by Steve Riggins & Woolie on 1/2/14.
//  Copyright (c) 2014 Walmart. All rights reserved.
//

#import "SDTableViewSectionController.h"

@interface SDTableViewSectionController () <UITableViewDataSource, UITableViewDelegate>
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
    id<SDTableViewSectionProtocol>sectionController = self.sectionControllers[section];
    if ([sectionController respondsToSelector:@selector(numberOfRowsForSectionController:)])
    {
        return [sectionController numberOfRowsForSectionController:self];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    id<SDTableViewSectionProtocol>sectionController = self.sectionControllers[section];
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
    @strongify(self.dataSource, dataSource);
    if (tableView == self.tableView)
    {
        if ([dataSource conformsToProtocol:@protocol(SDTableViewSectionControllerDataSource)])
        {
            self.sectionControllers = [dataSource controllersForTableView:tableView];
            NSInteger sectionCount = self.sectionControllers.count;
            return sectionCount;
        }
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id<SDTableViewSectionProtocol>sectionController = self.sectionControllers[section];
    if ([sectionController respondsToSelector:@selector(sectionControllerTitleForHeader:)])
    {
        return [sectionController sectionControllerTitleForHeader:self];
    }
    
    return nil;
}



#pragma mark - UITableView Delegate


@end
