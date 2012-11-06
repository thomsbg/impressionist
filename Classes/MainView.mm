//
//  MainView.m
//  Impressionist
//
//  Created by Stephanie Abascal on 1/24/09.
//  Copyright Stephanie Abascal 2009. All rights reserved.
//

#import "MainView.h"
#import <QuartzCore/QuartzCore.h>

static unsigned char clamp(double input) {
	if (input > 255.0)
		return 255;
	else if (input < 0.0)
		return 0.0;
	else
		return (unsigned char)input;
}

static unsigned char* getPixel(int x, int y, int numChannels, const unsigned char* sourceBuffer,
                               int srcBufferWidth, int srcBufferHeight) {
	if (x < 0)
		x = 0;
	else if  (x >= srcBufferWidth)
		x = srcBufferWidth-1;
        
    if (y < 0)
        y = 0;
	if (y >= srcBufferHeight)
		y = srcBufferHeight-1;
    
	return (unsigned char*)(sourceBuffer + numChannels*(y*srcBufferWidth+x));
}


// TODO: Implement this function!
/*
 *	INPUT: 
 *		sourceBuffer:		the original image buffer, 
 *		srcBufferWidth:		the width of the image buffer
 *		srcBufferHeight:	the height of the image buffer
 *		numChannels:	the number of channels int the buffers (i.e. 3 for color and 1 for grayscale) 
 *							the buffer is arranged such that 
 *							origImg[3*(row*srcBufferWidth+column)+0], 
 *							origImg[3*(row*srcBufferWidth+column)+1], 
 *							origImg[3*(row*srcBufferWidth+column)+2]
 *							are R, G, B values for pixel at (column, row).
 *		destBuffer:			the image buffer to put the resulting
 *							image in.  It is always the same size
 *							as the source buffer.
 *
 *      filterKernel:		the 2D filter kernel,
 *		knlWidth:			the width of the kernel
 *		knlHeight:			the height of the kernel
 *
 *		divisor, offset:	each pixel after filtering should be
 *							divided by divisor and then added by offset
 */
static void applyFilter( const unsigned char* sourceBuffer,
						int srcBufferWidth, int srcBufferHeight,
						int numChannels,
						unsigned char* destBuffer,
						const double *filterKernel, 
						int knlWidth, int knlHeight, 
						double divisor, double offset )
{
    // Implement me!
}

@implementation MainView

@synthesize brush;
@synthesize size;
@synthesize opacity;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
		self.userInteractionEnabled = YES;
		brush = 0;
		rawData = 0;
		cached = 0;
		
		srand ( time(NULL) );
    }
	
    return self;
}

- (void)drawInContext:(CGContextRef)context {
	
	CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
	CGContextFillRect(context, self.bounds);
	if (cached) {
		CGContextDrawImage(context, self.bounds, cached);
	}
	
	if (rawData == 0) return;
	
	for (std::vector<Stroke>::iterator I = strokes.begin(), E = strokes.end(); I != E; ++I) {
		Stroke s = *I;
		
		switch (s.type) {
            // Used to draw points.
            // TODO: add alpha parameter.
			case 0:
				if (s.location.x > imgWidth || s.location.y > imgHeight)
					CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
				else {
					int byteIndex = (bytesPerRow * (int)s.location3.y) + (int)s.location3.x * bytesPerPixel;
					unsigned char red = rawData[byteIndex];
					unsigned char green = rawData[byteIndex+1];
					unsigned char blue = rawData[byteIndex+2];
					
					CGContextSetRGBFillColor(context, red / 255.0, green / 255.0, blue / 255.0, 1.0);
				}
				CGContextFillRect(context, CGRectMake(s.location.x, s.location.y, s.strokeWidth, s.strokeWidth));
				break;
            // TODO: implement circles and lines.
			case 1:
				break;
			case 2:
				break;
			default:
                // Do nothing.
                break;
		}
	}	
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
	CGRect bounds = self.bounds;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	[self drawInContext:context];
}


- (void)dealloc {
    [super dealloc];
}

- (void)cacheView {
	CGContextRef mainViewContentContext;
    CGColorSpaceRef colorSpace;
	
    colorSpace = CGColorSpaceCreateDeviceRGB();
	
	// create a bitmap graphics context the size of the image
    mainViewContentContext = CGBitmapContextCreate (NULL, self.bounds.size.width, self.bounds.size.height, 8,0, colorSpace, kCGImageAlphaPremultipliedLast);
	
	// free the rgb colorspace
    CGColorSpaceRelease(colorSpace);	
	
	if (mainViewContentContext==NULL)
		return;
	
	// offset the context. This is necessary because, by default, the  layer created by a view for
	// caching its content is flipped. But when you actually access the layer content and have
	// it rendered it is inverted. Since we're only creating a context the size of our 
	// reflection view (a fraction of the size of the main view) we have to translate the context the
	// delta in size, render it, and then translate back (we could have saved/restored the graphics 
	// state
	
	// render the layer into the bitmap context
	[self.layer renderInContext:mainViewContentContext];
	
	// Create CGImageRef of the main view bitmap content, and then
	// release that bitmap context
	CGImageRef oldCached = cached;
	cached = CGBitmapContextCreateImage(mainViewContentContext);
	if (oldCached)
		CGImageRelease(oldCached);
	CGImageRetain(cached);
	
	CGContextRelease(mainViewContentContext);
	
	strokes.clear();
}

