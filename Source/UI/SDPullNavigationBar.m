//
//  SDPullNavigationBar.m
//  walmart
//
//  Created by Brandon Sneed on 08/06/2013.
//  Copyright (c) 2013 Walmart. All rights reserved.
//

#import "SDPullNavigationBar.h"

#import "SDPullNavigationBarBackground.h"
#import "SDPullNavigationBarTabButton.h"
#import "SDPullNavigationManager.h"
#import "UIDevice+machine.h"
#import "UIColor+SDExtensions.h"

static UIImage* sMenuAdornmentImage = nil;

#pragma mark - SDPullNavigationBar

@interface SDPullNavigationBar()

@property (nonatomic, strong) SDPullNavigationBarBackground* pullBackgroundView;
@property (nonatomic, strong) SDPullNavigationBarTabButton* tabButton;
@property (nonatomic, strong) UIView* menuContainer;
@property (nonatomic, strong) UIImageView* menuBackgroundEffectsView;
@property (nonatomic, strong) UIImageView* menuBottomAdornmentView;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) BOOL tabOpen;

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
        pullBarAppearance.titleTextAttributes = @{ UITextAttributeTextColor : [UIColor whiteColor] };
        pullBarAppearance.tintColor = [UIColor whiteColor];
    }
    else
    {
        pullBarAppearance.tintColor = [UIColor colorWith8BitRed:23 green:108 blue:172 alpha:1.0];
    }
}

+ (void)setMenuAdornmentImage:(UIImage*)image
{
    sMenuAdornmentImage = image;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self != nil)
    {
        [self commonInit];
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)commonInit
{
    self.translucent = NO;

    _pullBackgroundView = [[SDPullNavigationBarBackground alloc] init];
    _pullBackgroundView.autoresizesSubviews = YES;
    _pullBackgroundView.userInteractionEnabled = NO;
    _pullBackgroundView.opaque = NO;
    _pullBackgroundView.backgroundColor = [UIColor clearColor];
    _pullBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _pullBackgroundView.delegate = (id<SDPullNavigationBarOverlayProtocol>)self;

    _pullBackgroundView.frame = self.bounds;

    _tabButton = [[SDPullNavigationBarTabButton alloc] initWithNavigationBar:self];

    [self insertSubview:_pullBackgroundView atIndex:1];
    [self addSubview:_tabButton];

    _menuContainer = [[UIView alloc] initWithFrame:self.superview.bounds];
    _menuContainer.clipsToBounds = YES;
    _menuContainer.backgroundColor = [UIColor clearColor];
    _menuContainer.opaque = NO;

    _menuContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    _menuContainer.layer.shadowOffset = CGSizeMake(0, -3.0);
    _menuContainer.layer.shadowRadius = 3.0f;
    _menuContainer.layer.shadowOpacity = 1.0;

    _menuBackgroundEffectsView = [[UIImageView alloc] initWithFrame:_menuContainer.bounds];
    _menuBackgroundEffectsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _menuBackgroundEffectsView.clipsToBounds = YES;
    _menuBackgroundEffectsView.backgroundColor = [@"#00000033" uicolor];
    _menuBackgroundEffectsView.opaque = NO;
    [_menuContainer addSubview:_menuBackgroundEffectsView];

    UIStoryboard* menuStoryBoard = [UIStoryboard storyboardWithName:[SDPullNavigationManager globalMenuStoryboardId] bundle:nil];
    _menuController = [menuStoryBoard instantiateInitialViewController];
    _menuController.view.clipsToBounds = YES;
    _menuController.view.opaque = YES;
    _menuController.pullNavigationBarDelegate = self;
    [_menuContainer addSubview:_menuController.view];
    [_menuContainer addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTapAction:)]];

    if(sMenuAdornmentImage)
    {
        _menuBottomAdornmentView = [[UIImageView alloc] initWithFrame:(CGRect){CGPointZero, { _menuController.view.bounds.size.width, sMenuAdornmentImage.size.height }}];
        _menuBottomAdornmentView.clipsToBounds = YES;
        _menuBottomAdornmentView.backgroundColor = [UIColor clearColor];
        _menuBottomAdornmentView.opaque = YES;
        _menuBottomAdornmentView.image = sMenuAdornmentImage;
        [_menuContainer addSubview:_menuBottomAdornmentView];
    }

    // Setup the starting point for the first opening animation.

    CGRect menuFrame = _menuController.view.frame;
    menuFrame.size.height = 556.0f;
    _menuController.view.frame = menuFrame;
    _menuBottomAdornmentView.frame = (CGRect){{menuFrame.origin.x, menuFrame.origin.y + menuFrame.size.height }, _menuBottomAdornmentView.frame.size};

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusBarWillChangeRotationNotification:)
                                                 name:UIApplicationWillChangeStatusBarOrientationNotification
                                               object:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    NSInteger index = 0;
    if(self.subviews.count > 0)
        index = 1;

    CGFloat tabOffset = 8.0f;

    CGPoint navBarCenter = self.center;
    CGRect tabFrame = self.tabButton.frame;
    tabFrame.origin.x = (navBarCenter.x - (tabFrame.size.width * 0.5f));
    tabFrame.origin.y = self.bounds.size.height - (tabFrame.size.height - tabOffset);
    self.tabButton.frame = CGRectIntegral(tabFrame);

    [self insertSubview:self.pullBackgroundView atIndex:index];
    [self addSubview:self.tabButton];

    self.menuContainer.frame = self.superview.bounds;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.pullBackgroundView.frame = self.bounds;
}

