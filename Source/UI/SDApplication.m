//
//  SDApplication.m
//
//  Created by Brandon Sneed on 1/6/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "SDApplication.h"
#import "SDTimer.h"

#pragma mark - SDWindowAction

@interface SDApplicationAction : NSObject

@property (nonatomic, copy) NSObjectPerformBlock handlerBlock;
@property (nonatomic, weak) UIViewController *controller;

- (void)performActionBlock;

@end

@implementation SDApplicationAction

- (void)performActionBlock
{
    if (self.handlerBlock && self.controller)
    {
        NSObjectPerformBlock tempHandlerBlock = [self.handlerBlock copy];
        tempHandlerBlock();
    }
}

@end

#pragma mark - SDWindowTimeout

@interface SDApplicationTimeoutAction : SDApplicationAction

@property (nonatomic, assign) NSTimeInterval timeoutInterval;

- (void)startTimeoutMonitor;
- (void)stopTimeoutMonitor;

@end


@implementation SDApplicationTimeoutAction
{
    NSTimer *_internalTimer;
}

- (void)startTimeoutMonitor
{
    [_internalTimer invalidate];
    /*_internalTimer = [[SDTimer alloc] initWithInterval:self.timeoutInterval repeats:YES timerBlock:^(SDTimer *aTimer) {
        // maybe i'm being paranoid by checking this, but oh well.
        if (aTimer == _internalTimer)
            [self performTimeoutBlock];
    }];*/
    
    _internalTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeoutInterval target:self selector:@selector(performActionBlock) userInfo:nil repeats:YES];
}

- (void)stopTimeoutMonitor
{
    [_internalTimer invalidate];
    _internalTimer = nil;
}

- (void)resetTimeoutMonitor
{
    [self stopTimeoutMonitor];
    [self startTimeoutMonitor];
}

@end

#pragma mark - SDWindow implementation

@implementation SDApplication
{
    NSMutableArray *_timeoutHandlers;
    NSMutableArray *_backgroundHandlers;
}

+ (instancetype)sharedApplication
{
    return (SDApplication *)[super sharedApplication];
}

- (id)init
{
    self = [super init];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEnteredBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    return self;
}

- (void)dealloc
{
    // [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

#pragma mark - Idle Timeout Methods

- (void)addIdleTimeout:(NSTimeInterval)timeoutInterval controller:(UIViewController *)controller handlerBlock:(NSObjectPerformBlock)handlerBlock
{
    @synchronized(self)
    {
        if (!_timeoutHandlers)
            _timeoutHandlers = [NSMutableArray array];
        
        SDApplicationTimeoutAction *timeoutHandler = [[SDApplicationTimeoutAction alloc] init];
        timeoutHandler.timeoutInterval = timeoutInterval;
        timeoutHandler.controller = controller;
        timeoutHandler.handlerBlock = handlerBlock;
        
        [_timeoutHandlers addObject:timeoutHandler];
        [timeoutHandler startTimeoutMonitor];
    }
}

- (void)cleanupIdleTimers
{
    @synchronized(self)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"controller=nil"];
        NSArray *itemsToRemove = [_timeoutHandlers filteredArrayUsingPredicate:predicate];
        
        if (itemsToRemove.count > 0)
        {
            [_timeoutHandlers removeObjectsInArray:itemsToRemove];
            [itemsToRemove makeObjectsPerformSelector:@selector(stopTimeoutMonitor)];
        }
    }
}

- (void)removeIdleTimeoutsForController:(UIViewController *)controller
{
    @synchronized(self)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"controller==%@", controller];
        NSArray *itemsToRemove = [_timeoutHandlers filteredArrayUsingPredicate:predicate];
        
        if (itemsToRemove.count > 0)
        {
            [_timeoutHandlers removeObjectsInArray:itemsToRemove];
            [itemsToRemove makeObjectsPerformSelector:@selector(stopTimeoutMonitor)];
        }
    }
}

- (void)checkForTimerResets:(UIEvent *)event
{
    if (_timeoutHandlers.count < 1)
        return;
    
    NSSet *touches = [event allTouches];
    if (touches.count < 1)
        return;
    
    [_timeoutHandlers makeObjectsPerformSelector:@selector(resetTimeoutMonitor)];
}

#pragma mark - Backgrounding Action methods

/*- (void)addActionOnBackgroundingController:(UIViewController *)controller actionBlock:(NSObjectPerformBlock)actionBlock
{
    @synchronized(self)
    {
        if (!_backgroundHandlers)
            _backgroundHandlers = [NSMutableArray array];
        
        SDApplicationAction *actionHandler = [[SDApplicationAction alloc] init];
        actionHandler.controller = controller;
        actionHandler.handlerBlock = actionBlock;
        
        [_backgroundHandlers addObject:actionHandler];
    }
}

- (void)removeBackgroundingsActionFor:(UIViewController *)controller
{
    @synchronized(self)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"controller=%@", controller];
        NSArray *itemsToRemove = [_backgroundHandlers filteredArrayUsingPredicate:predicate];
        
        if (itemsToRemove.count > 0)
            [_backgroundHandlers removeObjectsInArray:itemsToRemove];
    }
}

- (void)cleanupBackgroundingActions
{
    @synchronized(self)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"controller=nil"];
        NSArray *itemsToRemove = [_backgroundHandlers filteredArrayUsingPredicate:predicate];
        
        if (itemsToRemove.count > 0)
            [_backgroundHandlers removeObjectsInArray:itemsToRemove];
    }
}*/

#pragma mark - Overrides

- (void)sendEvent:(UIEvent *)event
{
    [self checkForTimerResets:event];
    
    [super sendEvent:event];
}

@end

#pragma mark - SDApplicationMain()

int SDApplicationMain(int argc, char *argv[], NSString *delegateClassName)
{
    return UIApplicationMain(argc, argv, @"SDApplication", delegateClassName);
}
