//
//  FlipsideViewController.m
//  Impressionist
//
//  Created by Stephanie Abascal on 1/24/09.
//  Copyright Stephanie Abascal 2009. All rights reserved.
//

#import "FlipsideViewController.h"
#import "MainViewController.h"

@implementation FlipsideViewController

@synthesize mainController;
@synthesize rootViewController;
@synthesize opacity;
@synthesize size;

- (void)viewDidLoad {
    [super viewDidLoad];
	opacity.maximumValue = 255;
	opacity.minimumValue = 0;
	opacity.value = 255;
	
	size.maximumValue = 40;
	size.minimumValue = 1;
	size.value = 10;
	
	[mainController setSize:size];
	[mainController setOpacity:opacity];
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
	return 11;
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
			return @"Scattered Points";
		case 4:
			return @"Scattered Circles";
		case 5:
			return @"Scattered Lines";
		case 6:
			return @"Curves";
        case 7:
            return @"Gradient Scattered Lines";
        case 8:
            return @"Motion-based Scattered Lines";
        case 9:
            return @"Sharpen";
        case 10:
            return @"Blur";
		default:
			return @"Error!";
	}
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
