//
//  SDQuantityEditView.m
//
//  Created by ricky cancro on 1/7/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "SDQuantityEditView.h"
#import "SDQuantityView.h"

@interface SDQuantityEditView()
@property (nonatomic, strong) NSLayoutConstraint *editTotalSpaceToTopContraint;
@property (nonatomic, strong) SDQuantityEditViewBehavior *quantityBehavior;
@property (nonatomic, assign) BOOL createdConstraints;

@property (nonatomic, strong, readwrite) UIImageView *dropShadowImageView;
@property (nonatomic, strong, readwrite) UIImageView *backgroundImageView;
@property (nonatomic, strong, readwrite) UILabel *totalPriceLabel;
@property (nonatomic, strong, readwrite) UILabel *weightLabel;
@property (nonatomic, strong, readwrite) SDQuantityView *quantityView;
@property (nonatomic, strong, readwrite) UIActivityIndicatorView *activitingIndicator;
@end


@implementation SDQuantityEditView

+ (instancetype)quantityEditView
{
    SDQuantityEditView *editView = [[[self class] alloc] initWithFrame:CGRectMake(0, 0, 320, 90)];
    return editView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)createDoneAndRemoveButtons
{
    self.removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.removeButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    
    self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.doneButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    
    [self updateDoneRemoveButtons:NO];
}

- (void)setup
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self createDoneAndRemoveButtons];
    self.activitingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    self.dropShadowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.dropShadowImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.dropShadowImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.dropShadowImageView];
    
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundImageView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.backgroundImageView];
    
    [self.removeButton setTitle:NSLocalizedString(@"Remove", @"Remove Button Title") forState:UIControlStateNormal];
    self.removeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.removeButton];
    
    [self.doneButton setTitle:NSLocalizedString(@"Done", @"Done Button Title") forState:UIControlStateNormal];
    self.doneButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.doneButton];
    
    self.activitingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.activitingIndicator];
    
    self.totalPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.totalPriceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.totalPriceLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [self addSubview:self.totalPriceLabel];
    
    self.weightLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.weightLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.weightLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [self addSubview:self.weightLabel];
    
    self.quantityView = [SDQuantityView quantityView];
    self.quantityView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.quantityView];
    self.quantityView.fillColor = [UIColor lightGrayColor];
    self.quantityView.quantityLabel.textColor = [UIColor darkTextColor];
    
    self.removeButton.alpha = 0.0f;
    self.activitingIndicator.hidesWhenStopped = YES;
    [self.activitingIndicator stopAnimating];
    
    [self.doneButton addTarget:self action:@selector(doneTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.removeButton addTarget:self action:@selector(removeTapped:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)updateConstraints
{
    if (!self.createdConstraints)
    {
        self.createdConstraints = YES;
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics:nil views:@{@"imageView":self.dropShadowImageView}]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundView]|" options:0 metrics:nil views:@{@"backgroundView":self.backgroundImageView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView(22)][backgroundView(68)]|" options:0 metrics:nil views:@{@"imageView":self.dropShadowImageView, @"backgroundView":self.backgroundImageView}]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(43)-[quantityView]" options:0 metrics:nil views:@{@"quantityView":self.quantityView}]];
        
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[totalLabel]-(10)-[quantityView(110)]-(12)-[removeButton]-(13)-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:@{@"totalLabel":self.totalPriceLabel, @"quantityView":self.quantityView, @"removeButton":self.removeButton}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[quantityView]-(20)-[doneButton]-(21)-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:@{@"quantityView":self.quantityView, @"doneButton":self.doneButton}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[spinner]-(38)-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:@{@"spinner":self.activitingIndicator}]];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[weightLabel]-(10)-[quantityView]"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:@{@"weightLabel":self.weightLabel, @"quantityView":self.quantityView}]];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[removeButton]-(17)-|" options:0 metrics:nil views:@{@"removeButton":self.removeButton}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[doneButton]-(17)-|" options:0 metrics:nil views:@{@"doneButton":self.doneButton}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[spinner]-(22)-|" options:0 metrics:nil views:@{@"spinner":self.activitingIndicator}]];
        
        NSArray *topConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(48)-[totalLabel]" options:0 metrics:nil views:@{@"totalLabel":self.totalPriceLabel}];
        self.editTotalSpaceToTopContraint = [topConstraints objectAtIndex:0];
        [self addConstraint:self.editTotalSpaceToTopContraint];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[totalPrice]-(-3)-[weight]" options:0 metrics:nil views:@{@"totalPrice":self.totalPriceLabel, @"weight":self.weightLabel}]];
    }
    [super updateConstraints];
}

