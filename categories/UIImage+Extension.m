//
//  UIImage+Extension.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 3. 5.
//
//  last update: 2014.04.07.
//

#import "UIImage+Extension.h"

#import "Logging.h"
#import "GraphicFilter.h"	//from: http://www.gdargaud.net/Hack/SourceCode.html


@implementation UIImage (UIImageExtension)

#pragma mark -
#pragma mark functions for applying various filters

- (UIImage*)filteredImageWithFilter:(void*)filter 
						 filterType:(FilterType)type
{
	CGImageRef imageRef = self.CGImage;
	CFDataRef imageData = CGDataProviderCopyData(CGImageGetDataProvider(imageRef));	//must be released later (1)
	
	size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
	size_t bitsPerPixel = CGImageGetBitsPerPixel(imageRef);
	size_t width = CGImageGetWidth(imageRef);
	size_t height = CGImageGetHeight(imageRef);
	CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
	
	//get bitmap bytes array
	unsigned char* pixels = (unsigned char*)CFDataGetBytePtr(imageData);
	size_t bytesWidth = bytesPerRow / (bitsPerPixel / 8);	//FIXXX: calculated width of bytes array is different from the width obtained from imageRef (seems to be Framework's bug or something)
	
	//apply filter
	switch(type)
	{
		case FilterType1x1:
			Filter1x1(pixels, (int)bytesPerRow, (int)bitsPerPixel, (int)width, (int)height, filter);
			break;
		case FilterType3x3:
			Filter3x3(pixels, (int)bytesPerRow, (int)bitsPerPixel, (int)width, (int)height, filter);
			break;
		case FilterType5x5:
			Filter5x5(pixels, (int)bytesPerRow, (int)bitsPerPixel, (int)width, (int)height, filter);
			break;
		case FilterTypeIC:
			Filter1C(pixels, (int)bytesPerRow, (int)bitsPerPixel, (int)width, (int)height, filter);
			break;
		default:
			//do nothing
			DebugLog(@"non-identified filter");
			break;
	}

	//fill up missing rgba values for each pixel
	//(CGBitmapContextCreate does not support 24-bit RGB data: http://stackoverflow.com/questions/1579631/converting-rgb-data-into-a-bitmap-in-objective-c-cocoa )
	unsigned char* rgba = NULL;
	switch(bitsPerPixel)
	{
		case 16:	//ARRRRRGGGGGBBBBB
			//TODO: not implemented yet
			break;
		case 24:	//RRRRRRRRGGGGGGGGBBBBBBBB
			alphaInfo = kCGImageAlphaNoneSkipLast;
			rgba = (unsigned char*)malloc(width * height * 4);	//must be released later (2)
			int i = 0, x, y;
			size_t originPos, newPos;
			for(y=0; y < height; y++)
			{
				for(x=0; x < width; x++)
				{
					originPos = 3 * (x + y * bytesWidth);
					newPos = 4 * i++;
					
					//R
					rgba[newPos] = pixels[originPos];
					//G
					rgba[newPos + 1] = pixels[originPos + 1];
					//B
					rgba[newPos + 2] = pixels[originPos + 2];
					//A (dummy)
					rgba[newPos + 3] = 0;
				}
			}
			break;
		case 32:	//AAAAAAAARRRRRRRRGGGGGGGGBBBBBBBB or RRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA
			rgba = pixels;
			break;
	}
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();	//must be released later (3)
	CGContextRef bitmapContext = CGBitmapContextCreate(rgba, width, height, 8, 4 * width, colorSpace, (CGBitmapInfo)alphaInfo);	//must be released later (4)
	CFRelease(colorSpace);	//released (3)
	
	CGImageRef convertedImage = CGBitmapContextCreateImage(bitmapContext);	//must be released later (5)
	
	UIImage *newUIImage = [UIImage imageWithCGImage:convertedImage];
	
	CFRelease(convertedImage);	//released (5)
	CFRelease(bitmapContext);	//released (4)
	if(bitsPerPixel == 24)
		free(rgba);	//released (2)
	CFRelease(imageData);	//released (1)
	
	return newUIImage;
}

@end
