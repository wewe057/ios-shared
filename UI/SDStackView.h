//
//  SDStackView.h
//  SDStackViewTest
//
//  Created by Joel Bernstein on 7/18/12.
//  Copyright (c) 2012 Walmart. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDStackView : UIScrollView

@property (nonatomic, copy) NSArray* stackItemViews;
@property (nonatomic, assign) UIEdgeInsets touchInset;

@end
