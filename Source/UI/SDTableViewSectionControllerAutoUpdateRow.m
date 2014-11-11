//
//  SDTableViewSectionControllerAutoUpdateRow.m
//  walmart
//
//  Created by Steve Riggins on 11/10/14.
//  Copyright (c) 2014 Walmart. All rights reserved.
//

#import "SDTableViewSectionControllerAutoUpdateRow.h"

@interface SDTableViewSectionControllerAutoUpdateRow()
@property (nonatomic, assign) NSInteger attributeHash;
@property (nonatomic, assign) NSUInteger internalHash;
@end

@implementation SDTableViewSectionControllerAutoUpdateRow

+ (instancetype)genericRowOne
{
    SDTableViewSectionControllerAutoUpdateRow *row = [[self alloc] initWithHash:1 attributeHash:0];
    return row;
}

- (instancetype)initWithHash:(NSUInteger)hash attributeHash:(NSInteger)attributeHash
{
    if (self = [super init])
    {
        _attributeHash = attributeHash;
        _internalHash = hash;
    }
    return self;
}

- (instancetype)initWithHash:(NSUInteger)hash
{
    if (self = [super init])
    {
        _attributeHash = 0;
        _internalHash = hash;
    }
    return self;
}

- (NSUInteger)hash
{
    return self.internalHash;
}

@end
