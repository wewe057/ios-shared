//
//  SDGlobalNavMenuController.m
//  SamsClub
//
//  Created by Steven Woolgar on 12/07/2013.
//  Copyright (c) 2013 Wal-mart Stores, Inc. All rights reserved.
//

#import "SDGlobalNavMenuController.h"

#import "SDAppDelegate.h"
#import "SDPullNavigationManager.h"
#import "SDHomeScreenViewController.h"
#import "SDOrderHistoryViewController.h"

NSString* const SDGlobalNavMenuCell = @"SDGlobalNavMenuCell";
NSString* const SDGlobalNavMenuSignInCell = @"SDGlobalNavMenuSignInCell";

typedef NS_ENUM(NSUInteger, SDGlobalNavMenuSections)
{
    SDGlobalNavMenuSectionShop,
    SDGlobalNavMenuSectionMyAccount,
    SDGlobalNavMenuSectionToolsAndServices,
    SDGlobalNavMenuSectionMore,
    SDGlobalNavMenuSectionCount
};

typedef NS_ENUM(NSUInteger, SDGlobalNavShop)
{
    SDGlobalNavMenuHome,
    SDGlobalNavMenuInstantSavings,
    SDGlobalNavMenuLists,
    SDGlobalNavMenuShopCount
};

typedef NS_ENUM(NSUInteger, SDGlobalNavMyAccount)
{
    SDGlobalNavMenuHomeYourMembership,
    SDGlobalNavMenuMembershipCard,
    SDGlobalNavMenuYourOrders,
    SDGlobalNavMenuYourExpressCheckoutSettings,
    SDGlobalNavMenuMyAccountCount
};

typedef NS_ENUM(NSUInteger, SDGlobalNavToolsAndServices)
{
    SDGlobalNavMenuClubLocator,
    SDGlobalNavMenuPharmacyRefills,
    SDGlobalNavMenuToolsAndServicesCount
};

typedef NS_ENUM(NSUInteger, SDGlobalNavMore)
{
    SDGlobalNavMenuAbout,
    SDGlobalNavMenuProvideFeedback,
    SDGlobalNavMenuMessages,
    SDGlobalNavMenuSignOut,
    SDGlobalNavMenuMoreCount
};

@interface NSString(SDGlobalNavMenu_Extensions)
+ (NSString*)stringWithSectionGlobalNavMenu:(SDGlobalNavMenuSections)section andRow:(NSUInteger)row signedIn:(BOOL)signedIn;
+ (NSString*)stringWithSectionGlobalNavMenu:(SDGlobalNavMenuSections)section;
@end

@interface SDGlobalNavMenuController()
@property (nonatomic, strong) IBOutlet UITableViewHeaderFooterView* tableViewHeader;
@property (nonatomic, strong) IBOutlet UIView* signedInModeView;
@property (nonatomic, strong) IBOutlet UILabel* clubNameLabel;
@property (nonatomic, strong) IBOutlet UIView* signedOutModeView;
@property (nonatomic, strong) IBOutlet UILabel* yourClubLabel;
@property (nonatomic, copy) NSString* clubNameString;
@end

@implementation SDGlobalNavMenuController

@synthesize pullNavigationBarDelegate = _pullNavigationBarDelegate;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableViewHeader.backgroundView.backgroundColor = [@"#efeff4" uicolor];
    self.clubNameLabel.font = [UIFont fontWithName:@"Kulturista" size:22.0f];
    self.clubNameLabel.textColor = [@"#545454" uicolor];

    self.yourClubLabel.font = [UIFont fontWithName:@"KulturistaMedium" size:22.0f];
    self.yourClubLabel.textColor = [@"#545454" uicolor];

    self.signedInModeView.hidden = NO;
    self.signedOutModeView.hidden = YES;
}

- (void)viewWillLayoutSubviews
{
    self.signedInModeView.hidden = YES;
    self.signedOutModeView.hidden = NO;
}

// PullNav delegate methods. Good place to hook into the otherwise unavailable viewWillAppear.
// Commonly used to instrument analytics. Full series of methods supported.
//
// - (void)pullNavMenuWillAppear;
// - (void)pullNavMenuDidAppear;
//
// - (void)pullNavMenuWillDisappear;
// - (void)pullNavMenuDidDisappear;

