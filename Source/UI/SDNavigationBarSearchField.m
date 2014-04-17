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
    if ( self != nil ) {
        [self commonInit];
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self != nil ) {
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
    self.textField.delegate = self;
    [self addSubview:self.textField];
    
    // Load and configure the suggestions view controller
    self.suggestionsViewController = [[UIStoryboard storyboardWithName:@"SDSearchSuggestions" bundle:nil] instantiateInitialViewController];
    self.suggestionsViewController.delegate = self;
    [self configureSuggestionsViewController];
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
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.placeholder = NSLocalizedString(@"Search", @"Navigation Bar Search Field Placeholder");
    self.textField.accessibilityLabel = NSLocalizedString(@"Search", @"search field");
}

- (void) configureSuggestionsViewController
{
    
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
}

- (void)searchFieldEditingDidBegin:(UITextField*)searchTextField;
{
    @strongify(self.usageDelegate, usageDelegate);
    
    [usageDelegate searchUserTappedSearchField:self];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^
     {
         self.textField.frame = [self textFieldExpandedFrame];
     } completion:nil];
    
    if(!self.suggestionsPopover)
    {
        self.suggestionsPopover = [[UIPopoverController alloc] initWithContentViewController:self.suggestionsViewController];
        self.suggestionsPopover.delegate = self;
        [self configurePopover];
    }
    
    self.suggestionsViewController.searchString = searchTextField.text;
    
    [self.suggestionsPopover presentPopoverFromRect:self.frame inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
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
    [self collapseTextField];
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
    [self collapseTextField];
}

- (void) collapseTextField
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^
     {
         self.textField.frame = [self textFieldFrame];
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
