//
//  MainView.m
//  Impressionist
//
//  Created by Stephanie Abascal on 1/24/09.
//  Copyright Stephanie Abascal 2009. All rights reserved.
//

#import "MainView.h"
#import <QuartzCore/QuartzCore.h>

static const int BRUSH_POINT = 0;
static const int BRUSH_CIRCLE = 1;
static const int BRUSH_LINE = 2;
static const int BRUSH_CURVE = 3;
static const int BRUSH_LINE_GRADIENT = 4;
static const int BRUSH_CURVE_GRADIENT = 5;
static const int BRUSH_LINE_MOVEMENT = 6;
static const int BRUSH_SHARPEN = 7;
static const int BRUSH_BLUR = 8;
static const int BRUSH_CUSTOM = 9;

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
	// Assume only odd kernel widths/heights
	int row, column, i, j, x, y, ch;
	unsigned char *dest_pixel, *neighbor_pixel;
	double *kernel_value;
	double *values = (double*)malloc(sizeof(double) * numChannels); // hold the computed values for each channel in a double to avoid overflow
	
	for (row = 0; row < srcBufferHeight; row++) {
		for (column = 0; column < srcBufferWidth; column++) { // go through each pixel in the image, row by row
			
			for (ch = 0; ch < numChannels; ch++) { // zero all values
				values[ch] = 0;
			}
			
			for (j = 0; j < knlHeight; j++) {
				for (i = 0; i < knlWidth; i++) { // for each value in the kernel
				
					x = column - knlWidth / 2 + i;
					y = row - knlHeight / 2 + j; // center kernel on the current pixel
					
					neighbor_pixel = getPixel(x, y, numChannels, sourceBuffer, srcBufferWidth, srcBufferHeight);
					kernel_value = (double*)( filterKernel + (j*knlWidth+i) );
					for (ch = 0; ch < numChannels; ch++) {
						// adds to the weighted sum of applying the kernel to surrounding pixels
						values[ch] += *(kernel_value) * neighbor_pixel[ch];
					}
				}
			}
			
			// get the pointer to the pixel in the destination buffer
			dest_pixel = getPixel(column, row, numChannels, destBuffer, srcBufferWidth, srcBufferHeight);
			for (ch = 0; ch < numChannels; ch++) {
				// divide by divisor, add offset, then clamp to range 0-255
				dest_pixel[ch] = clamp (values[ch] / divisor + offset);
			}
		}
	}
	
	free(values);
}

// draws a line with midpoint (x,y) with the given angle from horizontal and length
static void drawLine(CGContextRef context, unsigned x, unsigned y, float angle, int len) {
	CGContextSaveGState(context);
	// translate drawing context to starting point
	CGContextTranslateCTM( context, x, y );
	// rotate drawing context by angle
	CGContextRotateCTM( context, angle );
	CGContextSetLineWidth( context, 3.0 );
	CGContextSetLineCap( context, kCGLineCapRound );
	CGContextBeginPath( context );
	// context is now centered on midpoint, draw a line of length {len}
	CGContextMoveToPoint( context, -len / 2, 0 );
	CGContextAddLineToPoint( context, len / 2, 0 );
	CGContextStrokePath( context );
	CGContextRestoreGState(context);
}

// returns a stroke with the given attributes
static Stroke createStroke(int brush, CGPoint location, CGPoint prevLocation, float opacity, float angle, float size) {
	Stroke s = Stroke(brush, location, opacity / 255.0);
	s.prevLocation = prevLocation;
	s.angle = angle;
	s.size = size;
	return s;
}

@implementation MainView

@synthesize brush;
@synthesize size;
@synthesize opacity;
@synthesize scatter;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
		self.userInteractionEnabled = YES;
		brush = 0;
		rawData = 0;
		cached = 0;
		prev_angle = 0; // used for the motion based brush
		clearImage = 0;
		
		srand ( time(NULL) );
    }
	
    return self;
}

