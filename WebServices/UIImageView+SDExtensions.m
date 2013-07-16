//
//  UIImageView+SDExtensions.m
//  ios-shared
//
//  Created by Brandon Sneed on 4/22/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "UIImageView+SDExtensions.h"
#import "SDURLConnection.h"

#import <objc/runtime.h>

@implementation UIImageView (SDExtensions)

- (void)setImageWithURL:(NSURL *)url
{
    if ( url == nil ) return;
    
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    __weak UIImageView *blockSelf = self;
    [self setImageWithURL:url placeholderImage:placeholder completionBlock: ^(UIImage *image, NSError *error) {
        blockSelf.image = image;
    }];
}

- (void)setImageWithURL:(NSURL *)url completionBlock:(UIImageViewURLCompletionBlock)completionBlock
{
    [self setImageWithURL:url placeholderImage:nil completionBlock:completionBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completionBlock:(UIImageViewURLCompletionBlock)completionBlock
{
    NSURL *existingURL = objc_getAssociatedObject(self, @"imageUrl");
    if (existingURL && [[url absoluteString] isEqualToString:[existingURL absoluteString]])
        return;
    else
    if (existingURL)
        [self cancelCurrentImageLoad];
    
    self.image = placeholder;
    
    objc_setAssociatedObject(self, @"imageUrl", url, OBJC_ASSOCIATION_RETAIN);

    @weakify(self);

    [[SDImageCache sharedInstance] fetchImageAtURL:url completionBlock:^(UIImage *image, NSError *error) {
        @strongify(self);
        NSURL *originalURL = objc_getAssociatedObject(self, @"imageUrl");
        if ([[url absoluteString] isEqualToString:[originalURL absoluteString]])
        {
            self.image = image;
            completionBlock(image, error);
        }
    }];
}

- (void)cancelCurrentImageLoad
{
    NSURL *originalURL = objc_getAssociatedObject(self, @"imageUrl");
    objc_setAssociatedObject(self, @"imageUrl", nil, OBJC_ASSOCIATION_RETAIN);
    [[SDImageCache sharedInstance] cancelFetchForURL:originalURL];
}

+ (void)removeImageURLFromCache:(NSURL *)url
{
    [[SDImageCache sharedInstance] removeImageURLFromCache:url];
}

+ (void)setImageMemoryCacheSize:(NSUInteger)memoryCacheSize
{
    [[SDImageCache sharedInstance] setMemoryCacheSize:memoryCacheSize];
}

@end
