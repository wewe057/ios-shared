//
//  NSDate+SDExtensions.m
//  SetDirection
//
//  Created by Sam Grover on 3/8/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import "NSDate+SDExtensions.h"


@implementation NSDate (SDExtensions)

+ (NSDate *)dateFromISO8601String:(NSString *)argDateString
{
    static NSDateFormatter *sFormatter = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sFormatter = [[NSDateFormatter alloc] init];
        [sFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [sFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    });
    
	return [sFormatter dateFromString:argDateString];
}

+ (NSDate *)dateFromRFC822String:(NSString *)argDateString
{
	static NSDateFormatter *sFormatter = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sFormatter = [[NSDateFormatter alloc] init];
        [sFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [sFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    });
    
    return [sFormatter dateFromString:argDateString];
}

/**
 Takes a string of format M/d/y and returns an NSDate.
 */
+ (NSDate *)dateFromMonthDayYearString:(NSString *)argDateString
{
    static NSDateFormatter *sFormatter = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sFormatter = [[NSDateFormatter alloc] init];
        [sFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [sFormatter setDateFormat:@"M/d/y"];
    });
    
    return [sFormatter dateFromString:argDateString];
}

+ (NSDate *)dateAtBeginningOfMonthForDate:(NSDate *)inputDate
{
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];
    
    // Selectively convert the date components (year, month) of the input date
    NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:inputDate];
    
    // Set the time components manually
    [dateComps setHour:0];
    [dateComps setMinute:0];
    [dateComps setSecond:0];
    [dateComps setDay:1];
	
    // Convert back
    NSDate *beginningOfMonth = [calendar dateFromComponents:dateComps];
    return beginningOfMonth;
}


// ---------------------------------------------------------------- //
// Time interval comparison convenience methods

-(BOOL)happenedMoreThanNSecondsAgo:(NSInteger)numSeconds
{
	if([self timeIntervalSinceNow] < -numSeconds)
	{
		return YES;
	}
	return NO;
}

-(BOOL)happenedMoreThanNMinutesAgo:(NSInteger)numMinutes
{
	return [self happenedMoreThanNSecondsAgo: numMinutes * 60];
}

-(BOOL)happenedMoreThanNHoursAgo:(NSInteger)numHours
{
	return [self happenedMoreThanNMinutesAgo: numHours * 60];
}

-(BOOL)happenedMoreThanNDaysAgo:(NSInteger)numDays
{
	return [self happenedMoreThanNHoursAgo: numDays * 24];
}

-(BOOL)happenedLessThanNSecondsAgo:(NSInteger)numSeconds
{
	if([self timeIntervalSinceNow] > -numSeconds)
	{
		return YES;
	}	
	return NO;
}

-(BOOL)happenedLessThanNMinutesAgo:(NSInteger)numMinutes
{
	return [self happenedLessThanNSecondsAgo: numMinutes * 60];
}

-(BOOL)happenedLessThanNHoursAgo:(NSInteger)numHours
{
	return [self happenedLessThanNMinutesAgo: numHours * 60];
}

-(BOOL)happenedLessThanNDaysAgo:(NSInteger)numDays
{
	return [self happenedLessThanNHoursAgo: numDays * 24];
}

@end
