//
//  UIViewController+SDExtensions.h
//  Photos
//
//  Created by Brandon Sneed on 5/16/13.
//  Copyright (c) 2013 walmart. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (SDExtensions)

+ (id)instanceInNavigationController;
+ (id)instanceInNavigationControllerWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle;
- (UINavigationController *)wrapInstanceInNavigationController;

@end
