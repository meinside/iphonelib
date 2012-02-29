//
//  DeviceUtil.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 12. 15.
//
//  last update: 11.04.27.
//

#import "DeviceUtil.h"

#import "Logging.h"

#import <sys/types.h>
#import <sys/socket.h>
#import <sys/sysctl.h>
#import <sys/time.h>
#import <netinet/in.h>
#import <net/if_dl.h>
#import <netdb.h>
#import <errno.h>
#import <arpa/inet.h>
#import <unistd.h>
#import <ifaddrs.h>

#if !defined(IFT_ETHER)
#define IFT_ETHER 0x6	/* Ethernet CSMACD */
#endif

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

//referenced: http://www.iphonedevsdk.com/forum/iphone-sdk-development/4970-iphone-mac-address.html
+ (NSString*)MACAddress
{
	NSMutableString* result = [NSMutableString string];
	
	BOOL success;
	struct ifaddrs* addrs;
	const struct ifaddrs* cursor;
	const struct sockaddr_dl* dlAddr;
	const uint8_t * base;
	int i;
	
	success = (getifaddrs(&addrs) == 0);
	if(success)
	{
		cursor = addrs;
		while(cursor != NULL)
		{
			if((cursor->ifa_addr->sa_family == AF_LINK) && (((const struct sockaddr_dl *) cursor->ifa_addr)->sdl_type == IFT_ETHER))
			{
				dlAddr = (const struct sockaddr_dl *) cursor->ifa_addr;

				base = (const uint8_t *) &dlAddr->sdl_data[dlAddr->sdl_nlen];
				
				for(i=0; i<dlAddr->sdl_alen; i++)
				{
					if(i != 0)
					{
						[result appendString:@":"];
					}
					[result appendFormat:@"%02x", base[i]];
				}
			}
			cursor = cursor->ifa_next;
		}
		freeifaddrs(addrs);
	}
	
	DebugLog(@"mac address = %@", result);

	return result;
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

+ (NSString*)appVersion
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (NSString*)bundleIdentifier
{
	return [[NSBundle mainBundle] bundleIdentifier];
}

//referenced: http://iphonedevelopertips.com/device/determine-if-iphone-is-3g-or-3gs-determine-if-ipod-is-first-or-second-generation.html
+ (NSString*)machine
{ 
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0); 

	char *name = malloc(size);
	sysctlbyname("hw.machine", name, &size, NULL, 0);

	NSString *machine = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
	free(name);

	return machine;
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
#ifdef __IPHONE_4_0
	return [CLLocationManager headingAvailable];
#else	//location.headingAvailable deprecated
	CLLocationManager* location = [[CLLocationManager alloc] init];
	BOOL supported = location.headingAvailable;
	[location release];
	return supported;
#endif
}

@end
