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

    // kill the HTML entities
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"&#[0-9]+;"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    fixed = [regex stringByReplacingMatchesInString:fixed 
                                            options:0 
                                              range:NSMakeRange(0, [fixed length]) 
                                       withTemplate:@""];
    
    // kill the HTML tags
    error = NULL;
    regex = [NSRegularExpression regularExpressionWithPattern:@"<\\/*[A-Z][A-Z0-9]*>"
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:&error];
    fixed = [regex stringByReplacingMatchesInString:fixed 
                                            options:0 
                                              range:NSMakeRange(0, [fixed length]) 
                                       withTemplate:@""];
    
    
    return fixed;
}

@end
