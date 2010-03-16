/*
 Copyright (c) 2010, Sungjin Han <meinside@gmail.com>
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
  * Neither the name of meinside nor the names of its contributors may be
    used to endorse or promote products derived from this software without
    specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 */
//
//  DeviceUtil.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 12. 15.
//
//  last update: 10.02.22.
//

#import "DeviceUtil.h"


@implementation DeviceUtil

#pragma mark -
#pragma mark network-related functions

+ (BOOL)checkConnection:(SCNetworkReachabilityFlags*)flags
{
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	
	SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr*)&zeroAddress);
	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, flags);
	CFRelease(defaultRouteReachability);
	
	if(!didRetrieveFlags)
		return NO;
	return YES;
}

+ (BOOL)connectedToNetwork
{
	SCNetworkReachabilityFlags flags;
	if(![DeviceUtil checkConnection:&flags])
		return NO;
	
	BOOL isReachable = flags & kSCNetworkReachabilityFlagsReachable;
	BOOL needsConnection = flags & kSCNetworkReachabilityFlagsConnectionRequired;
	
	return (isReachable && !needsConnection) ? YES : NO;
}

+ (BOOL)connectedToWiFi
{
	SCNetworkReachabilityFlags flags;
	if(![DeviceUtil checkConnection:&flags])
		return NO;
	
	BOOL isReachable = flags & kSCNetworkReachabilityFlagsReachable;
	BOOL needsConnection = flags & kSCNetworkReachabilityFlagsConnectionRequired;
	BOOL cellConnected = flags & kSCNetworkReachabilityFlagsTransientConnection;
	
	return (isReachable && !needsConnection && !cellConnected) ? YES : NO;
}

#pragma mark -
#pragma mark get device's attributes/information

+ (NSString*)UDID
{
	return [[UIDevice currentDevice] uniqueIdentifier];
}

+ (NSString*)name
{
	return [[UIDevice currentDevice] name];
}

+ (NSString*)model
{
	return [[UIDevice currentDevice] model];
}

+ (NSString*)systemVersion
{
	return [[UIDevice currentDevice] systemVersion];
}

+ (NSString*)systemName
{
	return [[UIDevice currentDevice] systemName];
}

#pragma mark -
#pragma mark functions that check device features

//check: http://developer.apple.com/iphone/library/documentation/General/Reference/InfoPlistKeyReference/Articles/iPhoneOSKeys.html#//apple_ref/doc/uid/TP40009252-SW3

+ (BOOL)cameraSupported
{
	return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

+ (BOOL)compassSupported
{
	CLLocationManager* location = [[CLLocationManager alloc] init];
	BOOL supported = location.headingAvailable;
	[location release];
	return supported;
}

@end
