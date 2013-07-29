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

NSString * const SDImageViewErrorDomain = @"SDImageViewErrorDomain";

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
    {
        completionBlock(nil, [NSError errorWithDomain:SDImageViewErrorDomain code:SDImageViewErrorAlreadyBeingFetched]);
        return;
    }
    else
    if (existingURL)
        [self cancelCurrentImageLoad];
    
    self.image = placeholder;
    
    objc_setAssociatedObject(self, @"imageUrl", url, OBJC_ASSOCIATION_RETAIN);

    // if the url is set to nil, assume it's intentional and don't send back an error.
    if (!url)
    {
        completionBlock(nil, nil);
        return;
    }

    @weakify(self);

    [[SDImageCache sharedInstance] fetchImageAtURL:url completionBlock:^(UIImage *image, NSError *error) {
        @strongify(self);
        NSURL *originalURL = objc_getAssociatedObject(self, @"imageUrl");

        // if the url's match on both sides, lets set it and/or wrap any error that comes back.
        if ([[url absoluteString] isEqualToString:[originalURL absoluteString]])
        {
            self.image = image;
            completionBlock(image, [NSError wrapErrorWithDomain:SDImageViewErrorDomain code:SDImageViewErrorConnectionError underlyingError:error]);
        }
        else
        {
            // the url's don't match anymore, skip setting it, but inform the client.
            completionBlock(nil, [NSError errorWithDomain:SDImageViewErrorDomain code:SDImageViewErrorHasBeenReused underlyingError:error]);
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
