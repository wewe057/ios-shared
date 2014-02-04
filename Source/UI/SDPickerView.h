//
//  SDPickerView.h
//
//  Created by Douglas Pedley on 12/13/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SDPickerViewDateCompletionBlock)(BOOL canceled, NSDate *selectedDate);
typedef void(^SDPickerViewItemSelectionCompletionBlock)(BOOL canceled, NSInteger selectedItemIndex, NSString *selectedItem);

@interface SDPickerView : UIButton

-(void)configureAsDatePickerWithCompletion:(SDPickerViewDateCompletionBlock)completion;
-(void)configureAsDatePicker:(NSDate *)initialDate completion:(SDPickerViewDateCompletionBlock)completion;
-(void)configureAsDatePicker:(NSDate *)initialDate datePickerMode:(UIDatePickerMode)datePickerMode completion:(SDPickerViewDateCompletionBlock)completion;

-(void)configureAsItemPicker:(NSArray<NSString>*)items completion:(SDPickerViewItemSelectionCompletionBlock)completion;
-(void)configureAsItemPicker:(NSArray<NSString>*)items initialItem:(NSInteger)selectedItem completion:(SDPickerViewItemSelectionCompletionBlock)completion;

@end
