//
//  SDWebImageView.m
//  walmart
//
//  Created by Sam Grover on 2/28/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import "SDWebImageView.h"
#import "SDDownloadCache.h"
#import "ASINetworkQueue.h"

@implementation SDWebImageView


#pragma mark -
#pragma mark Properties

@synthesize imageUrlString;
@synthesize errorImage;

- (void)setImageUrlString:(NSString *)argImageUrlString {
    
    if (imageUrlString && [imageUrlString isEqualToString:argImageUrlString])
        return;
    
	imageUrlString = [argImageUrlString copy];
	
    if (request)
    {
        request = nil;
    }
    
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
		
        __unsafe_unretained NSMutableURLRequest *tempRequest = nil;
        tempRequest = [NSMutableURLRequest requestWithURL:url]; 
        request = tempRequest;
		
		[request setHTTPMethod:@"GET"];
		[request setHTTPShouldHandleCookies:YES];
		[request setHTTPShouldUsePipelining:YES];
#ifdef DEBUG
		[request setTimeoutInterval:300000];
#else
		[request setTimeoutInterval:30];
#endif
		
		SDWebImageView *blockSelf = self;
		
#ifdef DEBUG
		NSDate *startDate = [NSDate date];
#endif
		
		__block SDURLConnectionResponseBlock urlCompletionBlock = ^(SDURLConnection *connection, NSURLResponse *response, NSData *responseData, NSError *error){
			@autoreleasepool {
				
#ifdef DEBUG
				SDLog(@"Service call took %lf seconds.", [[NSDate date] timeIntervalSinceDate:startDate]);
#endif
				
				if ([error code] == NSURLErrorTimedOut)
				{
					SDLog(@"Error fetching image: %@", error);
					
					// remove it from the cache if its there.
					NSURLCache *cache = [NSURLCache sharedURLCache];
					[cache removeCachedResponseForRequest:request];
					
					// set image
					blockSelf.image = blockSelf.errorImage;
					[UIView animateWithDuration:0.2 animations:^{
						blockSelf.alpha = 1.0;
					}];
					
				} else {
					
					// set image
					blockSelf.image = [UIImage imageWithData:responseData];
					[UIView animateWithDuration:0.2 animations:^{
						blockSelf.alpha = 1.0;
					}];

				}
			}
		};
		
		[SDURLConnection sendAsynchronousRequest:request shouldCache:YES withResponseHandler:urlCompletionBlock];
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


@end
