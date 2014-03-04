//
//  SDPullNavigationBar.m
//  ios-shared
//
//  Created by Brandon Sneed on 08/06/2013.
//  Copyright 2013-2014 SetDirection. All rights reserved.
//

#import "SDPullNavigationBar.h"

#import "SDPullNavigationBarAdornmentView.h"
#import "SDPullNavigationBarBackground.h"
#import "SDPullNavigationBarTabButton.h"
#import "SDPullNavigationManager.h"
#import "UIDevice+machine.h"
#import "UIColor+SDExtensions.h"

static const CGFloat kDefaultMenuWidth = 320.0f;
static const CGFloat kDefaultMenuHeightBuffer = 44.0f;  // Keeps the bottom of the menu from getting too close to the bottom of the screen

typedef NS_ENUM(NSInteger, SDPullNavigationViewTag)
{
    SDPullNavigationNavBarBackgroundViewTag  = 1,
    SDPullNavigationTabButtonViewTag         = 2,
    SDPullNavigationMenuContainerViewTag     = 3,
    SDPullNavigationClientViewTag            = 4,
    SDPullNavigationBackgroundEffectsViewTag = 5,
    SDPullNavigationAdornmentView            = 6
};

typedef struct
{
    CGPoint initialTouchPoint;
    CGPoint currentTouchPoint;
    CGFloat maxMenuHeight;
    CGFloat minMenuHeight;
    CGFloat velocity;
    BOOL    isInteracting;
} SDMenuControllerInteractionFlags;

@interface SDPullNavigationMenuContainer : UIView   // This custom class used for debugging purposes.
@end

#pragma mark - SDPullNavigationBar

@interface SDPullNavigationBar()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) SDPullNavigationBarBackground* navbarBackgroundView;
@property (nonatomic, strong) SDPullNavigationBarTabButton* tabButton;
@property (nonatomic, strong) SDPullNavigationMenuContainer* menuContainer;
@property (nonatomic, strong) UIView* backgroundEffectsView;
@property (nonatomic, strong) SDPullNavigationBarAdornmentView* menuBottomAdornmentView;
@property (nonatomic, assign) CGFloat menuAdornmentImageOverlapHeight;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) BOOL menuOpen;
@property (nonatomic, assign) CGFloat menuWidthForPortrait;
@property (nonatomic, assign) CGFloat menuWidthForLandscape;
@property (nonatomic, assign) CGFloat menuWidthForCurrentOrientation;
@property (nonatomic, strong, readwrite) UIPanGestureRecognizer* revealPanGestureRecognizer;
@property (nonatomic, strong, readwrite) UIPanGestureRecognizer* dismissPanGestureRecognizer;
@property (nonatomic, assign, readwrite) SDMenuControllerInteractionFlags menuInteraction;
@property (nonatomic, strong) UIImage* menuAdornmentImage;
@property (nonatomic, assign) BOOL showAdornment;

@property (nonatomic, assign) BOOL implementsWillAppear;
@property (nonatomic, assign) BOOL implementsDidAppear;
@property (nonatomic, assign) BOOL implementsWillDisappear;
@property (nonatomic, assign) BOOL implementsDidDisappear;

@property (nonatomic, assign) BOOL implementsMenuWidth;
@property (nonatomic, assign) BOOL implementsMenuWidthForOrientations;

@property (nonatomic, assign) BOOL implementsMenuAdornmentImage;
@property (nonatomic, assign) BOOL implementsMenuAdornmentImageWith3PartImage;

@end

@implementation SDPullNavigationBar

