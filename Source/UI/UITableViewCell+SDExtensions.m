//
//  UITableViewCell+SDExtensions.m
//  walmart
//
//  Created by Cody Garvin on 10/17/14.
//  Copyright (c) 2014 Walmart. All rights reserved.
//

#import "UITableViewCell+SDExtensions.h"

@implementation UITableViewCell (SDExtensions)

- (CGFloat)calculatedHeightForMultilineCellInTableview:(UITableView *)tableview
{
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    self.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableview.bounds), CGRectGetHeight(tableview.bounds));
    
    CGFloat cellHeight;
    if ([UIDevice systemMajorVersion] >= 8.0)
    {
        cellHeight = ([self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize
                                withHorizontalFittingPriority:UILayoutPriorityDefaultHigh
                                      verticalFittingPriority:UILayoutPriorityFittingSizeLevel].height +
                      [WalmartStyler tableViewCellSeparatorHeight]);
    }
    else
    {
        cellHeight = ([self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height +
                      [WalmartStyler tableViewCellSeparatorHeight]);
    }

    return cellHeight;
}

@end