- (void)drawOverlayRect:(CGRect)rect
{
    // default implementation does nothing.
}

- (void)tapAction:(id)sender
{
    if( !self.animating )
    {
        self.animating = YES;

        if([UIDevice iPad] && !self.tabOpen)
        {
            self.menuController.view.frame = (CGRect){{ self.frame.size.width * 0.5f - 160.0f, 64.0f }, { 320.0f, 0.0f } };
            self.menuBottomAdornmentView.frame = (CGRect){ { self.menuController.view.frame.origin.x, self.menuController.view.frame.origin.y + self.menuController.view.frame.size.height },
                                                           { self.menuController.view.frame.size.width, sMenuAdornmentImage.size.height } };
        }

        [self.superview insertSubview:self.menuContainer belowSubview:self];
        self.menuContainer.hidden = NO;

        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
        {
            self.tabButton.tuckedTab = !self.tabOpen;
            if(!self.tabOpen)
                [self.tabButton setNeedsDisplay];

            CGFloat height = self.tabOpen ? 0.0f : 556.0f;
            CGFloat width = [UIDevice iPad] ? 320.0f : self.menuController.view.frame.size.width;

            self.menuController.view.frame = (CGRect){ { self.frame.size.width * 0.5f - self.menuController.view.bounds.size.width * 0.5f, self.frame.size.height + 20.0f }, { width, height } };
            self.menuBottomAdornmentView.frame = (CGRect){{self.menuController.view.frame.origin.x, self.menuController.view.frame.origin.y + self.menuController.view.frame.size.height }, self.menuBottomAdornmentView.frame.size };

            self.tabOpen = !self.tabOpen;
        }
        completion:^(BOOL finished)
        {
            if(!self.tabOpen)
                [self.tabButton setNeedsDisplay];
            self.animating = NO;
            self.menuContainer.hidden = !self.tabOpen;
            self.menuBottomAdornmentView.hidden = !self.tabOpen;
        }];
    }
}

- (void)dismissTapAction:(id)sender
{
    if(self.tabOpen)
        [self dismissPullMenu];
}

#pragma mark - Helpers

+ (UINavigationController*)navControllerWithViewController:(UIViewController*)viewController
{
    UINavigationController *navController = [[UINavigationController alloc] initWithNavigationBarClass:[self class] toolbarClass:nil];
    [navController setViewControllers:@[viewController]];
    navController.delegate = [SDPullNavigationManager sharedInstance];
    return navController;
}

- (void)statusBarWillChangeRotationNotification:(NSNotification*)notification
{
    [self dismissPullMenu];
}

- (void)dismissPullMenu
{
    if(self.tabOpen)
    {
        [self tapAction:self];
    }
}

@end
