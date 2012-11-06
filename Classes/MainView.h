//
//  MainView.h
//  Impressionist
//
//  Created by Stephanie Abascal on 1/24/09.
//  Copyright Stephanie Abascal 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <vector>

struct Stroke {
	unsigned type;
	CGPoint location;
	CGPoint prevLocation;
	float alpha;
	float angle;
	float size;
	int curvePoints[6];
	
	Stroke() { }
	Stroke(unsigned t, CGPoint l, float alpha_) : type(t), location(l), alpha(alpha_) { }
};

@interface MainView : UIView {
	std::vector<Stroke> strokes;
	
	unsigned char *rawData;
	unsigned char *x_grad, *y_grad, *blurred, *sharpened, *custom;
	unsigned brush;
	
	unsigned imgWidth;
	unsigned imgHeight;
	unsigned bytesPerRow;
	unsigned bytesPerPixel;
	unsigned clearImage;
	
	float prev_angle;
	double* custom_kernel;
	
	UISlider* opacity;
	UISlider* size;
	UISwitch* scatter;

	CGImageRef cached;
	UIImageView image;
}

//- (void)setCustomKernel:(double*)values;
- (void)setImage:(UIImage*)paintImage;
- (void)clearImage;
- (void)setCustomFilter:(double*)kernel divisor:(double)d offset:(double)o;
- (void)computeGradient;
- (void)computeFilters;

@property unsigned brush;
@property (retain, nonatomic) UISlider* opacity;
@property (retain, nonatomic) UISlider* size;
@property (retain, nonatomic) UISwitch* scatter;

@end
