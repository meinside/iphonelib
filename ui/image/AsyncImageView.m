//
//  AsyncImageView.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 01. 24.
//
//  last update: 11.04.28.
//

#import "AsyncImageView.h"

#import "Logging.h"


@implementation AsyncImageView

@synthesize currentUrl;
@synthesize delegate;

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
	if((self = [super initWithCoder:aDecoder]))
	{
        // Initialization code
		[self setup];
	}
	return self;
}

- (id)initWithImage:(UIImage *)anImage highlightedImage:(UIImage *)aHighlightedImage
{
	if((self = [super initWithImage:anImage 
				   highlightedImage:aHighlightedImage]))
	{
        // Initialization code
		[self setup];
	}
	return self;
}

- (id)initWithImage:(UIImage *)anImage
{
	if((self = [super initWithImage:anImage]))
	{
        // Initialization code
		[self setup];
	}
	return self;
}

- (id)initWithFrame:(CGRect)aFrame
{
    if((self = [super initWithFrame:aFrame]))
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
	@synchronized(self)
	{
		[http cancelCurrentConnection];
		
		self.currentUrl = url;
		self.image = nil;
		
		//start indicator
		[indicator startAnimating];

		return [http sendAsyncGetRequestWithURL:url 
									 parameters:params 
						 additionalHeaderFields:headerFields
								timeoutInterval:timeout
											 to:self 
									   selector:@selector(receiveImage:)];
	}
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
			
			[delegate asyncImageView:self 
					 didReceiveImage:self.image 
							imageUrl:self.currentUrl];
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
	[http cancelCurrentConnection];
	[http release];
	[indicator release];
	[currentUrl release];
	
    [super dealloc];
}

@end
