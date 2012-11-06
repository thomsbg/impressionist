//
//  MainViewController.m
//  Impressionist
//
//  Created by Stephanie Abascal on 1/24/09.
//  Copyright Stephanie Abascal 2009. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"

@implementation MainViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}

- (void) setBrush:(unsigned)brush {
	mainView.brush = brush;
}

- (void)setImage:(UIImage*) image {
	[mainView setImage:image];
}

- (void) setOpacity:(UISlider*)opacity {
	mainView.opacity = opacity;
}

- (void) setSize:(UISlider*)size {
	mainView.size = size;
}

- (void)saveToAlbum {
	UIGraphicsBeginImageContext(self.view.bounds.size);
	[self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage* viewImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	UIImageWriteToSavedPhotosAlbum(viewImage, self, nil, nil); 
}

@end
