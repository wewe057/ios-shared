//
//  SDLog.h
//
//  Created by brandon on 2/12/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <Foundation/Foundation.h>

// this turns off logging if DEBUG is not defined in the target
// assuming one is using SDLog everywhere to log to console.

#ifdef DEBUG
#define SDLog NSLog
#else
#define SDLog
#endif