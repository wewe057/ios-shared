//
//  ios-shared.h
//  ios-shared
//
//  Created by Brandon Sneed on 3/15/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#ifdef __OBJC__


#define __deprecated__(s) __attribute__((deprecated(s)))


#define strongify(v) \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Wshadow\"") \
    try {} @finally {} \
    __strong __typeof(v) v = v ## _weak_ \
    _Pragma("clang diagnostic pop")

#define weakify(v) \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Wshadow\"") \
    try {} @finally {} \
    __weak __typeof(v) v ## _weak_ = v \
    _Pragma("clang diagnostic pop")

#define unsafeify(v) \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Wshadow\"") \
    try {} @finally {} \
    __unsafe_unretained __typeof(v) v \
    _Pragma("clang diagnostic pop")


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
#import "UIViewController+SDExtensions.h"

#import "SDURLConnection.h"
#import "SDWebService.h"

#endif
