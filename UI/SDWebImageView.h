//
//  SDWebImageView.h
//  walmart
//
//  Created by Sam Grover on 2/28/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDURLConnection.h"

@protocol SDWebImageViewDelegate;

@interface SDWebImageView : UIImageView {
	NSString *imageUrlString;
	UIImage *errorImage;
    NSMutableURLRequest *request;
	__unsafe_unretained SDURLConnection *currentRequest;
}

// If you set the delegate, set it to nil in your dealloc
@property (nonatomic, unsafe_unretained) id<SDWebImageViewDelegate> delegate;

@property (nonatomic, copy) NSString *imageUrlString;
@property (nonatomic, strong) UIImage *errorImage;
@end

@protocol SDWebImageViewDelegate <NSObject>
@optional
- (void)webImage:(SDWebImageView*)webImage didReceiveError:(NSError*)error;
- (void)webImageDidFinishLoading:(SDWebImageView*)webImage;
- (void)webImageDidStartLoading:(SDWebImageView*)webImage;
@end
