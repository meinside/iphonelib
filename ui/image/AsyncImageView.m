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
//  AsyncImageView.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 01. 24.
//
//  last update: 10.07.21.
//

#import "AsyncImageView.h"

#import "Logging.h"


@implementation AsyncImageView

#pragma mark -
#pragma mark initializers

- (void)setup
{
	http = [[HTTPUtil alloc] init];
	
	indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	indicator.center = self.center;
	indicator.hidesWhenStopped = YES;
	[self addSubview:indicator];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if(self = [super initWithCoder:aDecoder])
	{
        // Initialization code
		[self setup];
	}
	return self;
}

- (id)initWithImage:(UIImage *)anImage highlightedImage:(UIImage *)aHighlightedImage
{
	if(self = [super initWithImage:anImage 
				  highlightedImage:aHighlightedImage])
	{
        // Initialization code
		[self setup];
	}
	return self;
}

- (id)initWithImage:(UIImage *)anImage
{
	if(self = [super initWithImage:anImage])
	{
        // Initialization code
		[self setup];
	}
	return self;
}

- (id)initWithFrame:(CGRect)aFrame {
    if (self = [super initWithFrame:aFrame])
	{
        // Initialization code
		[self setup];
    }
    return self;
}


#pragma mark -
#pragma mark functions for loading images

- (BOOL)loadImageWithURLString:(NSString*)urlString
					parameters:(NSDictionary*)params 
		additionalHeaderFields:(NSDictionary*)headerFields 
			   timeoutInterval:(NSTimeInterval)timeout
{
	return [self loadImageWithURL:[NSURL URLWithString:urlString] 
					   parameters:params 
		   additionalHeaderFields:headerFields 
				  timeoutInterval:timeout];
}

- (BOOL)loadImageWithURL:(NSURL*)url 
			  parameters:(NSDictionary*)params 
  additionalHeaderFields:(NSDictionary*)headerFields 
		 timeoutInterval:(NSTimeInterval)timeout
{
	//start indicator
	[indicator startAnimating];
	
	return [http sendAsyncGetRequestWithURL:url 
								 parameters:params 
					 additionalHeaderFields:headerFields
							timeoutInterval:timeout
										 to:self 
								   selector:@selector(receiveImage:)];
}


#pragma mark -
#pragma mark etc.

- (void)receiveImage:(NSDictionary*)response
{
	int statusCode = [[response objectForKey:kHTTP_ASYNC_RESULT_CODE] intValue];
	if(statusCode == 200)
	{
		NSData* imageData = (NSData*)[response objectForKey:kHTTP_ASYNC_RESULT_DATA];
		@try
		{
			self.image = [UIImage imageWithData:imageData];
		}
		@catch (NSException * e)
		{
			self.image = nil;
			
			DebugLog(@"exception after receiving image data: %@ (%@ / %d bytes)", 
					 [e description], 
					 [response objectForKey:kHTTP_ASYNC_RESULT_CONTENTTYPE], 
					 [imageData length]);
		}
	}
	[self setNeedsLayout];
	
	[indicator stopAnimating];	//stop indicator
}

- (UIImage*)loadedImage
{
	return self.image;
}

- (void)dealloc {
	
	[http release];
	[indicator release];
	
    [super dealloc];
}


@end
