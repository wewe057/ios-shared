//
//  SDBase64.m
//  ios-shared
//
//  This class extension requires linking with libresolv.dylib.
//
//  Created by Brandon Sneed on 5/29/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "SDBase64.h"
#import <dlfcn.h>

@implementation NSData(SDBase64)

typedef int	(*t_b64_ntop)(u_char const *, size_t, char *, size_t);
typedef int	(*t_b64_pton)(char const *, u_char *, size_t);

void *p_libResolv = nil;
t_b64_ntop p_b64_ntop = nil;
t_b64_pton p_b64_pton = nil;

- (void)loadLibResolv
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // we have no way of unloading it, so no need to keep the handle.
        p_libResolv = dlopen("libResolv.dylib", RTLD_NOW);
        if (p_libResolv)
        {
            p_b64_ntop = dlsym(p_libResolv, "res_9_b64_ntop");
            p_b64_pton = dlsym(p_libResolv, "res_9_b64_pton");
            
            if (!p_b64_ntop || !p_b64_pton)
            {
                dlclose(p_libResolv);
                p_libResolv = nil;
            }
        }
    });
}

- (NSData *)encodeToBase64Data
{
    [self loadLibResolv];
    
    NSData *result = nil;
    
    NSUInteger dataToEncodeLength = self.length;
    NSUInteger encodedBufferLength = (((dataToEncodeLength + 2) / 3) * 4) + 1;
    
    char *encodedBuffer = malloc(encodedBufferLength);
    memset(encodedBuffer, 0, encodedBufferLength);
    NSInteger encodedLength = p_b64_ntop(self.bytes, dataToEncodeLength, encodedBuffer, encodedBufferLength + 1);
    
    if (encodedLength > 0)
        result = [NSData dataWithBytes:encodedBuffer length:(NSUInteger)encodedLength];
    
    free(encodedBuffer);
    
    return result;
}

- (NSData *)decodeBase64ToData
{
    [self loadLibResolv];

    NSData *result = nil;
    
    NSUInteger decodedBufferLength = (self.length * 3 / 4) + 1;
    uint8_t *decodedBuffer = malloc(decodedBufferLength);
    memset(decodedBuffer, 0, decodedBufferLength);

    NSUInteger bytesLength = self.length;
    uint8_t *dataBytes = malloc(bytesLength + 1);   // add one byte for null termination
    memcpy(dataBytes, self.bytes, bytesLength);
    dataBytes[bytesLength] = 0;                     // Must be null terminated

    NSInteger decodedLength = p_b64_pton((char const *)dataBytes, decodedBuffer, decodedBufferLength);
    
    if (decodedLength >= 0)
        result = [NSData dataWithBytes:decodedBuffer length:(NSUInteger)decodedLength];
    
    free(decodedBuffer);
    free(dataBytes);
    return result;
}

- (NSString *)encodeToBase64String
{
    NSString *result = nil;
    NSData *data = [self encodeToBase64Data];
    if (data && data.length > 0)
        result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return result;
}

- (NSString *)decodeBase64ToString
{
    NSString *result = nil;
    NSData *data = [self decodeBase64ToData];
    if (data && data.length > 0)
        result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return result;
}

@end


@implementation NSString(SDBase64)

- (NSData *)encodeToBase64Data
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data encodeToBase64Data];
}

- (NSData *)decodeBase64ToData
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data decodeBase64ToData];
}

- (NSString *)encodeToBase64String
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data encodeToBase64String];
}

- (NSString *)decodeBase64ToString
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data decodeBase64ToString];
}

@end
