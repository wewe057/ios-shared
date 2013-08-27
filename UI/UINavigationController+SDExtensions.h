//
//  UINavigationController+SDExtensions.h
//  samsclub
//
//  Created by Sam Grover on 1/10/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
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

/**
 Pops to the root VC and dismisses a modal if the top-most VC is currently 
 displaying one.  This stops a VC stack from being popped out from underneath
 a modal VC.  
 
 Note: Ideally we'd dismiss the modalVC in the presenting VC's dealloc.  However
 it appears that the modalViewController property on the presenting VC has been
 niled out by the time dealloc hits.
 
 @param animated Set to `YES` to animate the transition.
 @return An array of the view controllers popped.
 */
- (NSArray *)popToRootViewControllerDismissingModalAnimated:(BOOL)animated;

@end
