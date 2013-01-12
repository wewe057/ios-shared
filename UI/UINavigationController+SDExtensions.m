//
//  UINavigationController+SDExtensions.m
//  samsclub
//
//  Created by Sam Grover on 1/10/13.
//  Copyright (c) 2013 Walmart. All rights reserved.
//

#import "UINavigationController+SDExtensions.h"

@implementation UINavigationController (SDExtensions)

- (NSArray *)popViewControllerByLevels:(NSUInteger)numLevels animated:(BOOL)animated
{
    NSArray *viewControllersOnStack = self.viewControllers;
    NSUInteger theCount = viewControllersOnStack.count;
    NSUInteger currentLevel = (theCount > 0) ? (theCount - 1) : 0;
    
    if (numLevels == currentLevel) {
        return [self popToRootViewControllerAnimated:animated];
    }
    
    NSUInteger indexToPopTo = viewControllersOnStack.count - numLevels;
    return [self popToViewController:[viewControllersOnStack objectAtIndex:indexToPopTo] animated:animated];
}

@end