- (void)handleTouch:(UITouch*)touch {
	if (strokes.size() > 100) {
		[self cacheView];
	}
	
	CGPoint location = [touch locationInView:self];
	
	if (location.x < 0.0 || location.y < 0.0) return;
	if (location.x > imgWidth || location.y > imgHeight) return;
	
	Stroke s;

	
    // TODO: Implement the other brush types!
    // Do not implement curves (unless for extra credit).
	switch (brush) {
		case 0:
			// point
			s = Stroke(brush, location, opacity.value / 255.0);
			s.strokeWidth = size.value;
			s.location3 = location;
			strokes.push_back(s);
			break;
		case 1:
			// circle
			break;
		case 2:
			// line
			break;
		case 3:
			// scattered point
			break;
		case 4:
			// scattered circle
			break;
		case 5:
			//scattered line
			break;
		case 6:
			// curves
            // OPTIONAL
            break;
        case 7:
            // gradient scattered line
            break;
        case 8:
            // movement-oriented scattered line
            break;
        case 9:
            // sharpen
            break;
        case 10:
            // blur
			break;
	}
	
	
	[self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*) event {
	UITouch* touch = [touches anyObject];
	[self handleTouch:touch];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*) event {
	UITouch* touch = [touches anyObject];
	[self handleTouch:touch];
}

- (void)setImage:(UIImage*)paintImage {
	CGImageRef oldCached = cached;
	cached = 0;
	CGImageRelease(oldCached);
	strokes.clear();
	
	if (rawData) {
		unsigned char* oldData = rawData;
		rawData = 0;
		free(oldData);
	}
	
	// First get the image into your data buffer
	CGImageRef image = [paintImage CGImage];
	imgWidth = CGImageGetWidth(image);
	imgHeight = CGImageGetHeight(image);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	rawData = (unsigned char*)malloc(imgHeight * imgWidth * 4);
	bytesPerPixel = 4;
	bytesPerRow = bytesPerPixel * imgWidth;
	NSUInteger bitsPerComponent = 8;
	CGContextRef ctx = CGBitmapContextCreate(rawData, imgWidth, imgHeight, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);	
	CGContextDrawImage(ctx, CGRectMake(0, 0, imgWidth, imgHeight), image);
	CGColorSpaceRelease(colorSpace);
	CGContextRelease(ctx);
	
	[self computeGradient];
	[self setNeedsDisplay];
}

- (void)computeGradient {
	if (x_grad) free(x_grad);
	if (y_grad) free(y_grad);
	
	x_grad = (unsigned char*)malloc(imgHeight * imgWidth);
	y_grad = (unsigned char*)malloc(imgHeight * imgWidth);
	
	unsigned char* bw_img = (unsigned char*)malloc(imgHeight * imgWidth);
	unsigned char* tmp_img = (unsigned char*)malloc(imgHeight * imgWidth);
	unsigned char* smoothed_img = (unsigned char*)malloc(imgHeight * imgWidth);
	
	for (unsigned x = 0; x < imgWidth; ++x) {
		for (unsigned y = 0; y < imgHeight; ++y) {
			float val = 0.299 * rawData[(bytesPerRow * y) + x * bytesPerPixel];
			val += 0.587 * rawData[(bytesPerRow * y) + x * bytesPerPixel + 1];
			val += 0.114 * rawData[(bytesPerRow * y) + x * bytesPerPixel + 2];
			
			bw_img[y*imgWidth+x] = (unsigned char)val;
		}
	}
	
	double gauss_filter[5] = { 1.0, 4.0, 7.0, 4.0, 1.0 };
	
	applyFilter(bw_img, imgWidth, imgHeight, 1, tmp_img,
				gauss_filter, 5, 1, 17.0, 0.0);
	applyFilter(bw_img, imgWidth, imgHeight, 1, smoothed_img,
				gauss_filter, 1, 5, 17.0, 0.0);
	
	free(bw_img);
	
	double x_filter[9] = { 1.0, 0.0, -1.0, 2.0, 0.0, -2.0, 1.0, 0.0, -1.0};
	double y_filter[9] = { 1.0, 2.0, 1.0, 0.0, 0.0, 0.0, -1.0, -2.0, -1.0};
	
	applyFilter(smoothed_img, imgWidth, imgHeight, 1, x_grad,
					  x_filter, 3, 3, 1.0, 127.0);
	applyFilter(smoothed_img, imgWidth, imgHeight, 1, y_grad,
					  y_filter, 3, 3, 1.0, 127.0);
	
	free(smoothed_img);
}

@end
