//
//  NSDate+SDExtensions.h
//  SetDirection
//
//  Created by Sam Grover on 3/8/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate (SDExtensions)

/**
 Creates an NSDate from a given ISO 8601 string date of the format `yyyy-MM-dd'T'HH:mm:ss'Z'`.
 */
+ (NSDate *)dateFromISO8601String:(NSString *)argDateString;

/**
 Creates an NSDate from a given RFC 822 string date of the format `yyyy-MM-dd'T'HH:mm:ssZZZ`.
 */
+ (NSDate *)dateFromRFC822String:(NSString *)argDateString;

/**
 Creates an NSDate from a string of the format `month/day/year`.
 */
+ (NSDate *)dateFromMonthDayYearString:(NSString *)argDateString;

/**
 Returns `YES` if the date represented by the receiver occurred more than `numSeconds` seconds ago. Returns `NO` otherwise.
 */
- (BOOL)happenedMoreThanNSecondsAgo:(NSInteger)numSeconds;

/**
 Returns `YES` if the date represented by the receiver occurred more than `numMinutes` minutes ago. Returns `NO` otherwise.
 */
- (BOOL)happenedMoreThanNMinutesAgo:(NSInteger)numMinutes;

/**
 Returns `YES` if the date represented by the receiver occurred more than `numHours` hours ago. Returns `NO` otherwise.
 */
- (BOOL)happenedMoreThanNHoursAgo:(NSInteger)numHours;

/**
 Returns `YES` if the date represented by the receiver occurred more than `numDays` days ago. Returns `NO` otherwise.
 */
- (BOOL)happenedMoreThanNDaysAgo:(NSInteger)numDays;

/**
 Returns `YES` if the date represented by the receiver occurred less than `numSeconds` seconds ago. Returns `NO` otherwise.
 */
- (BOOL)happenedLessThanNSecondsAgo:(NSInteger)numSeconds;

/**
 Returns `YES` if the date represented by the receiver occurred less than `numMinutes` minutes ago. Returns `NO` otherwise.
 */
- (BOOL)happenedLessThanNMinutesAgo:(NSInteger)numMinutes;

/**
 Returns `YES` if the date represented by the receiver occurred less than `numHours` hours ago. Returns `NO` otherwise.
 */
- (BOOL)happenedLessThanNHoursAgo:(NSInteger)numHours;

/**
 Returns `YES` if the date represented by the receiver occurred less than `numDays` days ago. Returns `NO` otherwise.
 */
- (BOOL)happenedLessThanNDaysAgo:(NSInteger)numDays;

@end
