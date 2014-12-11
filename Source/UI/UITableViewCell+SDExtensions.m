//
//  UITableViewCell+SDExtensions.m
//  walmart
//
//  Created by Cody Garvin on 10/17/14.
//  Copyright (c) 2014 Walmart. All rights reserved.
//

#import "UITableViewCell+SDExtensions.h"

@implementation UITableViewCell (SDExtensions)

- (CGFloat)calculatedHeightForCellInTableview:(UITableView *)tableview
                              separatorHeight:(CGFloat)separatorHeight
{
    // Set the temporary sizing bounds so that we can use systemLayoutSizeFittingSize:
    // Note the contentView width is used. This helps with cells that could have a
    // manipulated contentView width or have an accessory view. If this isn't accounted
    // for than multi-line labels could be incorrectly calculated since the entire
    // width of the cell would be used during the calculation.
    self.bounds = CGRectMake(0.0f, 0.0f, self.contentView.size.width, CGRectGetHeight(tableview.bounds));
//    self.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableview.bounds), CGRectGetHeight(tableview.bounds));
//    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    CGFloat cellHeight;
    if ([UIDevice systemMajorVersion] >= 8.0)
    {
        CGSize tempSize = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize
                              withHorizontalFittingPriority:UILayoutPriorityDefaultHigh
                                    verticalFittingPriority:UILayoutPriorityFittingSizeLevel];
        cellHeight = (tempSize.height + separatorHeight);
    }
    else
    {
        cellHeight = ([self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + separatorHeight);
    }
    
    return cellHeight;
}

@end
