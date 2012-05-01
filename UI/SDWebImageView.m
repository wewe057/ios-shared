//
//  SDWebImageView.m
//  walmart
//
//  Created by Sam Grover on 2/28/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import "SDWebImageView.h"
#import "UIImageView+WebCache.h" // SDWebImage Submodule

typedef void (^SDWebImageSuccessBlock)(UIImage *image);
typedef void (^SDWebImageFailureBlock)(NSError *error);

@implementation SDWebImageView

#pragma mark -
#pragma mark Properties

@synthesize delegate;
@synthesize imageUrlString;

// SDWebImageView wrapper around SDWebImage
// Caveats:  SDWebImageView would only send webImageDidStartLoading if the image was not cached.  Now it always sends it
- (void)setImageUrlString:(NSString *)argImageUrlString shouldRetry:(BOOL)shouldRetry {
	
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
			if ([self.delegate respondsToSelector:@selector(webImageDidFinishLoading:)])
				[self.delegate webImageDidFinishLoading:self];
		}		
	};
	
	__block SDWebImageFailureBlock failureBlock = ^(NSError *error) {
		if (self.delegate)
		{
			if ([self.delegate respondsToSelector:@selector(webImage:didReceiveError:)])
				[self.delegate webImage:self didReceiveError:error];
		}		
	};
		
	// Make the call
	[self setImageWithURL:url success:successBlock failure:failureBlock];

}

- (void)setImageUrlString:(NSString *)argImageUrlString
{
	[self setImageUrlString:argImageUrlString shouldRetry:YES];
}

@end
