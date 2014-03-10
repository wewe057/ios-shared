//
//  SDViewController.m
//  SDTimerTest
//
//  Created by Steven Woolgar on 02/26/2014.
//  Copyright (c) 2014 Wal-mart Stores, Inc. All rights reserved.
//

#import "SDViewController.h"

#import "SDTimer.h"

@interface SDViewController ()

@property (nonatomic, strong) IBOutlet UIButton* repeatingTimerButton;
@property (nonatomic, strong) IBOutlet UIButton* oneTimeTimerButton;

@property (nonatomic, strong) IBOutlet UILabel* statusLabel;

@property (nonatomic, strong) SDTimer* oneTimeTimer;
@property (nonatomic, strong) SDTimer* repeatingTimer;

@end

@implementation SDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)tappedRepeatingTimerButton:(id)sender
{
    self.statusLabel.text = @"Starting repeating timer...";
    __block NSUInteger count = 0;

    self.repeatingTimer = [SDTimer timerWithInterval:2
                                             repeats:YES
                                          timerBlock:^(SDTimer *aTimer)
    {
        SDLog(@"Fired repeating timer #%tu...", count++);
        if(count == 5)
        {
            [self.repeatingTimer invalidate];
            self.statusLabel.text = @"Finished firing repeating timers";
            SDLog(@"Finished firing repeating timers");
            [self.statusLabel setNeedsDisplay];
        }
    }];
}

- (IBAction)tappedOneTimeTimerButton:(id)sender
{
    SDLog(@"Starting one time timer...");
    self.oneTimeTimer = [SDTimer timerWithInterval:2
                                           repeats:NO
                                        timerBlock:^(SDTimer *aTimer)
    {
        SDLog(@"Fired one time timer...");
    }];
}

@end
