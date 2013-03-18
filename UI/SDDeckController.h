//
//  SDDeckController.h
//
//  Created by Brandon Sneed on 1/18/12.
//  Copyright (c) 2012 SetDirection. All rights reserved.
//
//  Based on JASidePanels by Jesse Andersen.

/*
 Copyright (c) 2012 Jesse Andersen. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do
 so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 If you happen to meet one of the copyright holders in a bar you are obligated
 to buy them one pint of beer.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#import <UIKit/UIKit.h>

@interface UIView (SDDeckController)
// allows gesture activation to be overridden for things like tableviews.
- (BOOL)isEditable;
@end



typedef enum _WMDeckStyle {
    WMDeckSingleActive = 0,
    WMDeckMultipleActive
} WMDeckStyle;

typedef enum _WMDeckState {
    WMDeckCenterVisible = 1,
    WMDeckLeftVisible,
    WMDeckRightVisible
} WMDeckState;

@interface SDDeckController : UIViewController<UIGestureRecognizerDelegate>

#pragma mark - Usage

// set the Decks
@property (nonatomic, strong) UIViewController *leftDeck;   // optional
@property (nonatomic, strong) UIViewController *centerDeck; // required
@property (nonatomic, strong) UIViewController *rightDeck;  // optional

// show the Decks
- (void)showLeftDeck:(BOOL)animated;
- (void)showRightDeck:(BOOL)animated;
- (void)showRightDeck:(BOOL)animated completion:(void (^)(BOOL finished))completion;
- (void)showCenterDeck:(BOOL)animated;

// toggle them opened/closed
- (void)toggleLeftDeck:(id)sender;
- (void)toggleRightDeck:(id)sender;

// Calling this while the left or right Deck is visible causes the center Deck to be completely hidden
- (void)setCenterDeckHidden:(BOOL)centerDeckHidden animated:(BOOL)animated duration:(NSTimeInterval) duration;

#pragma mark - Look & Feel

// style
@property (nonatomic) WMDeckStyle style; // default is WMDeckSingleActive

// size the left Deck based on % of total screen width
@property (nonatomic) CGFloat leftGapPercentage; 

// size the left Deck based on this fixed size. overrides leftGapPercentage
@property (nonatomic) CGFloat leftFixedWidth;

// the visible width of the left Deck
@property (nonatomic, readonly) CGFloat leftVisibleWidth;

// size the right Deck based on % of total screen width
@property (nonatomic) CGFloat rightGapPercentage;

// size the right Deck based on this fixed size. overrides rightGapPercentage
@property (nonatomic) CGFloat rightFixedWidth;

// the visible width of the right Deck
@property (nonatomic, readonly) CGFloat rightVisibleWidth;

// by default applies a black shadow to the container. override in sublcass to change
- (void)styleContainer:(UIView *)container animate:(BOOL)animate duration:(NSTimeInterval)duration;

// by default applies rounded corners to the Deck. override in sublcass to change
- (void)styleDeck:(UIView *)Deck;

#pragma mark - Animation

// the minimum % of total screen width the centerDeck.view must move for panGesture to succeed
@property (nonatomic) CGFloat minimumMovePercentage;

// the maximum time Deck opening/closing should take. Actual time may be less if panGesture has already moved the view.
@property (nonatomic) CGFloat maximumAnimationDuration;

// how long the bounce animation should take
@property (nonatomic) CGFloat bounceDuration;

// how far the view should bounce
@property (nonatomic) CGFloat bouncePercentage;

// should the center Deck bounce when you are panning open a left/right Deck.
@property (nonatomic) BOOL bounceOnSideDeckOpen; // defaults to YES

// should the center Deck bounce when you are panning closed a left/right Deck.
@property (nonatomic) BOOL bounceOnSideDeckClose; // defaults to NO

#pragma mark - Gesture Behavior

// Determines whether the pan gesture is limited to the top ViewController in a UINavigationController/UITabBarController
@property (nonatomic) BOOL panningLimitedToTopViewController; // default is YES

// Determines whether showing Decks can be controlled through pan gestures, or only through buttons
@property (nonatomic) BOOL recognizesPanGesture; // default is YES

#pragma mark - Menu Buttons

// Gives you an image to use for your menu button. The image is three stacked white lines, similar to Path 2.0 or Facebook's menu button.
+ (UIImage *)defaultImage;

// Default button to place in gestureViewControllers top viewController. Override in sublcass to change look of default button
- (UIBarButtonItem *)leftButtonForCenterDeck;

#pragma mark - Nuts & Bolts

// Current state of Decks. Use KVO to monitor state changes
@property (nonatomic, readonly) WMDeckState state;

// Whether or not the center Deck is completely hidden
@property (nonatomic, assign) BOOL centerDeckHidden;

// The currently visible Deck
@property (nonatomic, weak, readonly) UIViewController *visibleDeck;

// If set to yes, "shouldAutorotateToInterfaceOrientation:" will be passed to self.visibleDeck instead of handled directly
@property (nonatomic, assign) BOOL shouldDelegateAutorotateToVisibleDeck; // defaults to YES

// Determines whether or not the Deck's views are removed when not visble. If YES, rightDeck & leftDeck's views are eligible for viewDidUnload
@property (nonatomic, assign) BOOL canUnloadRightDeck; // defaults to NO
@property (nonatomic, assign) BOOL canUnloadLeftDeck;  // defaults to NO

// Determines whether or not the Deck's views should be resized when they are displayed. If yes, the views will be resized to their visible width
@property (nonatomic, assign) BOOL shouldResizeRightDeck; // defaults to YES
@property (nonatomic, assign) BOOL shouldResizeLeftDeck;  // defaults to YES

// Determines whether or not the center Deck can be panned beyound the the visible area of the side Decks
@property (nonatomic, assign) BOOL allowRightOverpan; // defaults to YES
@property (nonatomic, assign) BOOL allowLeftOverpan;  // defaults to YES

// Containers for the Decks.
@property (nonatomic, strong, readonly) UIView *leftDeckContainer;
@property (nonatomic, strong, readonly) UIView *rightDeckContainer;
@property (nonatomic, strong, readonly) UIView *centerDeckContainer;

@end