+ (void)setupDefaults
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];

    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-9999, -9999) forBarMetrics:UIBarMetricsDefault];

    SDPullNavigationBar* pullBarAppearance = [SDPullNavigationBar appearance];
    if ([UIDevice bcdSystemVersion] >= 0x070000)
    {
        pullBarAppearance.barTintColor = [UIColor colorWith8BitRed:29 green:106 blue:166 alpha:1.0f];
        pullBarAppearance.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
        pullBarAppearance.tintColor = [UIColor whiteColor];
    }
    else
    {
        pullBarAppearance.tintColor = [UIColor colorWith8BitRed:23 green:108 blue:172 alpha:1.0];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self != nil)
    {
        self.translucent = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(statusBarWillChangeRotationNotification:)
                                                     name:UIApplicationWillChangeStatusBarOrientationNotification
                                                   object:nil];
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Superview is known, start setting up our subviews.
- (void)willMoveToSuperview:(UIView*)newSuperview
{
    if(newSuperview)
    {
        self.menuAdornmentImage = [SDPullNavigationManager sharedInstance].menuAdornmentImage;
        if([UIDevice iPad] && self.menuAdornmentImage)
            self.showAdornment = YES;

        // I tagged all of the view to be able to find them quickly when I am viewing the hierarchy in Spark Inspector or Reveal.

        // This is a navBar overlay which we can use to change navBar visuals.
        {
            self.navbarBackgroundView = [[SDPullNavigationBarBackground alloc] init];
            self.navbarBackgroundView.autoresizesSubviews = YES;
            self.navbarBackgroundView.userInteractionEnabled = NO;
            self.navbarBackgroundView.opaque = NO;
            self.navbarBackgroundView.backgroundColor = [UIColor clearColor];
            self.navbarBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            self.navbarBackgroundView.delegate = (id<SDPullNavigationBarOverlayProtocol>)self;
            self.navbarBackgroundView.frame = self.bounds;
            self.navbarBackgroundView.tag = SDPullNavigationNavBarBackgroundViewTag;
        }

        // This is the hit area for showing the pulldown menu, as well as the area (at the bottom) where the nipple is shown.
        {
            Class tabBarButtonClass = [SDPullNavigationBarTabButton class];
            if([SDPullNavigationManager sharedInstance].pullNavigationBarTabButtonClass)
                tabBarButtonClass = [SDPullNavigationManager sharedInstance].pullNavigationBarTabButtonClass;

            self.tabButton = [[tabBarButtonClass alloc] initWithNavigationBar:self];
            self.tabButton.tag = SDPullNavigationTabButtonViewTag;

            NSAssert([self.tabButton isKindOfClass:[SDPullNavigationBarTabButton class]], @"TabBarButton class must be derived from SDPullNavigationBarTabButton");
        }

        // The view that the client's menu lives in.
        {
            self.menuContainer = [[SDPullNavigationMenuContainer alloc] initWithFrame:newSuperview.bounds];
            self.menuContainer.clipsToBounds = YES;
            self.menuContainer.backgroundColor = [UIColor clearColor];
            self.menuContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            self.menuContainer.translatesAutoresizingMaskIntoConstraints = YES;
            self.menuContainer.opaque = NO;
            self.menuContainer.hidden = NO;

            self.menuContainer.layer.shadowColor = [UIColor blackColor].CGColor;
            self.menuContainer.layer.shadowOffset = (CGSize){ 0.0f, -3.0f };
            self.menuContainer.layer.shadowRadius = 3.0f;
            self.menuContainer.layer.shadowOpacity = 1.0;
            self.menuContainer.tag = SDPullNavigationMenuContainerViewTag;
        }

        // This is the client's controller for the menu.
        {
            UIStoryboard* menuStoryBoard = [UIStoryboard storyboardWithName:[SDPullNavigationManager sharedInstance].globalMenuStoryboardId bundle:nil];
            self.menuController = [menuStoryBoard instantiateInitialViewController];
            [self setupProtocolHelpers];

            CGFloat menuHeight = MIN(self.menuController.pullNavigationMenuHeight, self.availableHeight);
            self.menuController.view.frame = (CGRect){ CGPointZero, { self.menuWidthForCurrentOrientation, menuHeight } };

            self.menuController.view.clipsToBounds = YES;
            self.menuController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            self.menuController.view.translatesAutoresizingMaskIntoConstraints = YES;
            self.menuController.view.tag = SDPullNavigationClientViewTag;

            self.menuController.pullNavigationBarDelegate = self;
        }

        // View that darkens the views behind and to the side of the menu.
        {
            self.backgroundEffectsView = [[UIView alloc] initWithFrame:self.menuContainer.bounds];
            self.backgroundEffectsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            self.backgroundEffectsView.clipsToBounds = YES;
            self.backgroundEffectsView.backgroundColor = [UIColor clearColor];
            self.backgroundEffectsView.opaque = NO;
            self.backgroundEffectsView.tag = SDPullNavigationBackgroundEffectsViewTag;
        }

        // The adornmentView should be the exact same size as the menuController's view, except for the area that hangs down below.
        // It should also be the menu controller's superview. That way we just animate the adornment view instead of both.
        // This is the little nubbin' at the bottom of the menu. Don't show this on iPhone, don't show this if client has not set the image.

        {
            self.menuAdornmentImageOverlapHeight = [SDPullNavigationManager sharedInstance].menuAdornmentImageOverlapHeight;

            CGFloat menuHeight = MIN(self.menuController.pullNavigationMenuHeight, self.availableHeight);
            CGRect frame = (CGRect){ { newSuperview.frame.size.width * 0.5f - self.menuWidthForCurrentOrientation * 0.5f, -(menuHeight - self.navigationBarHeight) },
                                     { self.menuWidthForCurrentOrientation, menuHeight } };

            self.menuBottomAdornmentView = [[SDPullNavigationBarAdornmentView alloc] initWithFrame:frame];
            if(self.showAdornment)
                self.menuBottomAdornmentView.adornmentImage = self.menuAdornmentImage;
            self.menuBottomAdornmentView.tag = SDPullNavigationAdornmentView;
        }

        [self insertSubview:self.navbarBackgroundView atIndex:1];
        [self addSubview:self.tabButton];
        [self.menuBottomAdornmentView addSubview:self.menuController.view];
        [self.menuContainer addSubview:self.backgroundEffectsView];
        [self.menuContainer addSubview:self.menuBottomAdornmentView];
        [newSuperview insertSubview:self.menuContainer belowSubview:self];

        [self setupGestureRecognizers];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat tabOffset = 8.0f;

    CGPoint navBarCenter = self.center;
    CGRect tabFrame = self.tabButton.frame;
    tabFrame.origin.x = (navBarCenter.x - (tabFrame.size.width * 0.5f));
    tabFrame.origin.y = self.bounds.size.height - (tabFrame.size.height - tabOffset);
    self.tabButton.frame = CGRectIntegral(tabFrame);
    
    [self addSubview:self.tabButton];
}

- (void)centerViewsToOrientation
{
    CGFloat menuHeight = MIN(self.menuController.pullNavigationMenuHeight, self.availableHeight);
    self.menuBottomAdornmentView.frame = (CGRect){ { self.superview.frame.size.width * 0.5f - self.menuWidthForCurrentOrientation * 0.5f, -(menuHeight - self.navigationBarHeight) },
                                                   { self.menuWidthForCurrentOrientation, menuHeight } };
    [self.menuBottomAdornmentView setNeedsLayout];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.navbarBackgroundView.frame = self.bounds;
}

- (void)setupGestureRecognizers
{
    UITapGestureRecognizer* openTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.tabButton addGestureRecognizer:openTapGesture];

    self.revealPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeRevealPanGesture:)];
    self.revealPanGestureRecognizer.maximumNumberOfTouches = 1;
    [self.tabButton addGestureRecognizer:self.revealPanGestureRecognizer];

    self.dismissPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeDismissPanGesture:)];
    self.revealPanGestureRecognizer.maximumNumberOfTouches = 1;
    [self.menuBottomAdornmentView addGestureRecognizer:self.dismissPanGestureRecognizer];

    UITapGestureRecognizer* dismissTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTapAction:)];
    dismissTapGesture.delegate = self;
    [self.menuContainer addGestureRecognizer:dismissTapGesture];
}

