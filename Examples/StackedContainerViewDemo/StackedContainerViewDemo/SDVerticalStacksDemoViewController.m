//
//  SDVerticalStacksDemoViewController.m
//  StackedContainerViewDemo
//
//  Created by Tim Trautmann on 1/28/14.
//  Copyright (c) 2014 SetDirection All rights reserved.
//

#import "SDVerticalStacksDemoViewController.h"

// Views
#import "SDAutolayoutStackView.h"
#import "SDDemoBoxView.h"

@interface SDVerticalStacksDemoViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) SDAutolayoutStackView *stackView;
@property (nonatomic, strong) NSArray *views;
@end

@implementation SDVerticalStacksDemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.stackView = [[SDAutolayoutStackView alloc] init];
    self.stackView.translatesAutoresizingMaskIntoConstraints = NO;
    self.stackView.edgeInsets = UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0);
    self.stackView.gap = 50.0f;
    self.stackView.backgroundColor = @"#dddddd".uicolor;
    [self.scrollView addSubview:self.stackView];
    
    self.views = @[];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    NSDictionary *views = NSDictionaryOfVariableBindings(_stackView);
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.stackView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_stackView]|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:views]];
    
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_stackView]|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:views]];
}

- (IBAction)addItemTapped:(id)sender {
    static NSUInteger count = 0;
    
    SDDemoBoxView *view = [SDDemoBoxView loadFromNib];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.backgroundColor = [self getColor];
    view.boxLabel.text = [NSString stringWithFormat:@"Box: %lu", (unsigned long)count];
    
    self.views = [self.views arrayByAddingObject:view];
    count++;
    
    [self.stackView addSubview:view];
    
    [view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:40.0]];
    
}

- (IBAction)removeItemTapped:(id)sender {
    SDDemoBoxView *view = [self.views firstObject];
    [view removeFromSuperview];
    
    if (self.views.count > 1)
    {
        self.views = [self.views subarrayWithRange:NSMakeRange(1, self.views.count - 1)];
    }
    else {
        self.views = @[];
    }
}

- (UIColor *)getColor
{
    static NSUInteger count = 0;
    NSArray *colors = @[[UIColor redColor], [UIColor greenColor], [UIColor orangeColor], [UIColor purpleColor], [UIColor brownColor], [UIColor yellowColor]];
    return [colors objectAtIndex:count++ % [colors count]];
}
@end
