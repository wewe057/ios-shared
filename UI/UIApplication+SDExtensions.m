//
//  UIApplication+SDExtensions.m
//  SamsClub
//
//  Created by Sam Grover on 6/27/13.
//  Copyright (c) 2013 Wal-mart Stores, Inc. All rights reserved.
//

#import "UIApplication+SDExtensions.h"

@implementation UIApplication (SDExtensions)

#pragma mark - Standard iOS File system directories

+ (NSString *)documentsDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

+ (NSString *)libraryDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

+ (NSURL *)documentsDirectoryURL
{
    return [NSURL URLWithString:[self documentsDirectoryPath]];
}

+ (NSURL *)libraryDirectoryURL
{
    return [NSURL URLWithString:[self libraryDirectoryPath]];
}

@end