- (void)tapAction:(id)sender
{
    [self togglePullMenuWithCompletionBlock:nil];
}

// Check to see if our menuController implements the @optional methods.
// Set up flags and default values based on this.

- (void)setupProtocolHelpers
{
    self.implementsMenuWidth = [self.menuController respondsToSelector:@selector(pullNavigationMenuWidth)];
    self.implementsMenuWidthForOrientations = [self.menuController respondsToSelector:@selector(pullNavigationMenuWidthForPortrait)] &&
    [self.menuController respondsToSelector:@selector(pullNavigationMenuWidthForLandscape)];
    if(self.implementsMenuWidthForOrientations)
        self.implementsMenuWidth = NO;
    
    self.menuWidthForPortrait = self.menuWidthForLandscape = kDefaultMenuWidth;
    if(self.implementsMenuWidth)
    {
        self.menuWidthForPortrait = self.menuController.pullNavigationMenuWidth;
    }
    else if(self.implementsMenuWidthForOrientations)
    {
        self.menuWidthForPortrait = self.menuController.pullNavigationMenuWidthForPortrait;
        self.menuWidthForLandscape = self.menuController.pullNavigationMenuWidthForLandscape;
    }

    self.implementsWillAppear = [self.menuController respondsToSelector:@selector(pullNavMenuWillAppear)];
    self.implementsDidAppear = [self.menuController respondsToSelector:@selector(pullNavMenuDidAppear)];
    self.implementsWillDisappear = [self.menuController respondsToSelector:@selector(pullNavMenuWillDisappear)];
    self.implementsDidDisappear = [self.menuController respondsToSelector:@selector(pullNavMenuDidDisappear)];
}

