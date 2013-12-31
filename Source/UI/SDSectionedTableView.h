//
//  SDSectionedTableView.h
//  walmart
//
//  Created by Steve Riggins on 12/31/13.
//  Copyright (c) 2013 Walmart. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDSectionedTableView : UITableView

@end

@protocol SDSectionControllerProtocol <NSObject>
@required
- (UITableViewCell *)cellForIndexPath:(NSIndexPath *)indexPath;
- (void)didSelectCellAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (NSString *)sectionHeaderTitle;
- (UIView *)sectionHeaderView;
@end