- (void)pullNavMenuDidAppear
{
    SDLog(@"pullNavMenuDidAppear called.");
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SDGlobalNavMenuSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 0;
    switch(section)
    {
        case SDGlobalNavMenuSectionShop:
            rowCount = SDGlobalNavMenuShopCount;
            break;
        case SDGlobalNavMenuSectionMyAccount:
            rowCount = SDGlobalNavMenuMyAccountCount;
            break;
        case SDGlobalNavMenuSectionToolsAndServices:
            rowCount = SDGlobalNavMenuToolsAndServicesCount;
            break;
        case SDGlobalNavMenuSectionMore:
            rowCount = SDGlobalNavMenuMoreCount;
            break;
        default:
            NSAssert(NO, @"Invalid section");
            break;
    }

    return rowCount;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = nil;
    if(indexPath.section == SDGlobalNavMenuSectionShop && indexPath.row == SDGlobalNavMenuHome)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:SDGlobalNavMenuSignInCell];
        UIButton* signInButton = (UIButton*)[cell viewWithTag:2];
        [signInButton setBackgroundImage:[[UIImage imageNamed:@"button-small-gray"] resizableImageWithCapInsets:UIEdgeInsetsMake(13, 3, 13, 3)] forState:UIControlStateNormal];
        [signInButton setBackgroundImage:[[UIImage imageNamed:@"button-small-gray-highlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(13, 3, 13, 3)] forState:UIControlStateHighlighted];
        signInButton.hidden = NO;
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:SDGlobalNavMenuCell];
    }

    UILabel* cellLabel = (UILabel*)[cell viewWithTag:1];
    cellLabel.text = [NSString stringWithSectionGlobalNavMenu:(SDGlobalNavMenuSections)indexPath.section
                                                       andRow:(NSUInteger)indexPath.row
                                                     signedIn:NO];

    return cell;
}

// Be careful with the indexPath.row enums. There are two MyAccount ones. One set for signed in, one set for signedout.
// They are different and so you need to include the [[SWIUserSession userSession] loggedIn] boolean into the comparison.
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    @strongify(self.pullNavigationBarDelegate, pullNavigationBarDelegate);
    if(indexPath.section == SDGlobalNavMenuSectionShop && indexPath.row == SDGlobalNavMenuHome)
    {
        [[SDPullNavigationManager sharedInstance] navigateToTopLevelController:[SDHomeScreenViewController class] andPopToRootWithAnimation:NO];
        [pullNavigationBarDelegate dismissPullMenuWithCompletionBlock:nil];
    }

    else if(indexPath.section == SDGlobalNavMenuSectionMyAccount && indexPath.row == SDGlobalNavMenuYourOrders)
    {
        [[SDPullNavigationManager sharedInstance] navigateToTopLevelController:[SDOrderHistoryViewController class] andPopToRootWithAnimation:NO];
        [pullNavigationBarDelegate dismissPullMenuWithCompletionBlock:nil];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UITableViewDelegate

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* sectionView = [[UIView alloc] initWithFrame:(CGRect){ CGPointZero, { self.tableView.contentSize.width, 21.0f } }];
    UILabel* sectionLabel = [[UILabel alloc] initWithFrame:(CGRect){ { 21.0f, 1.0f }, { self.tableView.contentSize.width, 21.0f } }];
    [sectionView addSubview:sectionLabel];

    sectionView.backgroundColor = [@"#f7f7f9" uicolor];
    sectionLabel.backgroundColor = [UIColor clearColor];
    sectionLabel.textColor = [@"#545454" uicolor];
    sectionLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    sectionLabel.text = [NSString stringWithSectionGlobalNavMenu:(SDGlobalNavMenuSections)section];

    return sectionView;
}

#pragma mark - SDPullNavigationBarDelegate

- (CGFloat)pullNavigationMenuHeight
{
    CGFloat currentHeight = self.tableView.contentSize.height;

    if(currentHeight <= self.tableViewHeader.frame.size.height)
        [self.tableView reloadData];

    return self.tableView.contentSize.height;
}

#if 0   // This can be used if you have a menu that is the same width in both orientations.

- (CGFloat)pullNavigationMenuWidth
{
    return self.tableView.contentSize.width;
}

#else

- (CGFloat)pullNavigationMenuWidthForPortrait
{
    return self.tableView.contentSize.width;
}

- (CGFloat)pullNavigationMenuWidthForLandscape
{
    return self.tableView.contentSize.width + 80.0f;    // Just bigger so we can see this working.
}

#endif

@end

