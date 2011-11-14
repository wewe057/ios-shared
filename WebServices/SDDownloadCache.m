//
//  SDDownloadCache.m
//  walmart
//
//  Created by Sam Grover on 11/14/11.
//  Copyright (c) 2011 Walmart. All rights reserved.
//

#import "SDDownloadCache.h"

@implementation SDDownloadCache

+ (SDDownloadCache *)sharedCache
{
	static dispatch_once_t oncePred;
	static SDDownloadCache *sharedInstance = nil;
	dispatch_once(&oncePred, ^{ sharedInstance = [[self alloc] init]; });
	return sharedInstance;
}

- (id)init
{
	self = [super init];
	if (self) 
	{
		[self setStoragePath:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"SDWebServiceCache"]];
	}
	return self;
}


@end
