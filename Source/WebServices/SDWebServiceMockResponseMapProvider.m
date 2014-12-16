//
//  SDWebServiceMockResponseMapProvider.m
//  ios-shared
//
//  Created by Douglas Sjoquist on 12/15/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "SDWebServiceMockResponseMapProvider.h"
#import "SDWebServiceMockResponseRequestMapping.h"

@implementation SDWebServiceMockResponseMapProvider

- (NSData *) getMockResponseForRequest:(NSURLRequest *)request
{
    return nil;
}

- (void)addMockResponseFile:(NSString *)filename bundle:(NSBundle *)bundle forRequestMapping:(SDWebServiceMockResponseRequestMapping *) requestMapping frequency:(NSUInteger) frequency
{

}

- (void)addMockResponseFile:(NSString *)filename bundle:(NSBundle *)bundle forPath:(NSString *) path
{
    SDWebServiceMockResponseRequestMapping *requestMapping =
    [[SDWebServiceMockResponseRequestMapping alloc] initWithPath:path queryParameters:nil];
    [self addMockResponseFile:filename bundle:bundle forRequestMapping:requestMapping frequency:NSIntegerMax];
}

- (void)removeMockResponseFilename:(NSString *) filename;
{

}

- (void)removeMockResponseFileForRequestMapping:(SDWebServiceMockResponseRequestMapping *) requestMapping
{
}

@end
