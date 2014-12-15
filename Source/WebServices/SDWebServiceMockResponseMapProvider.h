//
//  SDWebServiceMockResponseMapProvider.h
//  ios-shared
//
//  Created by Douglas Sjoquist on 12/15/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SDWebServiceMockResponseRequestMapping;

@interface SDWebServiceMockResponseMapProvider : NSObject

- (void)addMockResponseFile:(NSString *)filename bundle:(NSBundle *)bundle forRequestMapping:(SDWebServiceMockResponseRequestMapping *) requestMapping frequency:(NSUInteger) frequency;
- (void)addMockResponseFile:(NSString *)filename bundle:(NSBundle *)bundle forPath:(NSString *) path;
- (void)removeMockResponseFilename:(NSString *) filename;
- (void)removeMockResponseFileForRequestMapping:(SDWebServiceMockResponseRequestMapping *) requestMapping;

@end
