//
//  SWIGlobalNavMenuController.m
//  SamsClub
//
//  Created by Steven Woolgar on 12/07/2013.
//  Copyright (c) 2013 Wal-mart Stores, Inc. All rights reserved.
//

#import "SWIGlobalNavMenuController.h"

#import "AppDelegate.h"
#import "DemoHomeViewController.h"
#import "RFIWebService.h"
#import "SDMacros.h"
#import "SDPullNavigationManager.h"
#import "SWIHomeScreenViewController.h"
#import "SWISignInViewController.h"
#import "SWIClubDetails.h"
#import "SWIClubLocatorViewController.h"
#import "SWIUserSession.h"
#import "SWIOrderHistorySplitViewController.h"
#import "SWIPharmacyRefillsViewController.h"
#import "SWIMyMembershipViewController.h"
#import "SWIInstantSavingsViewController.h"
#import "SWIAboutViewController.h"
#import "SWIMembershipBenefitsViewController.h"

NSString* const SWIGlobalNavMenuCell = @"SWIGlobalNavMenuCell";
NSString* const SWIGlobalNavMenuSignInCell = @"SWIGlobalNavMenuSignInCell";

typedef NS_ENUM(NSUInteger, SWIGlobalNavMenuSections)
{
    SWIGlobalNavMenuSectionShop,
    SWIGlobalNavMenuSectionMyAccount,
    SWIGlobalNavMenuSectionToolsAndServices,
    SWIGlobalNavMenuSectionMore,
    SWIGlobalNavMenuSectionCount
};

typedef NS_ENUM(NSUInteger, SWIGlobalNavShop)
{
    SWIGlobalNavMenuHome,
    SWIGlobalNavMenuInstantSavings,
    SWIGlobalNavMenuLists,
    SWIGlobalNavMenuShopCount
};

typedef NS_ENUM(NSUInteger, SWIGlobalNavMyAccountSignedOut)
{
    SWIGlobalNavMenuBecomeMemberSignedOut,
    SWIGlobalNavMenuMyAccountCountSignedOut
};

typedef NS_ENUM(NSUInteger, SWIGlobalNavMyAccountSignedIn)
{
    SWIGlobalNavMenuHomeYourMembershipSignedIn,
    SWIGlobalNavMenuMembershipCardSignedIn,
    SWIGlobalNavMenuYourOrdersSignedIn,
    SWIGlobalNavMenuYourExpressCheckoutSettingsSignedIn,
    SWIGlobalNavMenuMyAccountCountSignedIn
};

typedef NS_ENUM(NSUInteger, SWIGlobalNavToolsAndServices)
{
    SWIGlobalNavMenuClubLocator,
    SWIGlobalNavMenuPharmacyRefills,
    SWIGlobalNavMenuToolsAndServicesCount
};

typedef NS_ENUM(NSUInteger, SWIGlobalNavMoreSignedIn)
{
    SWIGlobalNavMenuAbout,
    SWIGlobalNavMenuProvideFeedback,
    SWIGlobalNavMenuMessages,
    SWIGlobalNavMenuSignOut,
    SWIGlobalNavMenuMoreCount
};

typedef NS_ENUM(NSUInteger, SWIGlobalNavMoreSignedOut)
{
    SWIGlobalNavMenuAboutSignedOut,
    SWIGlobalNavMenuProvideFeedbackSignedOut,
    SWIGlobalNavMenuMessagesSignedOut,
    SWIGlobalNavMenuMoreCountSignedOut
};

@interface NSString(SWIGlobalNavMenu_Extensions)
+ (NSString*)stringWithSectionGlobalNavMenu:(SWIGlobalNavMenuSections)section andRow:(NSUInteger)row signedIn:(BOOL)signedIn;
+ (NSString*)stringWithSectionGlobalNavMenu:(SWIGlobalNavMenuSections)section;
@end

