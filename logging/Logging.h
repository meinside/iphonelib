//
//  Logging.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 02. 3.
//
//  last update: 10.02.03.
//

#pragma once

//works in DEBUG mode only
#ifndef __OPTIMIZE__
	#define DebugLog(s, ...) NSLog(@"%s(%d): %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
	#define DebugLog(s, ...) 
#endif

