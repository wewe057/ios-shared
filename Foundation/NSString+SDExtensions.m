//
//  NSString+SDExtensions.m
//  walmart
//
//  Created by Ben Galbraith on 2/25/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import "NSString+SDExtensions.h"


@implementation NSString(SDExtensions)

- (NSString *)replaceHTMLWithUnformattedText {
    NSString* fixed = self;
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    return fixed;
}

@end