@interface SWIGlobalNavMenuController()
@property (nonatomic, strong) IBOutlet UITableViewHeaderFooterView* tableViewHeader;
@property (nonatomic, strong) IBOutlet UIView* signedInModeView;
@property (nonatomic, strong) IBOutlet UILabel* clubNameLabel;
@property (nonatomic, strong) IBOutlet UIView* signedOutModeView;
@property (nonatomic, strong) IBOutlet UILabel* yourClubLabel;
@property (nonatomic, copy) NSString* clubNameString;
@end

@implementation SWIGlobalNavMenuController

@synthesize pullNavigationBarDelegate = _pullNavigationBarDelegate;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSignedIn:) name:kSWIUserSessionNotificationLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSignedOut:) name:kSWIUserSessionNotificationLogout object:nil];

    self.tableViewHeader.backgroundView.backgroundColor = [@"#efeff4" uicolor];
    self.clubNameLabel.font = [UIFont fontWithName:@"Kulturista" size:22.0f];
    self.clubNameLabel.textColor = [@"#545454" uicolor];

    self.yourClubLabel.font = [UIFont fontWithName:@"KulturistaMedium" size:22.0f];
    self.yourClubLabel.textColor = [@"#545454" uicolor];

    self.signedInModeView.hidden = NO;
    self.signedOutModeView.hidden = YES;

    // Figure out the name of the home club.
    [self determineHomeClubName];
}

