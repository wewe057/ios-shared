//
//  UIImageView+SDExtensions.h
//  ios-shared
//
//  Created by Brandon Sneed on 4/22/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UIImageViewURLCompletionBlock)(UIImage *image, NSError *error);


@interface UIImageView (SDExtensions)

/**
 * Set the imageView `image` with an `url`.
 *
 * The downloand is asynchronous and cached.
 *
 * @param url The url for the image.
 */
- (void)setImageWithURL:(NSURL *)url;

/**
 * Set the imageView `image` with an `url` and a placeholder.
 *
 * The downloand is asynchronous and cached.
 *
 * @param url The url for the image.
 * @param placeholder The image to be set initially, until the image request finishes.
 */
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

/**
 * Set the imageView `image` with an `url`.
 *
 * The downloand is asynchronous and cached.
 *
 * @param url The url for the image.
 * @param A block to be executed when the image request finishes.
 */
- (void)setImageWithURL:(NSURL *)url completionBlock:(UIImageViewURLCompletionBlock)completionBlock;

/**
 * Set the imageView `image` with an `url`, placeholder.
 *
 * The downloand is asynchronous and cached.
 *
 * @param url The url for the image.
 * @param placeholder The image to be set initially, until the image request finishes.
 * @param A block to be executed when the image request finishes.
 */
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completionBlock:(UIImageViewURLCompletionBlock)completionBlock;

/**
 * Cancel the current download
 */
- (void)cancelCurrentImageLoad;

/**
 * Removes the image from NSURLCache based on the url.
 */
+ (void)removeImageURLFromCache:(NSURL *)url;

/**
 * Sets the in-memory cache size for this extension.  The default size is 4mb.  On-disk cache is handled by NSURLCache.
 */
+ (void)setImageMemoryCacheSize:(NSUInteger)memoryCacheSize;

@end
