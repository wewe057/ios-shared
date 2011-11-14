//
//  SDPickerModalViewController.m
//  walmart
//
//  Created by brandon on 4/29/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import "SDPickerModalViewController.h"
#import "CheckpointLog.h"


@implementation SDPickerModalViewController

@synthesize toolbar;
@synthesize pickerView;
@synthesize doneButton;
@synthesize cancelButton;

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        [self view];
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    toolbar = nil;
    pickerView = nil;
    cancelButton = nil;
    doneButton = nil;
    backgroundView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [CheckpointLog passCheckpointVCDidAppearWithFilePath:__FILE__];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)presentModallyFromViewController:(UIViewController *)controller onDone:(SDPickerBlock)done onCancel:(SDPickerBlock)cancel
{
    [self presentModallyFromViewController:controller onDone:done onCancel:cancel withSelectedRow:-1 inComponent:-1];
}

- (void)presentModallyFromViewController:(UIViewController *)controller onDone:(SDPickerBlock)done onCancel:(SDPickerBlock)cancel withSelectedRow:(int)row inComponent:(int)component
{
    doneBlock = [done copy];
    cancelBlock = [cancel copy];
    
    backgroundView.alpha = 0;
    
    UIWindow *window = controller.view.window;
    
    CGRect mainFrame = self.view.frame;
    mainFrame.origin.y = 20;
    self.view.frame = mainFrame;
    
    CGRect toolbarFrame = toolbar.frame;
    CGRect toolbarStartFrame = toolbarFrame;
    toolbarFrame.origin.y = mainFrame.size.height;
    toolbar.frame = toolbarFrame;
    
    CGRect pickerFrame = pickerView.frame;
    CGRect pickerStartFrame = pickerFrame;
    pickerFrame.origin.y = mainFrame.size.height + toolbarFrame.size.height;
    pickerView.frame = pickerFrame;
        
    [window addSubview:self.view];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    backgroundView.alpha = 0.7;
    toolbar.frame = toolbarStartFrame;
    pickerView.frame = pickerStartFrame;
    
    [UIView commitAnimations];
    
    // Default to a selected row in component
    if ( (row > -1) && (component > -1) ) {
        [pickerView selectRow:row inComponent:component animated:NO];
    }
}

- (void)dismiss
{
    CGRect toolbarFrame = toolbar.frame;
    toolbarFrame.origin.y = 480;
    
    CGRect pickerFrame = pickerView.frame;
    pickerFrame.origin.y = 480 + toolbarFrame.size.height;

    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState animations:^(void) {
        backgroundView.alpha = 0.0;
        toolbar.frame = toolbarFrame;
        pickerView.frame = pickerFrame;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

- (IBAction)cancelAction:(id)sender
{
    cancelBlock();
    [self dismiss];
}

- (IBAction)doneAction:(id)sender
{
    doneBlock();
    [self dismiss];
}

@end