- (CGFloat)menuWidthForCurrentOrientation
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    return UIInterfaceOrientationIsPortrait(orientation) ? self.menuWidthForPortrait : self.menuWidthForLandscape;
}

#pragma mark - Gesture Handling

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch
{
    return ![touch.view isDescendantOfView:self.menuController.view];
}

- (void)dismissTapAction:(UITapGestureRecognizer*)sender
{
    if(self.menuOpen)
        [self dismissPullMenuWithCompletionBlock:nil];
}

- (void)didRecognizeRevealPanGesture:(UIPanGestureRecognizer*)recognizer
{
    switch(recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            [self centerViewsToOrientation];

            self.tabButton.tuckedTab = !self.menuOpen;
            [self.tabButton setNeedsDisplay];

            [self.superview insertSubview:self.menuContainer belowSubview:self];

            _menuInteraction.initialTouchPoint = [recognizer translationInView:self];
            _menuInteraction.isInteracting = YES;
            _menuInteraction.velocity = 0.0f;
            _menuInteraction.minMenuHeight = -(MIN(self.menuController.pullNavigationMenuHeight, self.availableHeight) - self.navigationBarHeight + self.menuAdornmentImageOverlapHeight);
            _menuInteraction.maxMenuHeight = self.navigationBarHeight;

            [recognizer setTranslation:CGPointZero inView:self];

            [self showMenuContainer];
            [self showBackgroundEffectWithAnimation:YES completion:nil];
            break;
        }

        case UIGestureRecognizerStateChanged:
        {
            _menuInteraction.currentTouchPoint = [recognizer translationInView:self];

            CGFloat newY = MIN(_menuInteraction.minMenuHeight + _menuInteraction.initialTouchPoint.y + _menuInteraction.currentTouchPoint.y, _menuInteraction.maxMenuHeight);
            self.menuBottomAdornmentView.frame = (CGRect){ { self.menuBottomAdornmentView.frame.origin.x, newY }, self.menuBottomAdornmentView.frame.size };
            break;
        }

        case UIGestureRecognizerStateEnded:
        {
            _menuInteraction.velocity = [recognizer velocityInView:self].y;

            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState animations:^
            {
                if(fabs(_menuInteraction.velocity) < 100.0f)
                {
                    // Slow drag

                    CGFloat panArea = _menuInteraction.maxMenuHeight - _menuInteraction.minMenuHeight;
                    if(_menuInteraction.velocity < 0.0f)
                    {
                        if(self.menuBottomAdornmentView.frame.origin.y < panArea * 0.66f)
                            [self expandMenu];
                        else
                            [self collapseMenu];
                    }
                    else
                    {
                        if(self.menuBottomAdornmentView.frame.origin.y < panArea * 0.33f)
                            [self expandMenu];
                        else
                            [self collapseMenu];
                    }
                }
                else
                {
                    // Fast drag

                    if(_menuInteraction.velocity < 0.0f)
                        [self collapseMenu];
                    else
                        [self expandMenu];
                }
            }
            completion:^(BOOL finished) {}];

            // Falling through on purpose...
        }

        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        default:
        {
            _menuInteraction.isInteracting = NO;
            break;
        }
    }
}

