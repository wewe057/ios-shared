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
    IBOutlet UIBarButtonItem *doneButton;
    IBOutlet UIBarButtonItem *cancelButton;
    IBOutlet UIPickerView *pickerView;
    IBOutlet UIToolbar *toolbar;
    IBOutlet UIView *backgroundView;
    
    SDPickerBlock doneBlock;
    SDPickerBlock cancelBlock;
}

@property (nonatomic, readonly) UIToolbar *toolbar;
@property (nonatomic, readonly) UIPickerView *pickerView;
@property (nonatomic, readonly) UIBarButtonItem *doneButton;
@property (nonatomic, readonly) UIBarButtonItem *cancelButton;

- (id)init;

- (void)presentModallyFromViewController:(UIViewController *)controller onDone:(SDPickerBlock)done onCancel:(SDPickerBlock)cancel;

@end
