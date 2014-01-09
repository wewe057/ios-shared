//
//  SDQuantityEditViewBehavior.m
//
//  Created by Robb Albright on 17.4.12.
//  Copyright (c) 2012 SetDirection. All rights reserved.
//

#import "SDQuantityEditViewBehavior.h"

@implementation NSDecimalNumber (CurrencyExtension)

+(NSDecimalNumber*)decimalNumberWithCurrencyString:(NSString *)currencyString
{
    NSString *numeralsOnlyString = [currencyString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"$£ "]];
    numeralsOnlyString = [numeralsOnlyString stringByReplacingOccurrencesOfString: @"," withString:@""]; //Localize note: assumes full-stop for decimal separator
    NSDecimalNumber *outNumber = [NSDecimalNumber decimalNumberWithString:numeralsOnlyString];
    return outNumber;
}

@end

static char kObserveQuantityContext;

@interface SDQuantityEditViewBehavior ()

@property (nonatomic, copy, readwrite) NSDecimalNumber *updatedQuantity; // nil if not different
@property (nonatomic, copy, readwrite) NSDecimalNumber *currentQuantity;

@property (nonatomic, copy) NSDecimalNumber *stepAmount;
@property (nonatomic, copy) NSDecimalNumber *maxQuantity;
@property (nonatomic, copy) NSDecimalNumber *pricePerUnit;
@property (nonatomic, strong) NSDecimalNumberHandler* roundingBehavior;
@property (nonatomic, assign) SDProductQuantityMethod adjustQuantityMethod;
@property (nonatomic, weak) UIView<SDQuantityEditViewProtocol> *quantityViewDelegate;
@property (nonatomic, copy) NSDecimalNumber *avgWeight;

@end

@implementation SDQuantityEditViewBehavior

