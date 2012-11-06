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
	CGPoint location2;
	CGPoint location3;
	float alpha;
	float strokeWidth;
	float eltWidth;
	unsigned density;
	
	std::vector<CGPoint> curvePoints;
	
	Stroke() { }
	Stroke(unsigned t, CGPoint l, float alpha_) : type(t), location(l), alpha(alpha_) { }
};

@interface MainView : UIView {
	std::vector<Stroke> strokes;
	
	unsigned char *rawData;
	unsigned char *x_grad, *y_grad;
	unsigned brush;
	
	unsigned imgWidth;
	unsigned imgHeight;
	unsigned bytesPerRow;
	unsigned bytesPerPixel;
	
	UISlider* opacity;
	UISlider* size;
	
	CGImageRef cached;
}


- (void)setImage:(UIImage*)paintImage;
- (void)computeGradient;

@property unsigned brush;
@property (retain, nonatomic) UISlider* opacity;
@property (retain, nonatomic) UISlider* size;

@end
