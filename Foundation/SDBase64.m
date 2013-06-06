//
//  SDBase64.m
//  ios-shared
//
//  Created by Brandon Sneed on 5/29/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "SDBase64.h"
#import <resolv.h>

@implementation NSData(SDBase64)

- (NSData *)encodeToBase64Data
{
    NSData *result = nil;
    
    NSUInteger dataToEncodeLength = self.length;
    NSUInteger encodedBufferLength = (((dataToEncodeLength + 2) / 3) * 4) + 1;
    
    char *encodedBuffer = malloc(encodedBufferLength);
    memset(encodedBuffer, 0, encodedBufferLength);
    int encodedLength = b64_ntop(self.bytes, dataToEncodeLength, encodedBuffer, encodedBufferLength + 1);
    
    if (encodedLength > 0)
        result = [NSData dataWithBytes:encodedBuffer length:(NSUInteger)encodedLength];
    
    free(encodedBuffer);
    
    return result;
}

- (NSData *)decodeBase64ToData
{
    NSData *result = nil;
    
    NSUInteger decodedBufferLength = (self.length * 3 / 4) + 1;
    uint8_t *decodedBuffer = malloc(decodedBufferLength);
    memset(decodedBuffer, 0, decodedBufferLength);
    
    int decodedLength = b64_pton(self.bytes, decodedBuffer, decodedBufferLength);
    
    if (decodedLength >= 0)
        result = [NSData dataWithBytes:decodedBuffer length:(NSUInteger)decodedLength];
    
    free(decodedBuffer);
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