- (void)viewWillLayoutSubviews
{
    BOOL signedIn = [[SWIUserSession userSession] loggedIn];

    self.signedInModeView.hidden = !signedIn;
    self.signedOutModeView.hidden = signedIn;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SWIGlobalNavMenuSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 0;
    switch(section)
    {
        case SWIGlobalNavMenuSectionShop:
            rowCount = SWIGlobalNavMenuShopCount;
            break;
        case SWIGlobalNavMenuSectionMyAccount:
            rowCount = [[SWIUserSession userSession] loggedIn] ? SWIGlobalNavMenuMyAccountCountSignedIn : SWIGlobalNavMenuMyAccountCountSignedOut;
            break;
        case SWIGlobalNavMenuSectionToolsAndServices:
            rowCount = SWIGlobalNavMenuToolsAndServicesCount;
            break;
        case SWIGlobalNavMenuSectionMore:
            rowCount = [[SWIUserSession userSession] loggedIn] ? SWIGlobalNavMenuMoreCount : SWIGlobalNavMenuMoreCountSignedOut;
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
    if(indexPath.section == SWIGlobalNavMenuSectionShop && indexPath.row == SWIGlobalNavMenuHome)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:SWIGlobalNavMenuSignInCell];
        UIButton* signInButton = (UIButton*)[cell viewWithTag:2];
        if([[SWIUserSession userSession] loggedIn])
        {
            signInButton.hidden = YES;
        }
        else
        {
            [signInButton setBackgroundImage:[[UIImage imageNamed:@"button-small-gray"] resizableImageWithCapInsets:UIEdgeInsetsMake(13, 3, 13, 3)] forState:UIControlStateNormal];
            [signInButton setBackgroundImage:[[UIImage imageNamed:@"button-small-gray-highlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(13, 3, 13, 3)] forState:UIControlStateHighlighted];
            [signInButton addTarget:self action:@selector(signInTapped:) forControlEvents:UIControlEventTouchUpInside];
            signInButton.hidden = NO;
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:SWIGlobalNavMenuCell];
    }

    UILabel* cellLabel = (UILabel*)[cell viewWithTag:1];
    cellLabel.text = [NSString stringWithSectionGlobalNavMenu:(SWIGlobalNavMenuSections)indexPath.section
                                                       andRow:(NSUInteger)indexPath.row
                                                     signedIn:[[SWIUserSession userSession] loggedIn]];

    return cell;
}

// Be careful with the indexPath.row enums. There are two MyAccount ones. One set for signed in, one set for signedout.
// They are different and so you need to include the [[SWIUserSession userSession] loggedIn] boolean into the comparison.
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    SDContainerViewController* globalNav = [SDPullNavigationManager sharedInstance].globalPullNavController;
    BOOL signedIn = [[SWIUserSession userSession] loggedIn];

    @strongify(self.pullNavigationBarDelegate, pullNavigationBarDelegate);
    if(indexPath.section == SWIGlobalNavMenuSectionShop && indexPath.row == SWIGlobalNavMenuHome)
    {
        [[SDPullNavigationManager sharedInstance] navigateToTopLevelController:[SWIHomeScreenViewController class] andPopToRootWithAnimation:NO];
        [pullNavigationBarDelegate dismissPullMenuWithCompletionBlock:nil];
    }

    if (indexPath.section == SWIGlobalNavMenuSectionShop && indexPath.row == SWIGlobalNavMenuInstantSavings)
    {
        [[SDPullNavigationManager sharedInstance] navigateToTopLevelController:[SWIInstantSavingsViewController class] andPopToRootWithAnimation:NO];
        [pullNavigationBarDelegate dismissPullMenuWithCompletionBlock:nil];
    }
    
    else if(indexPath.section == SWIGlobalNavMenuSectionToolsAndServices && indexPath.row == SWIGlobalNavMenuClubLocator)
    {
        [pullNavigationBarDelegate dismissPullMenuWithCompletionBlock:^
        {
            SWIClubLocatorViewController* clubLocatorViewController = [SWIClubLocatorViewController loadFromStoryboardNamed:@"SWIClubLocator"];
            [globalNav.selectedViewController presentViewController:clubLocatorViewController animated:YES completion:nil];
            [tableView deselectRowAtIndexPath: indexPath animated: NO];
        }];
    }

    else if(indexPath.section == SWIGlobalNavMenuSectionMore && indexPath.row == SWIGlobalNavMenuSignOut)
    {
        [pullNavigationBarDelegate dismissPullMenuWithCompletionBlock:nil];
        [[SWIUserSession userSession] logout];
    }

	else if(signedIn && indexPath.section == SWIGlobalNavMenuSectionMyAccount && indexPath.row == SWIGlobalNavMenuYourOrdersSignedIn)
    {
        [[SDPullNavigationManager sharedInstance] navigateToTopLevelController:[SWIOrderHistorySplitViewController class]];
		[pullNavigationBarDelegate dismissPullMenuWithCompletionBlock:nil];
	}

    else if(signedIn && indexPath.section == SWIGlobalNavMenuSectionMyAccount && indexPath.row == SWIGlobalNavMenuHomeYourMembershipSignedIn)
    {
        [[SDPullNavigationManager sharedInstance] navigateToTopLevelController:[SWIMyMembershipViewController class]];
        [pullNavigationBarDelegate dismissPullMenuWithCompletionBlock:nil];
    }

	else if(!signedIn && indexPath.section == SWIGlobalNavMenuSectionMyAccount && indexPath.row == SWIGlobalNavMenuBecomeMemberSignedOut)
    {
        SWIMembershipBenefitsViewController *benefitsViewController = [[SWIMembershipBenefitsViewController alloc] initWithMembership:[[SWIUserSession userSession] membership]];
        UINavigationController* benefitsNavController = [[UINavigationController alloc] initWithRootViewController:benefitsViewController];
        [self presentViewController:benefitsNavController animated:YES completion:NULL];
        [pullNavigationBarDelegate dismissPullMenuWithCompletionBlock:nil];
	}

    else if(indexPath.section == SWIGlobalNavMenuSectionToolsAndServices && indexPath.row == SWIGlobalNavMenuPharmacyRefills)
    {
        [[SDPullNavigationManager sharedInstance] navigateToTopLevelController:[SWIPharmacyRefillsViewController class] andPopToRootWithAnimation:YES];
        [pullNavigationBarDelegate dismissPullMenuWithCompletionBlock:nil];
    }
    
    else if(indexPath.section == SWIGlobalNavMenuSectionMore && indexPath.row == SWIGlobalNavMenuAbout)
    {
        SWIAboutViewController* aboutViewController = [SWIAboutViewController loadFromStoryboardNamed:@"SWISettings"];
        [globalNav.selectedViewController presentViewController:aboutViewController animated:YES completion:nil];
        [pullNavigationBarDelegate dismissPullMenuWithCompletionBlock:nil];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (IBAction)chooseClubTapped:(id)sender
{
    SDContainerViewController* globalNav = [SDPullNavigationManager sharedInstance].globalPullNavController;

    [self.pullNavigationBarDelegate dismissPullMenuWithCompletionBlock:nil];
    SWIClubLocatorViewController* clubLocatorViewController = [[UIStoryboard storyboardWithName:@"SWIClubLocator" bundle:nil] instantiateInitialViewController];
    [globalNav.selectedViewController presentViewController:clubLocatorViewController animated:YES completion:nil];
}

- (IBAction)signInTapped:(id)sender
{
    SWISignInViewController* signInViewController = [[SWISignInViewController alloc] initWithNibName:nil bundle:nil];

    @weakify(self);
    signInViewController.doneBlock = ^(BOOL apply)
    {
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:nil];
    };

    // Dismiss the menu before showing the signin.
    [self.pullNavigationBarDelegate dismissPullMenuWithCompletionBlock:nil];

    // Now show it.
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:signInViewController];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navController animated:YES completion:nil];
    [self.tableView reloadData];
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
    sectionLabel.text = [NSString stringWithSectionGlobalNavMenu:(SWIGlobalNavMenuSections)section];

    return sectionView;
}

