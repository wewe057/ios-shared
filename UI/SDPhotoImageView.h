//
//  SDPhotoImageView.h
//  Photos
//
//  Created by Brandon Sneed on 5/10/13.
//  Copyright (c) 2013 walmart. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDPhotoImageView;

@protocol SDPhotoImageViewDelegate <NSObject>
@optional
/**
 Called when the view is tapped.
 */
- (void)photoImageView:(SDPhotoImageView *)photoImageView wasTappedAtPoint:(CGPoint)point;
@end


@interface SDPhotoImageView : UIView<UIScrollViewDelegate>

/**
 Delegate.  Must conform to SDPhotoImageViewDelegate protocol.
 */
@property (nonatomic, weak) id<SDPhotoImageViewDelegate> delegate;
/**
 The UIImageView contained within.  Useful for setting the image directly or via setImageURL: (see UIImageView+SDExtensions.h)
 */
@property (nonatomic, readonly) UIImageView *imageView;

@end
