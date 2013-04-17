//
//  ios-shared.h
//  ios-shared
//
//  Created by Brandon Sneed on 3/15/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#ifdef __OBJC__

#define __deprecated__(s) __attribute__((deprecated(s)))

#import "SDLog.h"
#import "NSObject+SDExtensions.h"
#import "NSString+SDExtensions.h"
#import "NSDate+SDExtensions.h"

#import "UIView+SDExtensions.h"
#import "NSArray+SDExtensions.h"
#import "NSDictionary+SDExtensions.h"
#import "NSData+SDExtensions.h"

#import "UIAlertView+SDExtensions.h"
#import "UIColor+SDExtensions.h"
#import "UIScreen+SDExtensions.h"
#import "UIView+SDExtensions.h"
#import "UIDevice+machine.h"

#import "SDURLConnection.h"
#import "SDWebService.h"

#endif