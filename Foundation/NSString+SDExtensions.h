//
//  NSString+SDExtensions.h
//  walmart
//
//  Created by Ben Galbraith on 2/25/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString(SDExtensions)

- (NSString *)replaceHTMLWithUnformattedText;
- (NSString *)replaceHTMLWithUnformattedText:(BOOL)keepBullets;
- (NSString *)escapedString;

@end
