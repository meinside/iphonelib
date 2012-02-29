//
//  LocalNotificationHelper.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 05. 25.
//
//  last update: 12.01.26.
//

#pragma once

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_4_0
#warning Do not use this if deployment target is lower than 4.0
#endif

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface LocalNotificationHelper : NSObject {

}


//interval = 0 when not repeated

+ (BOOL)scheduleLocalNotificationWithBody:(NSString*)alertBody 
								   action:(NSString*)alertAction 
									sound:(NSString*)soundName 
									badge:(NSInteger)appIconBadgeNumber 
								 userInfo:(id)userInfo 
									after:(NSUInteger)seconds
								 repeated:(NSCalendarUnit)interval;

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
								 repeated:(NSCalendarUnit)interval;

+ (BOOL)scheduleLocalNotificationWithBody:(NSString*)alertBody 
								   action:(NSString*)alertAction 
									sound:(NSString*)soundName 
									badge:(NSInteger)appIconBadgeNumber 
								 userInfo:(id)userInfo 
									   on:(NSDate*)date
								 repeated:(NSCalendarUnit)interval;

+ (BOOL)presentLocalNotificationNow:(UILocalNotification*)notification;

+ (BOOL)presentLocalNotificationNowWithBody:(NSString*)alertBody 
									 action:(NSString*)alertAction 
									  sound:(NSString*)soundName 
									  badge:(NSInteger)appIconBadgeNumber 
								   userInfo:(id)userInfo
								   repeated:(NSCalendarUnit)interval;

+ (BOOL)cancelAllLocalNotifications;

+ (NSArray*)scheduledLocalNotifications;

+ (BOOL)cancelLocalNotification:(UILocalNotification*)notification;

+ (UILocalNotification*)localNotificationWithBody:(NSString*)alertBody 
										   action:(NSString*)alertAction 
											sound:(NSString*)soundName 
											badge:(NSInteger)appIconBadgeNumber 
										 userInfo:(id)userInfo 
											   on:(NSDate*)date 
										 repeated:(NSCalendarUnit)interval;

@end
