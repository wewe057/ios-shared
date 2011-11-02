//
//  SDPickerModalViewController.h
//  walmart
//
//  Created by brandon on 4/29/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SDPickerBlock)(void);

@interface SDPickerModalViewController : UIViewController
{
	UIBarButtonItem *doneButton;
    UIBarButtonItem *cancelButton;
    UIPickerView *pickerView;
    UIToolbar *toolbar;
    UIView *backgroundView;
    
    SDPickerBlock doneBlock;
    SDPickerBlock cancelBlock;
}

@property (nonatomic, strong, readonly) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong, readonly) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong, readonly) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, strong, readonly) IBOutlet UIBarButtonItem *cancelButton;

- (id)init;

- (void)presentModallyFromViewController:(UIViewController *)controller onDone:(SDPickerBlock)done onCancel:(SDPickerBlock)cancel;
- (void)presentModallyFromViewController:(UIViewController *)controller onDone:(SDPickerBlock)done onCancel:(SDPickerBlock)cancel withSelectedRow:(int)row inComponent:(int)component;

@end
