//
//  UINavigationController+SDExtensions.h
//  samsclub
//
//  Created by Sam Grover on 1/10/13.
//  Copyright (c) 2013 Walmart. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (SDExtensions)

/**
 Pops the navigation stack by a number of levels.
 @param numLevels The number of levels to pop up.
 @param animated Set to `YES` to animate the transition.
 @return An array of the view controllers popped.
 */
- (NSArray *)popViewControllerByLevels:(NSUInteger)numLevels animated:(BOOL)animated;

@end
