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
#import "UIView+SDExtensions.h"

#endif