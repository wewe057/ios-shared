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
	[imageUrlString release];
	imageUrlString = [argImageUrlString copy];
	
    if (self.image != nil) {
        self.image = nil;
    }
    
    if (imageUrlString == nil) return;
    
	NSURL *url = [NSURL URLWithString:imageUrlString];
    
	__block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __block SDWebImageView *blockSelf = self;
    request.numberOfTimesToRetryOnTimeout = 3;
    [request setShouldContinueWhenAppEntersBackground:YES];
	[request setDownloadCache:[ASIDownloadCache sharedCache]];
    [request setCacheStoragePolicy:ASICacheForSessionDurationCacheStoragePolicy];
	
	[request setCompletionBlock:^{
		NSData *responseData = [request responseData];
		blockSelf.image = [UIImage imageWithData:responseData];
        
        // todo: add image cache
	}];
	
	[request setFailedBlock:^{
		NSError *error = [request error];
		SDLog(@"Error fetching image: %@", error);
		blockSelf.image = blockSelf.errorImage;
	}];
	
	[request startAsynchronous];
}


#pragma mark -
#pragma mark Object and Memory

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (void)dealloc {
	[imageUrlString release];
	[errorImage release];
	[super dealloc];
}


@end
