//
//  ios-shared.h
//  ios-shared
//
//  Created by Brandon Sneed on 3/15/2013.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#ifdef __OBJC__

// Required frameworks
@import UIKit;
@import SystemConfiguration;

// Low level bits
#import "SDMacros.h"
#import "ObjectiveCGenerics.h"
#import "SDLog.h"

// Foundation Extensions
#import "NSError+SDExtensions.h"
#import "NSObject+SDExtensions.h"
#import "NSString+SDExtensions.h"
#import "NSDate+SDExtensions.h"
#import "NSRunLoop+SDExtensions.h"
#import "NSArray+SDExtensions.h"
#import "NSDictionary+SDExtensions.h"
#import "NSData+SDExtensions.h"

// UIKit Extensions
#import "UIAlertView+SDExtensions.h"
#import "UIColor+SDExtensions.h"
#import "UIScreen+SDExtensions.h"
#import "UIView+SDExtensions.h"
#import "UIDevice+machine.h"
#import "UIViewController+SDExtensions.h"
#import "SDAlertView.h"

// Application Additions
#import "SDApplication.h"

// Services
#import "SDURLConnection.h"
#import "SDWebService.h"
#import "SDWebService+SDProcessingBlocks.h"

#endif