- (void)updateDoneRemoveButtons:(BOOL)animated
{
    if (animated)
    {
        [UIView beginAnimations:nil context:NULL];
    }
    
    if (self.quantityBehavior.updatedQuantity)
    {
        if ([self.quantityBehavior.updatedQuantity doubleValue] > 0)
        {
            self.doneButton.alpha = 1.0f;
            self.removeButton.alpha = 0.0f;
        }
        else if ([self.quantityBehavior.updatedQuantity doubleValue] == 0)
        {
            self.doneButton.alpha = 0.0f;
            self.removeButton.alpha = 1.0f;
        }
    }
    else
    {
        self.doneButton.alpha = 1.0f;
        self.removeButton.alpha = 0.0f;
    }
    
    if (animated)
    {
        [UIView commitAnimations];
    }
}

- (SDQuantityEditViewBehavior *)defaultQuantityBehavior
{
    return [[SDQuantityEditViewBehavior alloc] initWithAdjustableItem:self.adjustableItem delegate:self];
}


- (void)setAdjustableItem:(id<SDAdjustableItem>)adjustableItem
{
    _adjustableItem = adjustableItem;
    self.quantityBehavior = [self defaultQuantityBehavior];
    
    @weakify(self);
    self.quantityBehavior.didChangeQuantity = ^(BOOL increment) {
        @strongify(self);
        [self updateDoneRemoveButtons:YES];
    };
    
    [self updateDoneRemoveButtons:NO];
    
    switch ([adjustableItem adjustQuantityMethod])
    {
        case kAdjustableItemQuantityMethod_Counted:
        case kAdjustableItemQuantityMethod_Weighted:
            self.editTotalSpaceToTopContraint.constant = 48.0f;
            break;
            
        case kAdjustableItemQuantityMethod_Both:
            self.editTotalSpaceToTopContraint.constant = 42.0f;
            break;
            
    }
    [self layoutIfNeeded];
}

- (void)setCommitting:(BOOL)committing
{
    _committing = committing;
    if (committing)
    {
        self.doneButton.hidden = YES;
        self.removeButton.hidden = YES;
        [self.activitingIndicator startAnimating];
        self.quantityView.alpha = 0.4f;
        
        self.quantityView.userInteractionEnabled = NO;
        self.totalPriceLabel.alpha = 0.4f;
        self.weightLabel.alpha = 0.4;
    }
    else
    {
        self.doneButton.hidden = NO;
        self.removeButton.hidden = YES;
        [self.activitingIndicator stopAnimating];
        
        self.quantityView.alpha = 1.0f;
        self.quantityView.userInteractionEnabled = YES;
        self.totalPriceLabel.alpha = 1.0f;
        self.weightLabel.alpha = 1.0;
    }
}

- (void)removeTapped:(id)sender
{
    [self setCommitting:YES];
    if (self.removeTappedBlock)
    {
        self.removeTappedBlock(self.quantityBehavior.originalQuantity);
    }
}

- (void)doneTapped:(id)sender
{
    [self setCommitting:YES];
    if (self.doneTappedBlock)
    {
        self.doneTappedBlock(self.quantityBehavior.originalQuantity, self.quantityBehavior.updatedQuantity);
    }
}

#pragma mark - SDQuantityEditViewProtocol

- (UIButton *)plusButton
{
    return self.quantityView.incrementButton;
}

- (UIButton *)minusButton
{
    return self.quantityView.decrementButton;
}

- (UILabel *)quantityLabel
{
    return self.quantityView.quantityLabel;
}

- (UILabel *)totalWeightLabel
{
    switch (self.adjustableItem.adjustQuantityMethod)
    {
        case kAdjustableItemQuantityMethod_Weighted:
            return self.quantityView.quantityLabel;
            
        case kAdjustableItemQuantityMethod_Both:
            return self.weightLabel;
            
        default:
            return nil;
    }
}


@end