#pragma mark - Utility Methods

- (void)userSignedIn:(NSNotification*)notification
{
    [self determineHomeClubName];
    [self.tableView reloadData];
}

- (void)userSignedOut:(NSNotification*)notification
{
    [self.tableView reloadData];
}

- (void)determineHomeClubName
{
    self.clubNameString = @"";

    if([[SWIUserSession userSession] loggedIn])
    {
        [[RFIWebService sharedInstance] clubDetails:[[[SWIUserSession userSession] membership] homeClubNumber]
                                  uiCompletionBlock:^(id dataObject, NSError *error)
        {
            if(dataObject && error == nil)
            {
                SWIClubDetails* club = [SWIClubDetails clubDetailsWithDictionary:[dataObject dictionaryForKey:@"club"]];
                self.clubNameString = club.name;
                self.clubNameLabel.text = club.name;
                [self.clubNameLabel setNeedsDisplay];
            }
        }];
    }
}

#pragma mark - SDPullNavigationBarDelegate

- (CGFloat)pullNavigationMenuHeight
{
    CGFloat currentHeight = self.tableView.contentSize.height;

    if(currentHeight <= self.tableViewHeader.frame.size.height)
        [self.tableView reloadData];

    return self.tableView.contentSize.height;
}

- (CGFloat)pullNavigationMenuWidth
{
    return self.tableView.contentSize.width;
}

@end

@implementation NSString(SWIGlobalNavMenu_Extensions)

