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

- (NSData *)base64EncodedData
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

- (NSData *)base64DecodedData
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

- (NSString *)base64DecodedString
{
    NSString *result = nil;
    NSData *data = [self base64DecodedData];
    if (data && data.length > 0)
        result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return result;
}

- (NSString *)base64EncodedString
{
    NSString *result = nil;
    NSData *data = [self base64EncodedData];
    if (data && data.length > 0)
        result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return result;
}

@end


@implementation NSString(SDBase64)

- (NSData *)base64EncodedData
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedData];
}

- (NSData *)base64DecodedData
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64DecodedData];
}

- (NSString *)base64DecodedString
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64DecodedString];
}

- (NSString *)base64EncodedString
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedString];
}

@end