@implementation NSString(SDGlobalNavMenu_Extensions)

+ (NSString*)stringWithSectionGlobalNavMenu:(SDGlobalNavMenuSections)section andRow:(NSUInteger)row signedIn:(BOOL)signedIn
{
    NSString* result = @"";

    switch(section)
    {
        case SDGlobalNavMenuSectionShop:
        {
            switch(row)
            {
                case SDGlobalNavMenuHome:
                    result = NSLocalizedString( @"Home", @"SDGlobalNavMenuHome" );
                    break;
                case SDGlobalNavMenuInstantSavings:
                    result = NSLocalizedString( @"Instant Savings", @"SDGlobalNavMenuInstantSavings" );
                    break;
                case SDGlobalNavMenuLists:
                    result = NSLocalizedString( @"Lists", @"SDGlobalNavMenuLists" );
                    break;
                default:
                    NSAssert(NO, @"Invalid section");
                    break;
            }
            break;
        }
        case SDGlobalNavMenuSectionMyAccount:
        {
            switch(row)
            {
                case SDGlobalNavMenuHomeYourMembership:
                    result = NSLocalizedString( @"Your Membership", @"SDGlobalNavMenuHomeYourMembership" );
                    break;
                case SDGlobalNavMenuMembershipCard:
                    result = NSLocalizedString( @"Membership Card", @"SDGlobalNavMenuMembershipCard" );
                    break;
                case SDGlobalNavMenuYourOrders:
                    result = NSLocalizedString( @"Your Orders", @"SDGlobalNavMenuYourOrders" );
                    break;
                case SDGlobalNavMenuYourExpressCheckoutSettings:
                    result = NSLocalizedString( @"Express Checkout Settings", @"SDGlobalNavMenuYourExpressCheckoutSettings" );
                    break;
                default:
                    NSAssert(NO, @"Invalid section");
                    break;
            }
            break;
        }
        case SDGlobalNavMenuSectionToolsAndServices:
        {
            switch(row)
            {
                case SDGlobalNavMenuClubLocator:
                    result = NSLocalizedString( @"Club Locator", @"SDGlobalNavMenuClubLocator" );
                    break;
                case SDGlobalNavMenuPharmacyRefills:
                    result = NSLocalizedString( @"Pharmacy Refills", @"SDGlobalNavMenuPharmacyRefills" );
                    break;
                default:
                    NSAssert(NO, @"Invalid section");
                    break;
            }
            break;
        }
        case SDGlobalNavMenuSectionMore:
        {
            switch(row)
            {
                case SDGlobalNavMenuAbout:
                    result = NSLocalizedString( @"About", @"SDGlobalNavMenuAbout" );
                    break;
                case SDGlobalNavMenuProvideFeedback:
                    result = NSLocalizedString( @"Provide Feedback", @"SDGlobalNavMenuProvideFeedback" );
                    break;
                case SDGlobalNavMenuMessages:
                    result = NSLocalizedString( @"Messages", @"SDGlobalNavMenuMessages" );
                    break;
                case SDGlobalNavMenuSignOut:
                    result = NSLocalizedString( @"Sign Out", @"SDGlobalNavMenuSignOut" );
                    break;
                default:
                    NSAssert(NO, @"Invalid section");
                    break;
            }
            break;
        }
        default:
        {
            NSAssert(NO, @"Invalid section");
            break;
        }
    }

    return result;
}

+ (NSString*)stringWithSectionGlobalNavMenu:(SDGlobalNavMenuSections)section
{
    NSString* result = @"";
    
    switch(section)
    {
        case SDGlobalNavMenuSectionShop:
        {
            result = NSLocalizedString( @"SHOP", @"SDGlobalNavMenuSectionShop" );
            break;
        }
        case SDGlobalNavMenuSectionMyAccount:
        {
            result = NSLocalizedString( @"MY ACCOUNT", @"SDGlobalNavMenuSectionMyAccount" );
            break;
        }
        case SDGlobalNavMenuSectionToolsAndServices:
        {
            result = NSLocalizedString( @"TOOLS & SERVICES", @"SDGlobalNavMenuSectionToolsAndServices" );
            break;
        }
        case SDGlobalNavMenuSectionMore:
        {
            result = NSLocalizedString( @"MORE", @"SDGlobalNavMenuSectionMore" );
            break;
        }
        default:
        {
            NSAssert(NO, @"Invalid section");
            break;
        }
    }
    
    return result;
}

@end
