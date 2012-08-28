//
//  AsyncImageView.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 01. 24.
//
//  last update: 12.08.28.
//


#pragma once
#import <UIKit/UIKit.h>

#import "HTTPUtil.h"

@protocol AsyncImageViewDelegate;

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
 *	AsyncImageView* image = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
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
	NSURL* currentUrl;

	id<AsyncImageViewDelegate> delegate;
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

@property (retain) NSURL* currentUrl;
@property (assign) id<AsyncImageViewDelegate> delegate;

@end


/**
 * if you wanna reuse the downloaded image or something, use following delegate functions:
 */
@protocol AsyncImageViewDelegate

- (void)asyncImageView:(AsyncImageView*)asyncImageView didReceiveImage:(UIImage*)image imageUrl:(NSURL*)url;

@end