- (void)didRecognizeDismissPanGesture:(UIPanGestureRecognizer*)recognizer
{
    switch(recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            [self centerViewsToOrientation];
            
            _menuInteraction.initialTouchPoint = [recognizer translationInView:self];
            _menuInteraction.isInteracting = YES;
            _menuInteraction.velocity = 0.0f;
            _menuInteraction.minMenuHeight = self.navigationBarHeight;
            _menuInteraction.maxMenuHeight = -(MIN(self.menuController.pullNavigationMenuHeight, self.availableHeight) - (self.navigationBarHeight/* - self.menuAdornmentImageOverlapHeight*/));

            [recognizer setTranslation:CGPointZero inView:self];
            break;
        }
            
        case UIGestureRecognizerStateChanged:
        {
            _menuInteraction.currentTouchPoint = [recognizer translationInView:self];

            // Peg to the top value
            CGFloat newY = MAX(_menuInteraction.minMenuHeight - _menuInteraction.initialTouchPoint.y + _menuInteraction.currentTouchPoint.y, _menuInteraction.maxMenuHeight);

            // Peg to the bottom value.
            newY = MIN(newY, _menuInteraction.minMenuHeight);

            self.menuBottomAdornmentView.frame = (CGRect){ { self.menuBottomAdornmentView.frame.origin.x, newY }, self.menuBottomAdornmentView.frame.size };
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        {
            _menuInteraction.velocity = [recognizer velocityInView:self].y;

            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState animations:^
            {
                if(fabs(_menuInteraction.velocity) < 100.0f)
                {
                    // Slow drag
                    
                    CGFloat panArea = _menuInteraction.maxMenuHeight - _menuInteraction.minMenuHeight;
                    if(_menuInteraction.velocity < 0)
                    {
                        if(self.menuBottomAdornmentView.frame.origin.y < panArea * 0.66f)
                        {
                            [self collapseMenuWithCompletion:^{ [self hideMenuContainer]; }];
                        }
                        else
                        {
                            [self expandMenu];
                        }
                    }
                    else
                    {
                        if(self.menuBottomAdornmentView.frame.origin.y < panArea * 0.33f)
                        {
                            [self collapseMenuWithCompletion:^{ [self hideMenuContainer]; }];
                        }
                        else
                        {
                            [self expandMenu];
                        }
                    }
                }
                else
                {
                    // Fast drag
                    
                    if(_menuInteraction.velocity < 0)
                    {
                        [self collapseMenuWithCompletion:^{ [self hideMenuContainer]; }];
                    }
                    else
                    {
                        [self expandMenu];
                    }
                }
            }
            completion:^(BOOL finished)
            {
                if(self.menuOpen == NO)
                {
                    self.tabButton.tuckedTab = NO;
                    [self.tabButton setNeedsDisplay];
                }
            }];

            // Falling through on purpose...
        }
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        default:
        {
            _menuInteraction.isInteracting = NO;
            break;
        }
    }
}

#pragma mark - Helpers

- (void)togglePullMenuWithCompletionBlock:(void (^)(void))completion
{
    if(!self.animating)
    {
        self.animating = YES;

        [self.superview insertSubview:self.menuContainer belowSubview:self];
        [self showMenuContainer];

        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
        {
            if(self.menuOpen)
                [self collapseMenu];
            else
                [self expandMenu];
        }
        completion:^(BOOL finished)
        {
            self.animating = NO;

            [self.tabButton setNeedsDisplay];
            self.menuContainer.hidden = !self.menuOpen;

            if(completion)
                completion();
        }];
    }
    else
    {
        // Don't forget that if we did not need to dismiss the menu, then we should still call the completion block.
        if(completion)
            completion();
    }
}

- (void)expandMenu
{
    if(self.implementsWillAppear)
        [self.menuController pullNavMenuWillAppear];

    [self centerViewsToOrientation];

    [self showBackgroundEffectWithAnimation:NO completion:nil];

    self.tabButton.tuckedTab = YES;
    [self.tabButton setNeedsDisplay];   // During expand, hide the tab now

    self.menuBottomAdornmentView.frame = (CGRect){ { self.menuBottomAdornmentView.frame.origin.x, self.navigationBarHeight }, self.menuBottomAdornmentView.frame.size };

    self.menuOpen = YES;

    if(self.implementsDidAppear)
        [self.menuController pullNavMenuDidAppear];
}

- (void)collapseMenu
{
    if(self.implementsWillDisappear)
        [self.menuController pullNavMenuWillDisappear];

    [self collapseMenuWithCompletion:^
    {
        if(self.implementsDidDisappear)
            [self.menuController pullNavMenuDidDisappear];
    }];
}

- (void)collapseMenuWithCompletion:(void (^)(void))completion
{
    [self hideBackgroundEffectWithAnimation:!self.animating completion:completion];
    
    self.tabButton.tuckedTab = NO;  // During collapse, hide the tab at animation completion (hence no setNeedsDisplay).
    
    CGFloat menuPositionY = -(MIN(self.menuController.pullNavigationMenuHeight, self.availableHeight) - self.navigationBarHeight + self.menuAdornmentImageOverlapHeight);
    self.menuBottomAdornmentView.frame = (CGRect){ { self.menuBottomAdornmentView.frame.origin.x, menuPositionY }, self.menuBottomAdornmentView.frame.size };

    self.menuOpen = NO;
}

- (void)showMenuContainer
{
    self.menuContainer.hidden = NO;
}

- (void)hideMenuContainer
{
    self.menuContainer.hidden = YES;
}

