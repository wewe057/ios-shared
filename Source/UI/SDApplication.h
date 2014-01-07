//
//  SDApplication.h
//
//  Created by Brandon Sneed on 1/6/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDApplication : UIApplication

+ (instancetype)sharedApplication;

- (void)addIdleTimeout:(NSTimeInterval)timeoutInterval controller:(UIViewController *)controller handlerBlock:(NSObjectPerformBlock)handlerBlock;
- (void)removeIdleTimeoutForController:(UIViewController *)controller;
- (void)cleanupIdleTimers;

@end

int SDApplicationMain(int argc, char *argv[], NSString *delegateClassName);
