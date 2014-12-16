//
//  SDWebServiceMockResponseMapProvider.h
//  ios-shared
//
//  Created by Douglas Sjoquist on 12/15/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDWebServiceMockResponseProvider.h"

@class SDWebServiceMockResponseRequestMapping;

@interface SDWebServiceMockResponseMapProvider : NSObject<SDWebServiceMockResponseProvider>

- (void)addMockResponseFile:(NSString *)filename bundle:(NSBundle *)bundle forRequestMapping:(SDWebServiceMockResponseRequestMapping *) requestMapping maximumResponses:(NSUInteger) maximumResponses;
- (void)addMockResponseFile:(NSString *)filename bundle:(NSBundle *)bundle forPath:(NSString *) path;
- (void)removeMockResponseFileForRequestMapping:(SDWebServiceMockResponseRequestMapping *) requestMapping;
- (void)removeAllRequestMappings;

@end
