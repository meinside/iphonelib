//
//  Stopwatch.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 02. 6.
//
//  last update: 11.03.14.
//

#import "Stopwatch.h"

#import "Logging.h"


@implementation Stopwatch

@synthesize elapsedTime;

#pragma mark -
#pragma mark initializers

- (id)init
{
	if((self = [super init]))
	{
		lastStopTime = CFAbsoluteTimeGetCurrent();
	}
	return self;
}

+ (Stopwatch*)stopwatch
{
	return [[[Stopwatch alloc] init] autorelease];
}

#pragma mark -
#pragma mark getter functions

- (NSTimeInterval)elapsedTime
{
	NSTimeInterval timeNow = CFAbsoluteTimeGetCurrent();
	NSTimeInterval timeElapsed = timeNow - lastStopTime;

	lastStopTime = timeNow;
	elapsedTime = timeElapsed;

	return elapsedTime;
}

@end
