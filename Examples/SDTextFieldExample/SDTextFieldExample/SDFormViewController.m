//
//  SDFormViewController.m
//  SDTextFieldExample
//
//  Created by Brandon Sneed on 1/23/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "SDFormViewController.h"
#import "SDNumberTextField.h"

@interface SDFormViewController ()
@property (weak, nonatomic) IBOutlet SDTextField *name1Field;
@property (weak, nonatomic) IBOutlet SDTextField *name2Field;
@property (weak, nonatomic) IBOutlet SDTextField *name3Field;
@property (weak, nonatomic) IBOutlet SDNumberTextField *number1Field;
@property (weak, nonatomic) IBOutlet SDNumberTextField *number2Field;
@property (weak, nonatomic) IBOutlet SDNumberTextField *number3Field;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end

@implementation SDFormViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.name2Field.validationBlock = ^BOOL (SDTextField *textField) {
        if ([textField.text rangeOfString:@"@"].location != NSNotFound && [textField.text rangeOfString:@"."].location != NSNotFound)
            return YES;
        return NO;
    };
    
    self.name3Field.validationBlock = ^BOOL (SDTextField *textField) {
        NSCharacterSet *numericSet = [NSCharacterSet decimalDigitCharacterSet];
        NSCharacterSet *letterSet = [NSCharacterSet letterCharacterSet];
        
        BOOL hasNumbers = [textField.text rangeOfCharacterFromSet:numericSet options:0].location != NSNotFound;
        BOOL hasLetters = [textField.text rangeOfCharacterFromSet:letterSet options:0].location != NSNotFound;
        
        return (hasNumbers && hasLetters);
    };
    
    self.number1Field.format = @"##/##/####";
    self.number2Field.format = @"(###) ###-####";
    self.number2Field.validateWhileTyping = YES;
    self.number2Field.validationBlock = ^BOOL (SDTextField *textField) {
        BOOL result = (textField.text.length == 14);
        if (result)
            self.submitButton.enabled = YES;
        else
            self.submitButton.enabled = NO;
        return result;
    };

    self.number3Field.format = @"#.##.###";
    self.number3Field.validationBlock = ^BOOL (SDTextField *textField) {
        // so long as there's a dot, we're good.
        if ([textField.text rangeOfString:@"."].location != NSNotFound)
            return YES;
        return NO;
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // validateFields cycles through any fields attached via nextTextField and previousTextField
    if ([self.name1Field validateFields])
        self.submitButton.enabled = YES;
    else
        self.submitButton.enabled = NO;
}

- (IBAction)submitAction:(id)sender
{
    [SDAlertView showAlertWithTitle:@"Fields validated" message:@"Enjoy your validated fields.  N'shit."];
}

@end
