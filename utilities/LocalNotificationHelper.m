//
//  LocalNotificationHelper.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 05. 25.
//
//  last update: 10.08.12.
//

#import "LocalNotificationHelper.h"

#import "Logging.h"


@implementation LocalNotificationHelper

//since __IPHONE_4_0
#ifdef __IPHONE_4_0

#pragma mark -
#pragma mark functions for scheduling local notifications

+ (BOOL)scheduleLocalNotificationWithBody:(NSString*)alertBody 
								   action:(NSString*)alertAction 
									sound:(NSString*)soundName 
									badge:(NSInteger)appIconBadgeNumber 
								 userInfo:(id)userInfo 
									after:(NSUInteger)seconds
								 repeated:(NSCalendarUnit)interval
{
	return [self scheduleLocalNotificationWithBody:alertBody 
											action:alertAction 
											 sound:soundName 
											 badge:appIconBadgeNumber 
										  userInfo:userInfo 
												on:[NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval)seconds]
										  repeated:(NSCalendarUnit)interval];
}

+ (BOOL)scheduleLocalNotificationWithBody:(NSString*)alertBody 
								   action:(NSString*)alertAction 
									sound:(NSString*)soundName 
									badge:(NSInteger)appIconBadgeNumber 
								 userInfo:(id)userInfo 
									 year:(NSUInteger)year 
									month:(NSUInteger)month 
									  day:(NSUInteger)day 
									 hour:(NSUInteger)hour 
								   minute:(NSUInteger)minute
								 repeated:(NSCalendarUnit)interval
{
	NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
	NSDateComponents* dateComp = [[NSDateComponents alloc] init];
	[dateComp setYear:year];
	[dateComp setMonth:month];
	[dateComp setDay:day];
	[dateComp setHour:hour];
	[dateComp setMinute:minute];
	NSDate* date = [calendar dateFromComponents:dateComp];
	[dateComp release];
	
	if(!date)
		return NO;
	
	return [self scheduleLocalNotificationWithBody:alertBody 
											action:alertAction 
											 sound:soundName 
											 badge:appIconBadgeNumber 
										  userInfo:userInfo 
												on:date
										  repeated:interval];
}

+ (BOOL)scheduleLocalNotificationWithBody:(NSString*)alertBody 
								   action:(NSString*)alertAction 
									sound:(NSString*)soundName 
									badge:(NSInteger)appIconBadgeNumber 
								 userInfo:(id)userInfo 
									   on:(NSDate*)date
								 repeated:(NSCalendarUnit)interval
{
	UILocalNotification* noti = [self localNotificationWithBody:alertBody 
														 action:alertAction 
														  sound:soundName 
														  badge:appIconBadgeNumber 
													   userInfo:userInfo 
															 on:date
													   repeated:interval];
	if(!noti)
		return NO;
	
	[[UIApplication sharedApplication] scheduleLocalNotification:noti];
	
	return YES;
}

#pragma mark -
#pragma mark functions for invoking local notifications immediately

+ (BOOL)presentLocalNotificationNow:(UILocalNotification*)notification
{
	[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
	
	return YES;
}

+ (BOOL)presentLocalNotificationNowWithBody:(NSString*)alertBody 
									 action:(NSString*)alertAction 
									  sound:(NSString*)soundName 
									  badge:(NSInteger)appIconBadgeNumber 
								   userInfo:(id)userInfo
								   repeated:(NSCalendarUnit)interval
{
	UILocalNotification* noti = [self localNotificationWithBody:alertBody 
														 action:alertAction 
														  sound:soundName 
														  badge:appIconBadgeNumber 
													   userInfo:userInfo 
															 on:nil
													   repeated:interval];
	if(!noti)
		return NO;
	
	return [self presentLocalNotificationNow:noti];
}

#pragma mark -
#pragma mark functions for manipulating already-scheduled local notifications

+ (BOOL)cancelAllLocalNotifications
{
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	
	return YES;
}

+ (NSArray*)scheduledLocalNotifications
{
	return [[UIApplication sharedApplication] scheduledLocalNotifications];
}

+ (BOOL)cancelLocalNotification:(UILocalNotification*)notification
{
	[[UIApplication sharedApplication] cancelLocalNotification:notification];
	
	return YES;
}

#pragma mark -
#pragma mark etc.

+ (UILocalNotification*)localNotificationWithBody:(NSString*)alertBody 
										   action:(NSString*)alertAction 
											sound:(NSString*)soundName 
											badge:(NSInteger)appIconBadgeNumber 
										 userInfo:(id)userInfo 
											   on:(NSDate*)date
										 repeated:(NSCalendarUnit)interval
{
	UILocalNotification* noti = [[UILocalNotification alloc] init];
	if(!noti)
		return nil;
	
	noti.fireDate = date;
	noti.timeZone = [NSTimeZone defaultTimeZone];
	noti.alertBody = alertBody;
	noti.alertAction = alertAction;
	if(!alertAction)
		noti.hasAction = NO;
	noti.soundName = (soundName ? soundName : UILocalNotificationDefaultSoundName);
	noti.applicationIconBadgeNumber = appIconBadgeNumber;
	noti.userInfo = userInfo;
	noti.repeatInterval = interval;

	return [noti autorelease];
}

#endif

@end
