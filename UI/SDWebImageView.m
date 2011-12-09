//
//  SDWebImageView.m
//  walmart
//
//  Created by Sam Grover on 2/28/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import "SDWebImageView.h"
#import "ASIHTTPRequest.h"
#import "SDDownloadCache.h"
#import "ASINetworkQueue.h"

@implementation SDWebImageView


#pragma mark -
#pragma mark Properties

@synthesize imageUrlString;
@synthesize errorImage;

- (void)clearRequest
{
	if (request)
	{
		[request clearDelegatesAndCancel];
		[request release];
		request = nil;
	}
}

- (void)setImageUrlString:(NSString *)argImageUrlString {
    
    if (imageUrlString && [imageUrlString isEqualToString:argImageUrlString])
        return;
    
	[imageUrlString release];
	imageUrlString = [argImageUrlString copy];
	

    [self clearRequest];
	
    if (self.image != nil) {
        self.image = nil;
    }
    
    if (imageUrlString == nil) return;
    
	NSURL *url = [NSURL URLWithString:imageUrlString];
	
    SDDownloadCache *cache = [SDDownloadCache sharedCache];
    NSData *data = [cache cachedResponseDataForURL:url];
    if (data)
    {
        self.image = [UIImage imageWithData:data];
    }
    else
    {   
		self.alpha = 0;
		
        __block ASIHTTPRequest *tempRequest = nil;
        request = [[ASIHTTPRequest requestWithURL:url] retain];
        tempRequest = request;
        
        tempRequest.numberOfTimesToRetryOnTimeout = 3;
        tempRequest.delegate = self;
        [tempRequest setShouldContinueWhenAppEntersBackground:YES];
        [tempRequest setDownloadCache:[SDDownloadCache sharedCache]];
        [tempRequest setCacheStoragePolicy:ASICacheForSessionDurationCacheStoragePolicy];
        //[tempRequest setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
        
        __block SDWebImageView *blockSelf = self;
        [tempRequest setCompletionBlock:^{
            NSData *responseData = [tempRequest responseData];
            blockSelf.image = [UIImage imageWithData:responseData];
			
			[UIView animateWithDuration:0.2 animations:^{
				blockSelf.alpha = 1.0;
			}];
			[self clearRequest];
       }];
        
        [tempRequest setFailedBlock:^{
            NSError *error = [tempRequest error];
            SDLog(@"Error fetching image: %@", error);
            blockSelf.image = blockSelf.errorImage;

			[UIView animateWithDuration:0.2 animations:^{
				blockSelf.alpha = 1.0;
			}];
			[self clearRequest];
        }];
        
        ASINetworkQueue *queue = [ASINetworkQueue queue];
        [queue addOperation:tempRequest];
        [queue go];
    }
}


#pragma mark -
#pragma mark Object and Memory

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    [request clearDelegatesAndCancel];
    [request release];
	[imageUrlString release];
	[errorImage release];
	[super dealloc];
}


@end
