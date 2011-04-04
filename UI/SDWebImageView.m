//
//  SDWebImageView.m
//  walmart
//
//  Created by Sam Grover on 2/28/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import "SDWebImageView.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"

@implementation SDWebImageView


#pragma mark -
#pragma mark Properties

@synthesize imageUrlString;
@synthesize errorImage;

- (void)setImageUrlString:(NSString *)argImageUrlString {
    
    if (imageUrlString && [imageUrlString isEqualToString:argImageUrlString])
        return;
    
	[imageUrlString release];
	imageUrlString = [argImageUrlString copy];
	
    if (self.image != nil) {
        self.image = nil;
    }
    
    if (imageUrlString == nil) return;
    
	NSURL *url = [NSURL URLWithString:imageUrlString];
    
    if ([queue operationCount] > 0)
        [queue cancelAllOperations];
    
	__block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.numberOfTimesToRetryOnTimeout = 3;
    [request setShouldContinueWhenAppEntersBackground:YES];
	[request setDownloadCache:[ASIDownloadCache sharedCache]];
    [request setCacheStoragePolicy:ASICacheForSessionDurationCacheStoragePolicy];
	
	[request setCompletionBlock:^{
		NSData *responseData = [request responseData];
		self.image = [UIImage imageWithData:responseData];
	}];
	
	[request setFailedBlock:^{
		NSError *error = [request error];
		SDLog(@"Error fetching image: %@", error);
		self.image = self.errorImage;
	}];
    
    [queue addOperation:request];
	[queue go];
}


#pragma mark -
#pragma mark Object and Memory

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        queue = [[ASINetworkQueue alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        queue = [[ASINetworkQueue alloc] init];
    }
    return self;
}

- (void)dealloc {
    [queue cancelAllOperations];
    [queue release];
	[imageUrlString release];
	[errorImage release];
	[super dealloc];
}


@end
