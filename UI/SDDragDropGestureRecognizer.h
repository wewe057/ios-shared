//
//  SDDragDropGestureRecognizer.h
//  testdrag
//
//  Created by Brandon Sneed on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SDDragViewDelegate <NSObject>
@optional
- (BOOL)dragViewShouldReturnToOriginalContainer:(UIView *)view;
- (void)dragView:(UIView *)view didEnterTarget:(UIView *)dropTarget;
- (void)dragView:(UIView *)view didLeaveTarget:(UIView *)dropTarget;
@end


@interface SDDragDropGestureRecognizer : UILongPressGestureRecognizer
{
    UIView *originalSuperview;
    CGRect originalFrame;
    CGPoint originalCenterInContainer;
    CGPoint touchOffset;
    UIView *currentDropTarget;
}

@property (nonatomic, assign) UIView *dragView;
@property (nonatomic, readonly) UIView *currentDropTarget;
@property (nonatomic, assign) id<SDDragViewDelegate> dragViewDelegate;

@end