// determines and stores the color value for a stroke making sure it is in the image bounds
- (void)setFillColor:(Stroke) s context:(CGContextRef) context {
	int x = s.location.x;
	int y = s.location.y;
	if (x < 0) {
		x = 0;
	} else if (x >= imgWidth) {
		x = imgWidth-1;
	}
	if (y < 0) {
		y = 0;
	} else if (y >= imgHeight) {
		y = imgHeight-1;
	}
	
	int byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
	unsigned char red = rawData[byteIndex];
	unsigned char green = rawData[byteIndex+1];
	unsigned char blue = rawData[byteIndex+2];
	
	CGContextSetRGBFillColor(context, red / 255.0, green / 255.0, blue / 255.0, s.alpha);
	CGContextSetRGBStrokeColor(context, red / 255.0, green / 255.0, blue / 255.0, s.alpha);
}

// draws all strokes in the strokes stack
- (void)drawInContext:(CGContextRef)context {	
	CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
	CGContextFillRect(context, self.bounds);
	if (cached) {
		CGContextDrawImage(context, self.bounds, cached);
	}
	
	if (rawData == 0) return;
	
	for (std::vector<Stroke>::iterator I = strokes.begin(), E = strokes.end(); I != E; ++I) {
		Stroke s = *I;
		[self setFillColor:s context:context];
		
		if (s.type == BRUSH_POINT) { // points
			CGContextFillRect(context, CGRectMake(s.location.x - s.size / 2, s.location.y - s.size / 2, s.size, s.size));
		} else if (s.type == BRUSH_CIRCLE) { // circles
			CGContextFillEllipseInRect(context, CGRectMake(s.location.x - s.size / 2, s.location.y - s.size / 2, s.size, s.size));
		} else if (s.type == BRUSH_LINE || s.type == BRUSH_LINE_GRADIENT || s.type == BRUSH_LINE_MOVEMENT) { // lines
			drawLine(context, s.location.x, s.location.y, s.angle, s.size);
		} else if (s.type == BRUSH_SHARPEN || s.type == BRUSH_BLUR || s.type == BRUSH_CUSTOM) { // kernel based brush
			unsigned char* img;
			if (s.type == BRUSH_SHARPEN)
				img = sharpened;
			else if (s.type == BRUSH_BLUR)
				img = blurred;
			else
				img = custom;
			
			for (int j = s.location.y - s.size / 2; j < s.location.y + s.size / 2; j++) {
				for (int i = s.location.x - s.size / 2; i < s.location.x + s.size / 2; i++) {
					i = (i < imgWidth) ? i : imgWidth - 1;
					j = (j < imgHeight) ? j : imgHeight - 1;
					unsigned char* pixel = getPixel(i, j, 4, img, imgWidth, imgHeight);
					unsigned char red = pixel[0];
					unsigned char green = pixel[1];
					unsigned char blue = pixel[2];
					
					CGContextSetRGBFillColor(context, red / 255.0, green / 255.0, blue / 255.0, s.alpha);
					CGContextSetRGBStrokeColor(context, red / 255.0, green / 255.0, blue / 255.0, s.alpha);
					CGContextFillRect(context, CGRectMake(i, j, 1, 1));
				}
			}
		} else if (s.type == BRUSH_CURVE || s.type == BRUSH_CURVE_GRADIENT) { // curves
			CGContextSetLineWidth( context, 3.0 );
			CGContextSetLineCap( context, kCGLineCapRound );
			CGContextBeginPath( context );
			CGContextMoveToPoint( context, s.location.x, s.location.y );
			CGContextAddCurveToPoint( context, s.curvePoints[0], s.curvePoints[1], s.curvePoints[2], s.curvePoints[3], s.curvePoints[4], s.curvePoints[5]);
			CGContextStrokePath( context );
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
	CGPoint prevLocation = [touch previousLocationInView:self];
	
	// ignore touches outside the image
	if (location.x < 0.0 || location.y < 0.0) return;
	if (location.x > imgWidth || location.y > imgHeight) return;
	
	float angle;
	int numStrokes = scatter.on ? 4 : 1; // if scatter is on, make multiple (4) strokes

	int origX = location.x;
	int origY = location.y; // original touch location
	int dist = (int)size.value;
	int points[8];
	float gradX, gradY, dx, dy;
	
	for (int i = 0; i < numStrokes; i++) {
		if (scatter.on) { // offset the strokes a small amount if scatter is enabled
			location.x = origX + rand() % (6 * dist) - 3*dist;
			location.y = origY + rand() % (6 * dist) - 3*dist;
		}
		
		angle = 0;
		
		if (brush == BRUSH_LINE)
			angle = rand() % 100 / 100.0 * 2 * M_PI; // random angle
		else if (brush == BRUSH_LINE_GRADIENT) {
			gradX = *getPixel(location.x, location.y, 1, x_grad, imgWidth, imgHeight) - 127;
			gradY = *getPixel(location.x, location.y, 1, y_grad, imgWidth, imgHeight) - 127;
			angle = atan(1.0*gradY/gradX) + M_PI / 2; // set angle perpendicular to gradient
		} else if (brush == BRUSH_LINE_MOVEMENT) {
			dx = origX - prevLocation.x;
			dy = origY - prevLocation.y;
			angle = atan(1.0*dy/dx) + M_PI / 2; // set angle perpendicular to movement
			prev_angle = angle; // used for smoothing motion-based brush
		} else if (brush == BRUSH_CURVE || brush == BRUSH_CURVE_GRADIENT) {
			// create a curve using 8 values: x and y of starting point, 2 control points, and end point
			points[0] = location.x;
			points[1] = location.y;
			for (int j = 0; j < 6; j+=2) {
				if (brush == BRUSH_CURVE) { // random point
					points[j+2] = points[j] + rand() % (int)size.value - size.value / 2;
					points[j+3] = points[j+1] + rand() % (int)size.value - size.value / 2;
				} else { // follow perpendicular to gradient to get the next point
					gradX = (float) *getPixel(points[j], points[j+1], 1, x_grad, imgWidth, imgHeight) - 127;
					gradY = (float) *getPixel(points[j], points[j+1], 1, y_grad, imgWidth, imgHeight) - 127;
					double hyp = sqrt( gradX * gradX + gradY * gradY );
					if (hyp == 0)
						hyp = 1; // avoid divide by zero
					dx = size.value * -gradY / hyp; // make dx, dy perpendicular to gradient
					dy = size.value * gradX / hyp;
					points[j+2] = points[j] + dx;
					points[j+3] = points[j+1] + dy;
				}
			}
		}
		
		// create a stroke
		Stroke s = createStroke(brush, location, prevLocation, opacity.value, angle, size.value);
		if (brush == BRUSH_CURVE || brush == BRUSH_CURVE_GRADIENT) {
			// store control points and end point in extraVals field of the stroke
			for (int i = 0; i < 6; i++) {
				s.curvePoints[i] = points[i+2];
			}
		}
		strokes.push_back(s); // push the stroke on the strokes stack
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

- (void)clearImage {
	strokes.clear();
	CGImageRelease(cached);
	cached = 0;
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
	
	[[UIScreen mainScreen] bounds];
	UIGraphicsBeginImageContextWithOptions(dims, true, 0.0);
	// First get the image into your data buffer
	CGImageRef image = [paintImage CGImage];
	imgWidth = CGImageGetWidth(image);
	imgHeight = CGImageGetHeight(image);
	bytesPerPixel = 4;
	bytesPerRow = bytesPerPixel * imgWidth;
	rawData = (unsigned char*)malloc(imgHeight * imgWidth * bytesPerPixel);

	NSUInteger bitsPerComponent = 8;
	CGContextRef ctx = CGBitmapContextCreate(rawData, imgWidth, imgHeight, bitsPerComponent, bytesPerRow, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);	
	CGContextDrawImage(ctx, CGRectMake(0, 0, imgWidth, imgHeight), image);
	CGContextRelease(ctx);
	
	[self computeFilters];
	[self computeGradient];
	[self setNeedsDisplay];
}

- (void)setCustomFilter:(double*)kernel divisor:(double)d offset:(double)o {
	if (custom_kernel) free(custom_kernel);
	if (custom) free(custom);
	
	custom = (unsigned char*)malloc(imgHeight * imgWidth * 4);
	custom_kernel = kernel;
	//for (int i = 0; i < 25; i++)
	//	custom_kernel[i] = 0.0;
	//custom_kernel[12] = 1.0;
	
	applyFilter(rawData, imgWidth, imgHeight, 4, custom, custom_kernel, 5, 5, d, o);
}

// computes the sharpened and blurred filters for faster rendering of those brushes
- (void)computeFilters {
	if (sharpened) free(sharpened);
	if (blurred) free(blurred);
	
	sharpened = (unsigned char*)malloc(imgHeight * imgWidth * 4);
	blurred = (unsigned char*)malloc(imgHeight * imgWidth * 4);
	
	double laplacian[] = { 0.0, -1.0, 0.0, -1.0, 5.0, -1.0, 0.0, -1.0, 0.0 };
	double gaussian[] = { 1.0, 2.0, 1.0, 2.0, 4.0, 2.0, 1.0, 2.0, 1.0 };
	
	applyFilter(rawData, imgWidth, imgHeight, 4, sharpened, laplacian, 3, 3, 1.0, 0);	
	applyFilter(rawData, imgWidth, imgHeight, 4, blurred, gaussian, 3, 3, 16, 0);
}

- (void)computeGradient {
	if (x_grad) free(x_grad);
	if (y_grad) free(y_grad);
	
	x_grad = (unsigned char*)malloc(imgHeight * imgWidth);
	y_grad = (unsigned char*)malloc(imgHeight * imgWidth);
	
	unsigned char* bw_img = (unsigned char*)malloc(imgHeight * imgWidth);
	unsigned char* smooth_x = (unsigned char*)malloc(imgHeight * imgWidth);
	unsigned char* smooth_y = (unsigned char*)malloc(imgHeight * imgWidth);
	
	for (unsigned x = 0; x < imgWidth; ++x) {
		for (unsigned y = 0; y < imgHeight; ++y) {
			float val = 0.299 * rawData[(bytesPerRow * y) + x * bytesPerPixel];
			val += 0.587 * rawData[(bytesPerRow * y) + x * bytesPerPixel + 1];
			val += 0.114 * rawData[(bytesPerRow * y) + x * bytesPerPixel + 2];
			
			bw_img[y*imgWidth+x] = (unsigned char)val;
		}
	}
	
	double gauss_filter[5] = { 1.0, 4.0, 7.0, 4.0, 1.0 };
	
	applyFilter(bw_img, imgWidth, imgHeight, 1, smooth_x,
				gauss_filter, 5, 1, 17.0, 0.0);
	applyFilter(bw_img, imgWidth, imgHeight, 1, smooth_y,
				gauss_filter, 1, 5, 17.0, 0.0);
	
	free(bw_img);
	
	double x_filter[9] = { 1.0, 0.0, -1.0, 2.0, 0.0, -2.0, 1.0, 0.0, -1.0};
	double y_filter[9] = { 1.0, 2.0, 1.0, 0.0, 0.0, 0.0, -1.0, -2.0, -1.0};
	
	applyFilter(smooth_x, imgWidth, imgHeight, 1, x_grad,
				x_filter, 3, 3, 1.0, 127.0);
	applyFilter(smooth_y, imgWidth, imgHeight, 1, y_grad,
				y_filter, 3, 3, 1.0, 127.0);
	
	free(smooth_x);
	free(smooth_y);
}

@end