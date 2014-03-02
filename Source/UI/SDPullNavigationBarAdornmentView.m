//
//  SDPullNavigationBarAdornmentView.m
//  ios-shared
//
//  Created by Steven Woolgar on 03/01/2014.
//  Copyright 2014 SetDirection. All rights reserved.
//

#import "SDPullNavigationBarAdornmentView.h"

@interface SDPullNavigationBarAdornmentView()
@property (nonatomic, strong) UIImageView* adornmentView;
@end

@implementation SDPullNavigationBarAdornmentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self != nil)
    {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        self.opaque = YES;
    }

    return self;
}

- (void)setAdornmentImage:(UIImage*)adornmentImage
{
    if(_adornmentImage != adornmentImage)
    {
        CGRect frame = self.frame;

        // Take off the existing adornment image's height.
        if(_adornmentImage)
        {
            frame.size.height -= _adornmentImage.size.height;
        }

        // Add the height of the image to the view.
        frame.size.height += adornmentImage.size.height;

        _adornmentImage = adornmentImage;

        // Adding or removing an adornment image means laying our the view again.
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    // If we haven't created the adornment view yet, and there is an image, create one, then position it at the bottom of the view.
    if(self.adornmentView == nil && self.adornmentImage)
    {
        CGSize imageSize = self.adornmentImage.size;
        CGRect imageViewRect = self.frame;
        imageViewRect.origin.y = CGRectGetHeight(imageViewRect) - imageSize.height;
        imageViewRect.origin.x = floor(CGRectGetWidth(imageViewRect) * 0.5f - imageSize.width * 0.5f);
        imageViewRect.size = imageSize;

        self.adornmentView = [[UIImageView alloc] initWithFrame:imageViewRect];
        self.adornmentView.image = self.adornmentImage;
        [self addSubview:self.adornmentView];
    }
    else if(self.adornmentView && self.adornmentImage)
    {
        CGSize imageSize = self.adornmentImage.size;
        CGRect imageViewRect = self.frame;
        imageViewRect.origin.y = CGRectGetHeight(imageViewRect) - imageSize.height;
        imageViewRect.origin.x = floor(CGRectGetWidth(imageViewRect) * 0.5f - imageSize.width * 0.5f);
        imageViewRect.size.width = imageSize.width;

        self.adornmentView.frame = imageViewRect;
    }
    else if(self.adornmentView && self.adornmentImage == nil)
    {
        [self.adornmentView removeFromSuperview];
        self.adornmentView = nil;
    }
}

@end