- (id)initWithAdjustableItem:(id<SDAdjustableItem>)adjustableItem delegate:(UIView<SDQuantityEditViewProtocol> *)delegate;
{
    self = [super init];
    if (self)
    {
        
        _quantityViewDelegate = delegate;
        @strongify(_quantityViewDelegate, viewDelegate);
        
        _adjustQuantityMethod = [adjustableItem adjustQuantityMethod];
        [viewDelegate.plusButton addTarget:self action:@selector(incrementAction:) forControlEvents:UIControlEventTouchUpInside];
        [viewDelegate.minusButton addTarget:self action:@selector(decrementAction:) forControlEvents:UIControlEventTouchUpInside];
        
        
        if (_adjustQuantityMethod == kAdjustableItemQuantityMethod_Weighted) {
            _quantitySuffix = @"kg";
            _stepAmount = [NSDecimalNumber decimalNumberWithString:@"0.1"];
        }
        else {
            _quantitySuffix = @"";
            _stepAmount = [NSDecimalNumber decimalNumberWithString:@"1"];
        }
        
        // We always start with one step unit if the product is not already in the trolley
        if ([adjustableItem respondsToSelector:@selector(quantity)] && [adjustableItem quantity]) {
            _originalQuantity = _currentQuantity = [NSDecimalNumber decimalNumberWithString:[adjustableItem quantity]];
        }
        else {
            _originalQuantity = [NSDecimalNumber decimalNumberWithString:@"0"];
            _currentQuantity = [_originalQuantity decimalNumberByAdding:_stepAmount];
        }
        
        if ([adjustableItem maxQuantity]) {
            _maxQuantity = [NSDecimalNumber decimalNumberWithString:[adjustableItem maxQuantity]];
        }
        else {
            _maxQuantity = [NSDecimalNumber decimalNumberWithString:@"24"]; // 24 is the usual max quantity
        }
        
        if ([adjustableItem pricePerUnitOfMeasure]) {
            _pricePerUnit = [NSDecimalNumber decimalNumberWithCurrencyString:[adjustableItem pricePerUnitOfMeasure]];
        }
        else {
            SDLog(@"NO price per unit given!");
            viewDelegate.totalPriceLabel.hidden = YES;
        }
        
        if(_adjustQuantityMethod == kAdjustableItemQuantityMethod_Both && [adjustableItem respondsToSelector:@selector(averageWeight)])
        {
            _avgWeight = [NSDecimalNumber decimalNumberWithCurrencyString:[adjustableItem averageWeight]];
            _maxQuantity = [_maxQuantity decimalNumberByDividingBy:_avgWeight];
            _pricePerUnit = [_pricePerUnit decimalNumberByMultiplyingBy:_avgWeight];
        }
        
        _roundingBehavior =  [[NSDecimalNumberHandler alloc] initWithRoundingMode:NSRoundPlain scale:1 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
        
        [self updateTotalCost];
        [self updateQuantityLabel];
        [self updateButtonState];
        
        // observe our quantity to update the displayed quantity and expanded price
        [self addObserver:self forKeyPath:@"currentQuantity" options:NSKeyValueObservingOptionNew context:&kObserveQuantityContext];
        [self updateTotalWeight];
    }
    return self;
}

-(void)dealloc
{
    @strongify(_quantityViewDelegate, viewDelegate);
    [self removeObserver:self forKeyPath:@"currentQuantity"];
    self.roundingBehavior = nil;
    [viewDelegate removeFromSuperview];
    [viewDelegate.plusButton removeTarget:self action:@selector(incrementAction:) forControlEvents:UIControlEventTouchUpInside];
    [viewDelegate.minusButton removeTarget:self action:@selector(decrementAction:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setOriginalQuantity:(NSDecimalNumber *)newOriginalQuantity
{
    @strongify(_quantityViewDelegate, viewDelegate);
    _originalQuantity = [newOriginalQuantity copy];
    if ([self.quantitySuffix length]) {
        viewDelegate.quantityLabel.text = [NSString stringWithFormat: @"%@ %@", _originalQuantity.stringValue, self.quantitySuffix];
    }
    else {
        viewDelegate.quantityLabel.text = _originalQuantity.stringValue;
    }
    
}

-(void)updateQuantityLabel
{
    @strongify(_quantityViewDelegate, viewDelegate);
    if ([self.quantitySuffix length]) {
        viewDelegate.quantityLabel.text = [NSString stringWithFormat: @"%@ %@", self.currentQuantity.stringValue, self.quantitySuffix];
    }
    else {
        viewDelegate.quantityLabel.text = self.currentQuantity.stringValue;
    }
}


- (void)updateButtonState
{
    @strongify(_quantityViewDelegate, viewDelegate);
    // plus only on if quantity is less than max
    NSComparisonResult maxResult;
    if (self.adjustQuantityMethod == kAdjustableItemQuantityMethod_Both) {
        maxResult = [self.maxQuantity compare:[self.currentQuantity decimalNumberByAdding:self.stepAmount]];
    } else {
        maxResult = [self.maxQuantity compare:self.currentQuantity];
    }
    viewDelegate.plusButton.enabled = ( maxResult == NSOrderedDescending);
    
    // minus on only if quantity is more than the min
    NSComparisonResult minResult = [[NSDecimalNumber zero] compare:self.currentQuantity];
    viewDelegate.minusButton.enabled = ( minResult == NSOrderedAscending);
}


-(IBAction)incrementAction:(id)sender
{
    if (self.willChangeQuantity)
    {
        self.willChangeQuantity(YES);
    }
    
    self.currentQuantity = [self.currentQuantity decimalNumberByAdding:self.stepAmount];
    // When server adjusts quantity based on average, the step can be 2 decimal places, round it to 1
    self.currentQuantity = [self.currentQuantity decimalNumberByRoundingAccordingToBehavior:self.roundingBehavior];
    [self updateButtonState];
    [self updateTotalCost];
    [self updateTotalWeight];
    
    if (self.didChangeQuantity)
    {
        self.didChangeQuantity(YES);
    }
}


-(IBAction)decrementAction:(id)sender
{
    if (self.willChangeQuantity)
    {
        self.willChangeQuantity(NO);
    }
    
    self.currentQuantity = [self.currentQuantity decimalNumberBySubtracting:self.stepAmount];
    // When server adjusts quantity based on average, the step can be 2 decimal places, round it to 1
    self.currentQuantity = [self.currentQuantity decimalNumberByRoundingAccordingToBehavior:self.roundingBehavior];
    // and could go below zero
    if ([self.currentQuantity compare:[NSDecimalNumber zero]] == NSOrderedAscending ) {
        self.currentQuantity = [NSDecimalNumber zero];
    }
    [self updateButtonState];
    [self updateTotalCost];
    [self updateTotalWeight];
    
    if (self.didChangeQuantity)
    {
        self.didChangeQuantity(NO);
    }
}

-(void)updateTotalCost
{
    if (!self.priceFormatter)
    {
        self.priceFormatter = [[NSNumberFormatter alloc] init];
        
        // Trolley Details Cell version
        [self.priceFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
        [self.priceFormatter setCurrencySymbol: @"£"];
        [self.priceFormatter setCurrencyGroupingSeparator: @","];
        [self.priceFormatter setGroupingSize: 3];
        [self.priceFormatter setCurrencyDecimalSeparator: @"."];
        
        [self.priceFormatter setGeneratesDecimalNumbers: YES];
    }
    
    if (self.pricePerUnit && self.currentQuantity) {
        // We may have empty(NaN) ppu, so guard against an exception in decimalNumberBy…
        if ([self.pricePerUnit isEqualToNumber:[NSDecimalNumber notANumber]] || [self.pricePerUnit isEqualToNumber:[NSDecimalNumber maximumDecimalNumber]] || [self.currentQuantity isEqualToNumber:[NSDecimalNumber notANumber]] || [self.currentQuantity isEqualToNumber:[NSDecimalNumber maximumDecimalNumber]]) {
            SDLog(@"WARNING - bad input to price per unit or current quantity");
            SDLog(@"price per unit: %f", [self.pricePerUnit doubleValue]);
            SDLog(@"current quantity: %f", [self.currentQuantity doubleValue]);
            return;
        }
        
        NSDecimalNumber *total = [self.pricePerUnit decimalNumberByMultiplyingBy:self.currentQuantity];
        self.quantityViewDelegate.totalPriceLabel.text = [self.priceFormatter stringFromNumber:total];
    }
}

-(void)updateTotalWeight {
    if (self.adjustQuantityMethod == kAdjustableItemQuantityMethod_Both) {
        @strongify(_quantityViewDelegate, viewDelegate);
        NSDecimalNumber *totalWeight = [self.currentQuantity decimalNumberByMultiplyingBy:self.avgWeight];
        //push totalWeight to IQV's totalWeightLabel
        SDLog(@"total weight is now %@ kg", [totalWeight stringValue]);
        viewDelegate.totalWeightLabel.text = [NSString stringWithFormat:@"~%@ kg", [totalWeight stringValue]];
    }
}

/// Returns the new quantity if it has been updated, or nil if it hasn't
-(NSDecimalNumber *)updatedQuantity
{
    NSDecimalNumber *result = nil;
    if (! [self.currentQuantity isEqualToNumber:self.originalQuantity]) {
        result = self.currentQuantity;
    }
    return result;
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &kObserveQuantityContext) {
        if ([[change valueForKey:NSKeyValueChangeKindKey] integerValue] == NSKeyValueChangeSetting) {
            NSDecimalNumber *newValue = (NSDecimalNumber*)[change objectForKey:NSKeyValueChangeNewKey];
            SDLog(@"Quantity Changed to %f", [newValue floatValue]);
            
            @strongify(_quantityViewDelegate, viewDelegate);
            if([self.quantitySuffix length]) {
                viewDelegate.quantityLabel.text = [NSString stringWithFormat: @"%@ %@", [newValue stringValue], self.quantitySuffix];
            }
            else {
                viewDelegate.quantityLabel.text = [newValue stringValue];
            }
        }
    }
}
@end


