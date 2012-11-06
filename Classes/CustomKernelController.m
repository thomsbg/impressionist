//
//  CustomKernelEntryController.m
//  Impressionist
//
//  Created by Blake Thomson on 4/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CustomKernelController.h"
#import "MainViewController.h"
#import "RootViewController.h"

@implementation CustomKernelController

@synthesize mainController;
@synthesize rootController;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


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
	[mainController release];
	[rootController release];
	
	[divisor release];
	[offset release];
	
	[val0 release];
	[val1 release];
	[val2 release];
	[val3 release];
	[val4 release];
	[val5 release];
	[val6 release];
	[val7 release];
	[val8 release];
	[val9 release];
	[val10 release];
	[val11 release];
	[val12 release];
	[val13 release];
	[val14 release];
	[val15 release];
	[val16 release];
	[val17 release];
	[val18 release];
	[val19 release];
	[val20 release];
	[val21 release];
	[val22 release];
	[val23 release];
	[val24 release];
    [super dealloc];
}

- (IBAction)saveAndReturn {
	double *values = (double*)malloc(sizeof(double) * 25);
	values[0] = val0.text.doubleValue;
	values[1] = val1.text.doubleValue;
	values[2] = val2.text.doubleValue;
	values[3] = val3.text.doubleValue;
	values[4] = val4.text.doubleValue;
	values[5] = val5.text.doubleValue;
	values[6] = val6.text.doubleValue;
	values[7] = val7.text.doubleValue;
	values[8] = val8.text.doubleValue;
	values[9] = val9.text.doubleValue;
	values[10] = val10.text.doubleValue;
	values[11] = val11.text.doubleValue;
	values[12] = val12.text.doubleValue;
	values[13] = val13.text.doubleValue;
	values[14] = val14.text.doubleValue;
	values[15] = val15.text.doubleValue;
	values[16] = val16.text.doubleValue;
	values[17] = val17.text.doubleValue;
	values[18] = val18.text.doubleValue;
	values[19] = val19.text.doubleValue;
	values[20] = val20.text.doubleValue;
	values[21] = val21.text.doubleValue;
	values[22] = val22.text.doubleValue;
	values[23] = val23.text.doubleValue;
	values[24] = val24.text.doubleValue;
	
	for (int i = 0; i < 25; i++) {
		if (values[i] < 0)
			values[i] = 0;
		else if (values[i] > 255)
			values[i] = 255;
	}
	
	double d = divisor.text.doubleValue;
	double o = offset.text.doubleValue;
	[mainController setCustomFilter:values divisor:d offset:o];
	[rootController toggleNavBar];
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancel {
	[rootController toggleNavBar];
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
	[textField resignFirstResponder];
	return YES;
}

@end
