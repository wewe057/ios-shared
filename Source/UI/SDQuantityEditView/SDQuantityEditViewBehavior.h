//
//  SDQuantityEditViewBehavior.h
//
//  Created by Robb Albright on 17.4.12.
//  Copyright (c) 2012 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDAdjustableItem.h"

/**
 A protocol that a view that wants to use a SDQuantityEditViewBehavior must conform to.
 */
@protocol SDQuantityEditViewProtocol

/**
 Returns the EditView's plus button
 */
- (UIButton *)plusButton;

/**
 Returns the EditView's minus button
 */
- (UIButton *)minusButton;

/**
 Returns the EditView's label that displays current quantity
 */
- (UILabel *)quantityLabel;

/**
 Returns the EditView's label that displays current cost
 */
- (UILabel *)totalPriceLabel;

/**
 Returns the EditView's label that displays current weight
 */
- (UILabel *)totalWeightLabel;
@end

/**
 A class that handles the logic behind incrementing and decrementing an AdjustableItem depending on the type of SDProductQuantityMethod 
 the adjustableItem supports.
 
 If none of the SDProductQuantityMethod provide what you need, you can subclass this behavior and customize how the item's quantity is changed.
 You should also subclass SDEditQuantityView so that defaultQuantityBehavior returns the proper behavior.
 */
@interface SDQuantityEditViewBehavior : NSObject

/**
 The quantity of the adjustableItem when this behavior was created.  This can be reset by a client if needed.
 */
@property (nonatomic, copy) NSDecimalNumber *originalQuantity;

/**
 The new quantity of the adjustableItem.  Note this is nil if there is no change in quantity.
 */
@property (nonatomic, copy, readonly) NSDecimalNumber *updatedQuantity;


/**
 The suffix on the quantity.  This is only used for kAdjustableItemQuantityMethod_Weighted and defaults to "kg".
 */
@property (nonatomic, copy) NSString *quantitySuffix;

/**
 The formatter used to display the total price of the adjustableItem.  This defaults to using £ as the currency symbol.
 */
@property (nonatomic, strong) NSNumberFormatter *priceFormatter;

/**
 A block called when the adjustableItem is about to change quantity.
 @param incremented YES if the value will be incremented.  NO if it will be decremented
 */
@property (nonatomic, copy) void (^willChangeQuantity)(BOOL incremented);

/**
 A block called when the adjustableItem changed quantity
 @param incremented YES if the value incremented.  NO if decremented
 */
@property (nonatomic, copy) void (^didChangeQuantity)(BOOL incremented);

/**
 Creates a new SDQuantityEditViewBehavior with the given adjustableItem and SDQuantityEditViewProtocol
 */
- (id)initWithAdjustableItem:(id<SDAdjustableItem>)adjustableItem delegate:(UIView<SDQuantityEditViewProtocol> *)delegate;

/**
 NOTE: These should probably not be exposed.  We are using them in a case where we are reseting the original quantity of the
 behavior.  Instead we should really either create a new behavior or add a new method to "reset" the behavior so
 that it doesn't need to access these methods.
 TODO: Remove these when this behavior is updated.
 */
- (void)updateTotalCost;
- (void)updateTotalWeight;
- (void)updateButtonState;
@end
