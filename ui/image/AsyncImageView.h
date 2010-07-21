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
//  AsyncImageView.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 01. 24.
//
//  last update: 10.07.21.
//


#pragma once
#import <UIKit/UIKit.h>

#import "HTTPUtil.h"


/*
 * when using with table view, do like this:
 * (referenced: http://www.markj.net/iphone-asynchronous-table-image )
 * 
 *	//blah blah ...
 * 
 *	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 *	if (cell == nil) {
 *		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
 *	}
 *	else {
 *		AsyncImageView* oldImage = (AsyncImageView*)[cell.contentView viewWithTag:999];
 *		[oldImage removeFromSuperview];
 *	}
 * 
 *	//blah blah ...
 * 
 *	CGRect frame;
 *	frame.size.width = 40; frame.size.height = 40;
 *	frame.origin.x = 0; frame.origin.y = 0;
 * 
 *	AsyncImageView* image = [[AsyncImageView alloc] initWithFrame:frame];
 *	[image loadImageWithURLString:imageUrl parameters:nil additionalHeaderFields:nil timeoutInterval:10.0];
 *	image.tag = 999;
 *	[cell.contentView addSubview:image];
 *	[image release];
 * 
 *	return cell;
 * 
 */

@interface AsyncImageView : UIImageView {
	
	HTTPUtil* http;
	UIActivityIndicatorView* indicator;

}

- (BOOL)loadImageWithURLString:(NSString*)urlString
					parameters:(NSDictionary*)params 
		additionalHeaderFields:(NSDictionary*)headerFields 
			   timeoutInterval:(NSTimeInterval)timeout;
- (BOOL)loadImageWithURL:(NSURL*)url 
			  parameters:(NSDictionary*)params 
  additionalHeaderFields:(NSDictionary*)headerFields 
		 timeoutInterval:(NSTimeInterval)timeout;

- (void)receiveImage:(NSDictionary*)response;

- (UIImage*)loadedImage;

@end