+ (NSString*)stringWithSectionGlobalNavMenu:(SWIGlobalNavMenuSections)section andRow:(NSUInteger)row signedIn:(BOOL)signedIn
{
    NSString* result = @"";

    switch(section)
    {
        case SWIGlobalNavMenuSectionShop:
        {
            switch(row)
            {
                case SWIGlobalNavMenuHome:
                    result = NSLocalizedString( @"Home", @"SWIGlobalNavMenuHome" );
                    break;
                case SWIGlobalNavMenuInstantSavings:
                    result = NSLocalizedString( @"Instant Savings", @"SWIGlobalNavMenuInstantSavings" );
                    break;
                case SWIGlobalNavMenuLists:
                    result = NSLocalizedString( @"Lists", @"SWIGlobalNavMenuLists" );
                    break;
                default:
                    NSAssert(NO, @"Invalid section");
                    break;
            }
            break;
        }
        case SWIGlobalNavMenuSectionMyAccount:
        {
            if(signedIn)
            {
                switch(row)
                {
                    case SWIGlobalNavMenuHomeYourMembershipSignedIn:
                        result = NSLocalizedString( @"Your Membership", @"SWIGlobalNavMenuHomeYourMembership" );
                        break;
                    case SWIGlobalNavMenuMembershipCardSignedIn:
                        result = NSLocalizedString( @"Membership Card", @"SWIGlobalNavMenuMembershipCard" );
                        break;
                    case SWIGlobalNavMenuYourOrdersSignedIn:
                        result = NSLocalizedString( @"Your Orders", @"SWIGlobalNavMenuYourOrders" );
                        break;
                    case SWIGlobalNavMenuYourExpressCheckoutSettingsSignedIn:
                        result = NSLocalizedString( @"Express Checkout Settings", @"SWIGlobalNavMenuYourExpressCheckoutSettings" );
                        break;
                    default:
                        NSAssert(NO, @"Invalid section");
                        break;
                }
                break;
            }
            else
            {
                switch(row)
                {
                    case SWIGlobalNavMenuBecomeMemberSignedOut:
                        result = NSLocalizedString( @"Become a Member", @"SWIGlobalNavMenuBecomeMemberSignedOut" );
                        break;
                    default:
                        NSAssert(NO, @"Invalid section");
                        break;
                }
                break;
            }
        }
        case SWIGlobalNavMenuSectionToolsAndServices:
        {
            switch(row)
            {
                case SWIGlobalNavMenuClubLocator:
                    result = NSLocalizedString( @"Club Locator", @"SWIGlobalNavMenuClubLocator" );
                    break;
                case SWIGlobalNavMenuPharmacyRefills:
                    result = NSLocalizedString( @"Pharmacy Refills", @"SWIGlobalNavMenuPharmacyRefills" );
                    break;
                default:
                    NSAssert(NO, @"Invalid section");
                    break;
            }
            break;
        }
        case SWIGlobalNavMenuSectionMore:
        {
            if(signedIn)
            {
                switch(row)
                {
                    case SWIGlobalNavMenuAbout:
                        result = NSLocalizedString( @"About", @"SWIGlobalNavMenuAbout" );
                        break;
                    case SWIGlobalNavMenuProvideFeedback:
                        result = NSLocalizedString( @"Provide Feedback", @"SWIGlobalNavMenuProvideFeedback" );
                        break;
                    case SWIGlobalNavMenuMessages:
                        result = NSLocalizedString( @"Messages", @"SWIGlobalNavMenuMessages" );
                        break;
                    case SWIGlobalNavMenuSignOut:
                        result = NSLocalizedString( @"Sign Out", @"SWIGlobalNavMenuSignOut" );
                        break;
                    default:
                        NSAssert(NO, @"Invalid section");
                        break;
                }
                break;
            }
            else
            {
                switch(row)
                {
                    case SWIGlobalNavMenuAboutSignedOut:
                        result = NSLocalizedString( @"About", @"SWIGlobalNavMenuAbout" );
                        break;
                    case SWIGlobalNavMenuProvideFeedbackSignedOut:
                        result = NSLocalizedString( @"Provide Feedback", @"SWIGlobalNavMenuProvideFeedback" );
                        break;
                    case SWIGlobalNavMenuMessagesSignedOut:
                        result = NSLocalizedString( @"Messages", @"SWIGlobalNavMenuMessages" );
                        break;
                    default:
                        NSAssert(NO, @"Invalid section");
                        break;
                }
                break;
            }
        }
        default:
        {
            NSAssert(NO, @"Invalid section");
            break;
        }
    }

    return result;
}

+ (NSString*)stringWithSectionGlobalNavMenu:(SWIGlobalNavMenuSections)section
{
    NSString* result = @"";
    
    switch(section)
    {
        case SWIGlobalNavMenuSectionShop:
        {
            result = NSLocalizedString( @"SHOP", @"SWIGlobalNavMenuSectionShop" );
            break;
        }
        case SWIGlobalNavMenuSectionMyAccount:
        {
            result = NSLocalizedString( @"MY ACCOUNT", @"SWIGlobalNavMenuSectionMyAccount" );
            break;
        }
        case SWIGlobalNavMenuSectionToolsAndServices:
        {
            result = NSLocalizedString( @"TOOLS & SERVICES", @"SWIGlobalNavMenuSectionToolsAndServices" );
            break;
        }
        case SWIGlobalNavMenuSectionMore:
        {
            result = NSLocalizedString( @"MORE", @"SWIGlobalNavMenuSectionMore" );
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
