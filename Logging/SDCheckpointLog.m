//
//  SDCheckpointLog.m
//  walmart
//
//  Created by Joel Bernstein on 11/8/11.
//  Copyright (c) 2011 Walmart. All rights reserved.
//

#import "SDCheckpointLog.h"

#ifdef TESTFLIGHT
    #import "TestFlight.h"
#endif

@implementation SDCheckpointLog

+(void)passCheckpoint:(NSString*)checkpointName
{
    #ifdef TESTFLIGHT
        [TestFlight passCheckpoint:checkpointName];
    #endif
    
    SDLog(@"Checkpoint Passed: %@", checkpointName);
}

+(void)passCheckpointVCDidAppearWithFilePath:(const char*)filePath
{
    NSString* fileName = [[[NSString stringWithUTF8String:filePath] lastPathComponent] stringByDeletingPathExtension];
    
    [self passCheckpoint:[NSString stringWithFormat:@"VC %@ Did Appear", fileName]];
}

+(void)passCheckpointServiceCallBegan:(NSString*)requestName url:(NSURL*)url postParams:(NSString*)postParams
{
    if(postParams)
    {
        [self passCheckpoint:[NSString stringWithFormat:@"Began Service Call: %@  URL: %@  POST: %@", requestName, url, postParams]];
    }
    else
    {
        [self passCheckpoint:[NSString stringWithFormat:@"Began Service Call: %@  URL: %@", requestName, url]];
    }
}

+(void)passCheckpointServiceCallFinished:(NSString*)requestName
{
    [self passCheckpoint:[NSString stringWithFormat:@"Finished Service Call: %@", requestName]];
}

@end