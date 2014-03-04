//
//  SDPullNavigationBarAdornmentView.m
//  ios-shared
//
//  Created by Steven Woolgar on 03/01/2014.
//  Copyright 2014 SetDirection. All rights reserved.
//

#import "SDPullNavigationBarAdornmentView.h"

static const CGFloat kMinimumHeightForTapArea = 44.0f;

@interface SDPullNavigationBarAdornmentView()
@property (nonatomic, assign) CGRect baseFrame;
@property (nonatomic, strong) UIImageView* adornmentView;
@end

@implementation SDPullNavigationBarAdornmentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self != nil)
    {
        _baseFrame = frame;
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
        _adornmentImage = adornmentImage;

        if(adornmentImage)
        {
            CGSize imageSize = self.adornmentImage.size;
            CGRect imageViewRect = self.baseFrame;
            imageViewRect.origin.y = self.baseFrame.size.height;
            imageViewRect.origin.x = floor(CGRectGetWidth(imageViewRect) * 0.5f - imageSize.width * 0.5f);
            imageViewRect.size = imageSize;

            self.adornmentView = [[UIImageView alloc] initWithFrame:imageViewRect];
            self.adornmentView.image = self.adornmentImage;
            [self addSubview:self.adornmentView];

            [self setFrame:_baseFrame];    // Tell our setFrame to adjust for the image.
        }
        else
        {
            [self.adornmentView removeFromSuperview];
            self.adornmentView = nil;
        }

        // Adding or removing an adornment image means laying our the view again.

        [self setNeedsLayout];
    }
}

- (CGRect)frame
{
    return _baseFrame;
}

// Override the setFrame so that the code that sizes this view does not need to take into account the adornment view
// at the bottom of the view.

- (void)setFrame:(CGRect)frame
{
    _baseFrame = frame;
    CGRect adjustedFrame = frame;
    adjustedFrame.size.height += MAX(self.adornmentImage.size.height, kMinimumHeightForTapArea);

    [super setFrame:adjustedFrame];
}

- (void)layoutSubviews
{
    // If we haven't created the adornment view yet, and there is an image, create one, then position it at the bottom of the view.

    if(self.adornmentImage)
    {
        CGSize imageSize = self.adornmentImage.size;
        CGRect imageViewRect = self.baseFrame;
        imageViewRect.origin.y = self.baseFrame.size.height;
        imageViewRect.origin.x = floor(CGRectGetWidth(imageViewRect) * 0.5f - imageSize.width * 0.5f);
        imageViewRect.size = imageSize;

        self.adornmentView.frame = imageViewRect;
    }
}

@end