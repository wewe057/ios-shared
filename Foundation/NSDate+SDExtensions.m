//
//  NSDate+SDExtensions.m
//  walmart
//
//  Created by Sam Grover on 3/8/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import "NSDate+SDExtensions.h"


@implementation NSDate (SDExtensions)

+ (NSDate *)dateFromISO8601String:(NSString *)argDateString
{
	NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
	return [formatter dateFromString:argDateString];
}

+ (NSDate *)dateFromRFC822String:(NSString *)argDateString
{
	NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
	return [formatter dateFromString:argDateString];
}

+ (NSDate *)dateFromRFC822String:(NSString *)argDateString maintainRFC822StringTimeZone:(BOOL)maintainRFC822StringTimeZone
{
    if (maintainRFC822StringTimeZone) {
        NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];

        NSString *timeZoneString = [argDateString substringWithRange:NSMakeRange(19, 3)]; // e.g. "2011-05-06T21:30:00-0700"
        int hourOffset = [timeZoneString intValue];
        NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:(hourOffset * 3600)]; // -8 * 3600 for PST
        [formatter setTimeZone:timeZone];
        
        return [formatter dateFromString:argDateString];
    } else {
        return [NSDate dateFromRFC822String:argDateString];
    }
}

@end