- (void)showBackgroundEffectWithAnimation:(BOOL)animate completion:(void (^)(void))completion
{
    if(animate)
    {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
        {
            self.backgroundEffectsView.backgroundColor = [@"#00000033" uicolor];
        }
        completion:^(BOOL finished)
        {
            if(completion)
                completion();
        }];
    }
    else
    {
        self.backgroundEffectsView.backgroundColor = [@"#00000033" uicolor];
        if(completion)
            completion();
    }
}

- (void)hideBackgroundEffectWithAnimation:(BOOL)animate completion:(void (^)(void))completion
{
    if(animate)
    {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
        {
             self.backgroundEffectsView.backgroundColor = [UIColor clearColor];
        }
        completion:^(BOOL finished)
        {
            if(completion)
                completion();
        }];
    }
    else
    {
        self.backgroundEffectsView.backgroundColor = [UIColor clearColor];
        if(completion)
            completion();
    }
}

+ (UINavigationController*)navControllerWithViewController:(UIViewController*)viewController
{
    UINavigationController* navController = [[UINavigationController alloc] initWithNavigationBarClass:[self class] toolbarClass:nil];
    [navController setViewControllers:@[viewController]];
    navController.delegate = [SDPullNavigationManager sharedInstance];
    return navController;
}

- (void)statusBarWillChangeRotationNotification:(NSNotification*)notification
{
    [self hideMenuContainer];
    [self collapseMenu];
    [self.tabButton setNeedsDisplay];

    UIInterfaceOrientation orientation = [notification.userInfo[UIApplicationStatusBarOrientationUserInfoKey] integerValue];

    if(self.implementsMenuWidthForOrientations)
    {
        CGSize menuSize = (CGSize){ UIInterfaceOrientationIsPortrait(orientation) ? self.menuWidthForPortrait : self.menuWidthForLandscape,
                                    MIN(self.menuController.pullNavigationMenuHeight, self.availableHeight) };
        self.menuBottomAdornmentView.frame = (CGRect){ { self.superview.frame.size.width * 0.5f - menuSize.width * 0.5f, -(menuSize.height - self.navigationBarHeight) }, menuSize };
    }

#if 0
    if(self.implementsMenuAdornmentImageWith3PartImage)
    {
        self.menuBottomAdornmentView.adornmentImage = image;
    }
#endif
}

- (void)dismissPullMenuWithCompletionBlock:(void (^)(void))completion
{
    if(self.menuOpen)
    {
        [self togglePullMenuWithCompletionBlock:completion];
    }
}

- (CGFloat)availableHeight
{
    static CGFloat sBottomSafetyGap = 2.0f;

    // Check to see what kind of gap between the bottom of the screen the client wants. Default to 44.0f
    // Should not do this for iPad. Not going to work out well with the bottom of the screen.

    if(sBottomSafetyGap == 2.0f)
    {
        if([UIDevice iPad])
        {
            sBottomSafetyGap = MAX([SDPullNavigationManager sharedInstance].menuAdornmentBottomGap, kDefaultMenuHeightBuffer);
        }
    }

    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    UIWindow* topMostWindow = [UIApplication sharedApplication].windows.lastObject;
    CGSize topMostWindowSize = topMostWindow.bounds.size;
    CGFloat height = UIInterfaceOrientationIsPortrait(orientation) ? MAX(topMostWindowSize.height, topMostWindowSize.width) : MIN(topMostWindowSize.height, topMostWindowSize.width);

    CGFloat navHeight = self.navigationBarHeight;

    // Take into account the menuAdornment at the bottom of the menu and some extra so that the adornment does not butt up against the bottom of the screen.
    if(self.showAdornment)
        navHeight += self.menuAdornmentImage.size.height + sBottomSafetyGap;

    SDLog(@"availableHeight = %f", height - navHeight);

    return height - navHeight;
}

- (CGFloat)navigationBarHeight
{
    CGFloat navHeight = self.frame.size.height;
    
    if(navHeight == 0.0f)
        navHeight += 44.0f;
    navHeight += MIN([UIApplication sharedApplication].statusBarFrame.size.height, [UIApplication sharedApplication].statusBarFrame.size.width);

    return navHeight;
}

#pragma mark - Hit testing

// If user taps in any of my subviews, dismiss the menu. Let the normal events go on as they are wont to do.

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event
{
    UIView* hitView = [super hitTest:point withEvent:event];
    
    if([hitView isDescendantOfView:self])
        [self dismissPullMenuWithCompletionBlock:nil];
    
    return hitView;
}

@end

@implementation SDPullNavigationMenuContainer

#ifdef DEBUG

- (void)layoutSubviews
{
    [super layoutSubviews];

}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

#endif

@end
