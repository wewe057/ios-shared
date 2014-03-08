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
@property (nonatomic, strong) UIImageView* adornmentView;
@property (nonatomic, assign) CGFloat adornmentViewHeight;  // This accounts for both imageSize and gap to make it more grabbable.
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

        _containerView = [[UIView alloc] initWithFrame:(CGRect){ CGPointZero, frame.size }];
        _containerView.backgroundColor = [UIColor clearColor];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        _containerView.tag = 1;
        [self addSubview:_containerView];
    }

    return self;
}

- (void)setAdornmentImage:(UIImage*)adornmentImage
{
    if(_adornmentImage != adornmentImage)
    {
        _adornmentImage = adornmentImage;

        [self.adornmentView removeFromSuperview];
        self.adornmentView = nil;

        self.adornmentViewHeight = 0.0f;

        if(adornmentImage)
        {
            CGSize imageSize = self.adornmentImage.size;
            CGRect imageViewRect = self.baseFrame;
            imageViewRect.origin.y = self.baseFrame.size.height;
            imageViewRect.origin.x = floor(CGRectGetWidth(imageViewRect) * 0.5f - imageSize.width * 0.5f);
            imageViewRect.size = imageSize;
            self.adornmentViewHeight = MAX(imageSize.height, kMinimumHeightForTapArea);

            self.adornmentView = [[UIImageView alloc] initWithFrame:imageViewRect];
            self.adornmentView.backgroundColor = [UIColor clearColor];
            self.adornmentView.opaque = YES;
            self.adornmentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            self.adornmentView.image = self.adornmentImage;
            self.adornmentView.tag = 2;
            [self addSubview:self.adornmentView];
        }

        [self setFrame:(CGRect){ self.baseFrame.origin, { self.baseFrame.size.width, self.baseFrame.size.height + self.adornmentViewHeight } }];

        // Adding or removing an adornment image means laying our the view again.

        [self setNeedsLayout];
    }
}

- (void)setBaseFrame:(CGRect)baseFrame
{
    if(!CGRectEqualToRect(baseFrame, _baseFrame))
    {
        _baseFrame = baseFrame;
        [self setFrame:(CGRect){ _baseFrame.origin, { _baseFrame.size.width, _baseFrame.size.height + self.adornmentViewHeight } }];
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    // Adjust the views that we have. If we have an image, it means we created the image view that contains it.

    if(self.adornmentImage)
    {
        CGSize imageSize = self.adornmentImage.size;
        CGRect imageViewRect = self.baseFrame;
        imageViewRect.origin.x = floor(CGRectGetWidth(imageViewRect) * 0.5f - imageSize.width * 0.5f);
        imageViewRect.origin.y = self.baseFrame.size.height;
        imageViewRect.size = imageSize;

        self.adornmentView.frame = imageViewRect;
    }

    self.containerView.frame = (CGRect){ CGPointZero, self.baseFrame.size };
}

@end
