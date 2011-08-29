//
//  SDDragDropManager.m
//  testdrag
//
//  Created by Brandon Sneed on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SDDragDropManager.h"

@implementation SDDragDropManager

@synthesize dropTargets;
@synthesize dragContainer;

+ (SDDragDropManager *)sharedManager
{
    static dispatch_once_t pred;
    static SDDragDropManager *sharedManager = nil;
    
    dispatch_once(&pred, ^{ sharedManager = [[self alloc] init]; });
    return sharedManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        dropTargets = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [dropTargets release];
    [super dealloc];
}

- (NSArray *)dropTargets
{
    return [NSArray arrayWithArray:dropTargets];
}

- (void)addDropTarget:(UIView *)view
{
    [dropTargets addObject:view];
}

- (void)removeDropTarget:(UIView *)view
{
    [dropTargets removeObject:view];
}

@end
