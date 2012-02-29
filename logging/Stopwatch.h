//
//  Stopwatch.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 02. 6.
//
//  last update: 10.07.21.
//

#pragma once
#import <Foundation/Foundation.h>


@interface Stopwatch : NSObject {

	NSTimeInterval lastStopTime;
	NSTimeInterval elapsedTime;
}

- (id)init;

+ (Stopwatch*)stopwatch;

- (NSTimeInterval)elapsedTime;

@property (nonatomic, getter=elapsedTime) NSTimeInterval elapsedTime;

@end
