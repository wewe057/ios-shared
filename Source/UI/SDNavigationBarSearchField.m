//
//  SDNavigationBarSearchField.m
//  SetDirection
//
//  Created by Andrew Finnell on 4/16/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "SDNavigationBarSearchField.h"
#import "SDSearchSuggestionsViewController.h"

@interface SDNavigationBarSearchField () <UITextFieldDelegate, SDSearchSuggestionsViewControllerDelegate, UIPopoverControllerDelegate>
@end

@implementation SDNavigationBarSearchField

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self != nil )
    {
        [self commonInit];
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self != nil )
    {
        [self commonInit];
    }
    return self;
}

- (void) commonInit
{
    // Load and configure the text field
    self.textField = [[UITextField alloc] initWithFrame:[self textFieldFrame]];
    [self configureTextField];
    [self.textField addTarget:self action:@selector(searchFieldEdited:) forControlEvents:UIControlEventEditingChanged];
    [self.textField addTarget:self action:@selector(searchFieldEditingDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
    [self.textField addTarget:self action:@selector(searchFieldEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
    self.textField.delegate = self;
    [self addSubview:self.textField];
    
    // Load and configure the suggestions view controller
    self.suggestionsViewController = [[UIStoryboard storyboardWithName:@"SDSearchSuggestions" bundle:nil] instantiateInitialViewController];
    self.suggestionsViewController.delegate = self;
}

- (CGRect) textFieldFrame
{
    CGRect bounds = self.bounds;
    CGFloat searchFieldXPadding = 80.0f;
    return CGRectMake(searchFieldXPadding, 0, CGRectGetWidth(bounds) - searchFieldXPadding, CGRectGetHeight(bounds) - 1);
}

- (CGRect) textFieldExpandedFrame
{
    CGRect bounds = self.bounds;
    return CGRectMake(0, 0, CGRectGetWidth(bounds), CGRectGetHeight(bounds) - 1);
}

- (void) configureTextField
{
    self.textField.font = [UIFont systemFontOfSize:14];
    self.textField.returnKeyType = UIReturnKeySearch;
    self.textField.enablesReturnKeyAutomatically = YES;
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.placeholder = NSLocalizedString(@"Search", @"Navigation Bar Search Field Placeholder");
    self.textField.accessibilityLabel = NSLocalizedString(@"Search", @"search field");
}

- (void) configureSuggestionsViewController
{
    
}

-(void) configureSearchSuggestionsViewController:(SDSearchSuggestionsViewController *)viewController
{
    [self configureSuggestionsViewController];
}

- (void) configureSuggestionTableCell:(UITableViewCell *)cell
{
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = [UIColor colorWithHexValue:@"#0091ff"];
}

- (void) configurePopover
{
    self.suggestionsPopover.backgroundColor = [UIColor colorWithHexValue:@"#e7e9ee"];
    self.suggestionsPopover.passthroughViews = @[ self.textField ];
}

- (void)searchFieldEdited:(UITextField*)searchTextField;
{
    self.suggestionsViewController.searchString = searchTextField.text;
    [self autoShowHidePopover];
}

- (void) clear
{
    self.textField.text = @"";
    [self configureForCollapse];
    [self collapse];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self configureForExpand];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ( self.canCollapse )
        [self configureForCollapse];
    
    return YES;
}

- (void) configureForExpand
{
    
}

- (void) configureForCollapse
{
    
}

- (BOOL)shouldShowPopover
{
    @strongify(self.suggestionDataSource, dataSource);
    
    return (self.textField.text.length > 0) || (dataSource.recentSearchStrings.count > 0);
}

- (void) autoShowHidePopover
{
    BOOL shouldShow = [self shouldShowPopover];
    BOOL isShowing = self.suggestionsPopover != nil && self.suggestionsPopover.isPopoverVisible;
    
    if ( shouldShow && !isShowing ) {
        [self.suggestionsPopover presentPopoverFromRect:self.frame inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else if ( !shouldShow && isShowing ) {
        [self.suggestionsPopover dismissPopoverAnimated:YES];
    }
}

- (void)searchFieldEditingDidBegin:(UITextField*)searchTextField;
{
    @strongify(self.usageDelegate, usageDelegate);
    
    [usageDelegate searchUserTappedSearchField:self];
    
    [self expand];
    
    if ( self.suggestionsPopover == nil )
    {
        self.suggestionsPopover = [[UIPopoverController alloc] initWithContentViewController:self.suggestionsViewController];
        self.suggestionsPopover.delegate = self;
        [self configurePopover];
    }
    
    self.suggestionsViewController.searchString = searchTextField.text;
    
    [self autoShowHidePopover];
}

- (void)searchFieldEditingDidEnd:(UITextField *)searchTextField
{
    if ( self.canCollapse )
        [self collapse];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    // If no focus, collapse now
    if ( !self.collapseRegardlessIfEmpty && ![self.textField isFirstResponder] )
        [self collapse];

    return YES;
}

- (BOOL) canCollapse
{
    return self.collapseRegardlessIfEmpty || (!self.collapseRegardlessIfEmpty && (self.textField.text == 0 || [self.textField.text length] == 0));
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    @strongify(self.usageDelegate, usageDelegate);

    [usageDelegate searchTypedInWithTerm:textField.text];
    
    [self searchForKeyword:textField.text];
    
    return YES;
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self.textField resignFirstResponder];
}

-(void)searchViewController:(SDSearchSuggestionsViewController *)searchViewController didSearchForKeyword:(NSString *)keyword
{
    [self searchForKeyword:keyword];
}

-(void)searchForKeyword:(NSString*)keyword
{
    self.textField.text = keyword;
    
    @strongify(self.suggestionDataSource, dataSource);
    [dataSource addRecentSearchString:keyword];
    
    @strongify(self.delegate, delegate);
    [delegate searchField:self performSearch:keyword];
    
    [self.suggestionsPopover dismissPopoverAnimated:YES];
    [self.textField resignFirstResponder];
}

- (void) collapse
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^
     {
         self.textField.frame = [self textFieldFrame];
     } completion:nil];
}

- (void) expand
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^
     {
         self.textField.frame = [self textFieldExpandedFrame];
     } completion:nil];
}

- (void) setUsageDelegate:(id<SDSearchUsageDelegate>)usageDelegate
{
    _usageDelegate = usageDelegate;
    self.suggestionsViewController.usageDelegate = usageDelegate;
}

- (void) setSuggestionDataSource:(id<SDSearchSuggestionsDataSource>)suggestionDataSource
{
    _suggestionDataSource = suggestionDataSource;
    self.suggestionsViewController.suggestionDataSource = suggestionDataSource;
}

@end
