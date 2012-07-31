//
//  SDWebImageView.m
//  walmart
//
//  Created by Sam Grover on 2/28/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import "SDWebImageView.h"
#import "UIImageView+WebCache.h" // SDWebImage Submodule
#import "SDImageCache.h"
#import "WMAniviaClient.h"

typedef void (^SDWebImageSuccessBlock)(UIImage *image);
typedef void (^SDWebImageFailureBlock)(NSError *error);

@interface SDWebImageView ()
@property (nonatomic, assign) NSUInteger badImageRetryCount; // How many times have we tried to reload for a 0,0 image?
@end

@implementation SDWebImageView

#pragma mark -
#pragma mark Properties

@synthesize delegate;
@synthesize imageUrlString;
@synthesize badImageRetryCount;

- (void)retryImage
{
	[[SDImageCache sharedImageCache] removeImageForKey:imageUrlString];
	[self setImageUrlString:imageUrlString shouldRetry:NO];
}

- (void)dealloc
{
	self.delegate = nil;
}

// SDWebImageView wrapper around SDWebImage
// Caveats:  SDWebImageView would only send webImageDidStartLoading if the image was not cached.  Now it always sends it
- (void)setImageUrlString:(NSString *)argImageUrlString shouldRetry:(BOOL)shouldRetry {
	
	if ([imageUrlString isEqualToString:argImageUrlString] == NO)
		self.badImageRetryCount = 0;
	
	imageUrlString = argImageUrlString;
    
	NSURL *url = [NSURL URLWithString:argImageUrlString];

	// First, tell our delegate that we are about to start loading
	if (self.delegate)
	{
		if ([self.delegate respondsToSelector:@selector(webImageDidStartLoading:)])
			[self.delegate webImageDidStartLoading:self];
	}
	
	// Create our success and failure blocks
	__block SDWebImageSuccessBlock successBlock = ^(UIImage *image) {
		if (self.delegate)
		{
			// We have seen SDWebImage cache 0x0 images before.  If we run into one of these, let's retry once after killing the cache
			if ((self.image.size.width == 0) || (self.image.size.height == 0))
			{
				if (self.badImageRetryCount < 1)
				{
					self.badImageRetryCount++;
					[self performSelector:@selector(retryImage) withObject:self afterDelay:0.1]; // Must exit out of this completion block first!
					return;
				}
			}
			if ([self.delegate respondsToSelector:@selector(webImageDidFinishLoading:)])
				[self.delegate webImageDidFinishLoading:self];
		}		
	};
	
	__block SDWebImageFailureBlock failureBlock = ^(NSError *error) {
		if (self.delegate)
		{
			if ([self.delegate respondsToSelector:@selector(webImage:didReceiveError:)])
			{
				// Report the URL because with a delegate pattern, this instance may have been changed by the time the error happens
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:argImageUrlString forKey:@"imageUrlString"];
				NSError *imageError = [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo];
				[self.delegate webImage:self didReceiveError:imageError];
			}
		}
		// Analytics - Not sure I like this code this deep in the system
		NSString *errorString = [NSString stringWithFormat:@"Error loading image %@",argImageUrlString];
		[[WMAniviaClient sharedInstance] trackEvent:[WMAniviaEvent errorEventWithDesc:errorString]];
	};
		
	// Make the call
	[self setImageWithURL:url success:successBlock failure:failureBlock];

}

- (void)setImageUrlString:(NSString *)argImageUrlString
{
	[self setImageUrlString:argImageUrlString shouldRetry:YES];
}

@end
