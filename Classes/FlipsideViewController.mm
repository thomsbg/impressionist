//
//  FlipsideViewController.m
//  Impressionist
//
//  Created by Stephanie Abascal on 1/24/09.
//  Copyright Stephanie Abascal 2009. All rights reserved.
//

#import "FlipsideViewController.h"
#import "RootViewController.h"
#import "MainViewController.h"
#import "CustomKernelController.h"

@implementation FlipsideViewController

@synthesize rootViewController;
@synthesize mainController;
//@synthesize customKernelController;
@synthesize opacity;
@synthesize size;
@synthesize scatter;

- (void)viewDidLoad {
    [super viewDidLoad];
	opacity.maximumValue = 255;
	opacity.minimumValue = 0;
	opacity.value = 255;
	
	size.maximumValue = 40;
	size.minimumValue = 1;
	size.value = 10;
	
	scatter.on = NO;
	
	[mainController setSize:size];
	[mainController setOpacity:opacity];
	[mainController setScatter:scatter];
}


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
	[rootViewController release];
	[MainViewController release];
	[opacity release];
	[size release];
	[scatter release];
    [super dealloc];
}

// returns the number of columns to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

// returns the number of rows
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return 10;
}

// returns the title of each row
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	switch (row) {
		case 0:
			return @"Points";
		case 1:
			return @"Circles";
		case 2:
			return @"Lines";
		case 3:
			return @"Curves";
        case 4:
            return @"Gradient Lines";
		case 5:
            return @"Gradient Curves";
        case 6:
            return @"Motion-Based Lines";
        case 7:
            return @"Sharpen";
        case 8:
            return @"Blur";
		case 9:
			return @"Custom Filter";
		default:
			return @"Error!";
	}
}


- (IBAction)createFilter {
	[rootViewController toggleNavBar];
	CustomKernelController *kernelController = [[CustomKernelController alloc] initWithNibName:@"CustomKernelView" bundle:nil];
    //self.customKernelController = kernelController;
	//[kernelController release];
	kernelController.mainController = self.mainController;
	kernelController.rootController = self.rootViewController;
	
	[self presentModalViewController:kernelController animated:YES];
}

// gets called when the user settles on a row
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	[mainController setBrush:row];
}

- (IBAction)selectPicture {
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
	
    // Picker is displayed asynchronously.
	[rootViewController toggleNavBar];
    [self presentModalViewController:picker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
	[mainController setImage:image];
	
	// Remove the picker interface and release the picker object.
    [[picker parentViewController] dismissModalViewControllerAnimated:YES];
	[rootViewController toggleNavBar];
    [picker release];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[picker parentViewController] dismissModalViewControllerAnimated:YES];
	[rootViewController toggleNavBar];
    [picker release];
}

- (IBAction)saveToAlbum {
	[rootViewController saveToAlbum];
}

@end
