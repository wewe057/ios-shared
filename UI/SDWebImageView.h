//
//  SDWebImageView.h
//  walmart
//
//  Created by Sam Grover on 2/28/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ASIHTTPRequest;

@interface SDWebImageView : UIImageView {
	NSString *imageUrlString;
	UIImage *errorImage;
}

@property (nonatomic, copy) NSString *imageUrlString;
@property (nonatomic, retain) UIImage *errorImage;

@end
