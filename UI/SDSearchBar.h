//
//  SDSearchBar.h
//  walmart
//
//  Created by brandon on 2/23/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SDSearchBar : UISearchBar
{
	UIViewController *controller;
	UIView *obscuringView;
	BOOL isActive;
}

@property (nonatomic, assign) BOOL active;
@property (nonatomic, retain) IBOutlet UIViewController *controller;
@property (nonatomic, readonly) UIView *obscuringView;

- (void)setActive:(BOOL)active animated:(BOOL)animated;

@end
