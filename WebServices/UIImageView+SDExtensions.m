//
//  UIImageView+SDExtensions.m
//  ios-shared
//
//  Created by Brandon Sneed on 4/22/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "UIImageView+SDExtensions.h"
#import "NSURLCache+SDExtensions.h"
#import "NSCachedURLResponse+LeakFix.h"
#import "SDURLConnection.h"
#import <objc/runtime.h>

@interface SDImageCache : NSObject
{
    NSMutableDictionary *_activeConnections;
    NSMutableDictionary *_memoryCache;
    NSOperationQueue *_decodeQueue;
    
    NSUInteger _imageCounter;
}

@property (atomic, assign) NSUInteger memoryCacheSize;

+ (SDImageCache *)sharedInstance;

- (NSUInteger)actualMemoryCacheSize;

- (BOOL)isImageURLInProgress:(NSURL *)url;
- (void)fetchImageAtURL:(NSURL *)url completionBlock:(UIImageViewURLCompletionBlock)completionBlock;
- (void)cancelFetchForURL:(NSURL *)url;
- (void)removeImageURLFromCache:(NSURL *)url;
- (void)addImageToMemoryCache:(UIImage *)image withURL:(NSURL *)url;

@end

@implementation UIImageView (SDExtensions)

- (void)setImageWithURL:(NSURL *)url
{
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

    __weak UIImageView *blockSelf = self;

    [[SDImageCache sharedInstance] fetchImageAtURL:url completionBlock:^(UIImage *image, NSError *error) {
        NSURL *originalURL = objc_getAssociatedObject(blockSelf, @"imageUrl");
        if ([[url absoluteString] isEqualToString:[originalURL absoluteString]])
        {
            blockSelf.image = image;
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

@implementation SDImageCache

+ (SDImageCache *)sharedInstance
{
    static dispatch_once_t onceToken;
    static SDImageCache *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[SDImageCache alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    
    _activeConnections = [NSMutableDictionary dictionary];
    _memoryCache = [NSMutableDictionary dictionary];
    _decodeQueue = [[NSOperationQueue alloc] init];
    _memoryCacheSize = 1024 * 1024 * 4; // default to 4mb
    _imageCounter = 0;
    
    // Subscribe to app events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(flushMemoryCache)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
    UIDevice *device = [UIDevice currentDevice];
    if ([device respondsToSelector:@selector(isMultitaskingSupported)] && device.multitaskingSupported)
    {
        // When in background, clean memory in order to have less chance to be killed
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(flushMemoryCache)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }

    return self;
}

- (NSUInteger)actualMemoryCacheSize
{
    __block NSUInteger result = 0;
    [_memoryCache enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        UIImage *thisImage = (UIImage *)obj;
        NSUInteger thisImageSize = (thisImage.size.width * thisImage.size.height) * 4; // rough estimate
        result += thisImageSize;
    }];
    
    return result;
}

- (void)flushMemoryCache
{
    [_memoryCache removeAllObjects];
    _imageCounter = 0;
}

- (void)cleanCacheAsNeeded
{
    NSUInteger actualSize = [self actualMemoryCacheSize];
    if (actualSize > _memoryCacheSize)
    {
        NSMutableArray *keys = [[_memoryCache keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSNumber *obj1Index = objc_getAssociatedObject(obj1, @"decodedIndex");
            NSNumber *obj2Index = objc_getAssociatedObject(obj2, @"decodedIndex");
            
            if ([obj1Index integerValue] > [obj2Index integerValue])
                return NSOrderedDescending;
            if ([obj1Index integerValue] < [obj2Index integerValue])
                return NSOrderedAscending;
            return NSOrderedSame;
        }] mutableCopy];

        while ([self actualMemoryCacheSize] > _memoryCacheSize - (_memoryCacheSize / 4))
        {
            NSString *key = [keys lastObject];
            [_memoryCache removeObjectForKey:key];
            [keys removeObject:key];
            SDLog(@"dumped from cache: %@", key);
            
            // safety break.  i don't like while loops without a break.
            if ([_memoryCache count] == 0 || [keys count] == 0)
                break;
        }
    }
}

- (BOOL)isImageURLInProgress:(NSURL *)url
{
    SDURLConnection *connection = [_activeConnections objectForKey:[url absoluteString]];
    if (connection)
        return YES;
    return NO;
}

+ (UIImage *)decodedImageWithImage:(UIImage *)image
{
    CGImageRef imageRef = image.CGImage;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 CGImageGetWidth(imageRef),
                                                 CGImageGetHeight(imageRef),
                                                 8,
                                                 // Just always return width * 4 will be enough
                                                 CGImageGetWidth(imageRef) * 4,
                                                 // System only supports RGB, set explicitly
                                                 colorSpace,
                                                 // Makes system don't need to do extra conversion when displayed.
                                                 kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    CGColorSpaceRelease(colorSpace);
    if (!context) return nil;
    
    CGRect rect = (CGRect){CGPointZero, {CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)}};
    CGContextDrawImage(context, rect, imageRef);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    UIImage *decompressedImage = [[UIImage alloc] initWithCGImage:decompressedImageRef scale:image.scale orientation:UIImageOrientationUp];
    CGImageRelease(decompressedImageRef);
    return decompressedImage;
}

- (void)fetchImageAtURL:(NSURL *)url completionBlock:(UIImageViewURLCompletionBlock)completionBlock
{
    UIImage *cachedImage = [_memoryCache objectForKey:[url absoluteString]];
    if (cachedImage)
    {
        SDLog(@"image found in memory cache: %@", url);
        completionBlock(cachedImage, nil);
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLCache *urlCache = [NSURLCache sharedURLCache];
    NSCachedURLResponse *cachedResponse = [urlCache validCachedResponseForRequest:request forTime:60 removeIfInvalid:YES];
    if (cachedResponse)
    {
        UIImage *diskCachedImage = [UIImage imageWithData:cachedResponse.responseData];
        if (diskCachedImage)
        {
            SDLog(@"image found in disk cache: %@", url);
            completionBlock(diskCachedImage, nil);
            return;
        }
    }
    
    SDURLConnection *connection = [SDURLConnection sendAsynchronousRequest:request shouldCache:YES withResponseHandler:^(SDURLConnection *connection, NSURLResponse *response, NSData *responseData, NSError *error) {
        UIImage *image = nil;
        if (responseData && responseData.length > 0)
            image = [UIImage imageWithData:responseData];
        
        [_decodeQueue addOperationWithBlock:^{
            UIImage *decodedImage = nil;
            if (image)
                decodedImage = [SDImageCache decodedImageWithImage:image];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self addImageToMemoryCache:decodedImage withURL:url];
                completionBlock(decodedImage, error);
                if (decodedImage.size.width == 0 || decodedImage.size.height == 0)
                    [self removeImageURLFromCache:url];
            }];
        }];
    }];
    
    if (connection)
        [_activeConnections setObject:connection forKey:[url absoluteString]];
}

- (void)cancelFetchForURL:(NSURL *)url
{
    SDURLConnection *connection = [_activeConnections objectForKey:[url absoluteString]];
    [connection cancel];
    [_activeConnections removeObjectForKey:[url absoluteString]];
}

- (void)removeImageURLFromCache:(NSURL *)url
{
    [self cancelFetchForURL:url];
    
    NSURLCache *cache = [NSURLCache sharedURLCache];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [cache removeCachedResponseForRequest:request];
}

- (void)addImageToMemoryCache:(UIImage *)image withURL:(NSURL *)url
{
    if (image)
    {
        [_memoryCache setObject:image forKey:[url absoluteString]];
        _imageCounter++;
        objc_setAssociatedObject(image, @"decodedIndex", [NSNumber numberWithUnsignedInteger:_imageCounter], OBJC_ASSOCIATION_RETAIN);
    }
    
    [self cleanCacheAsNeeded];
}


@end
