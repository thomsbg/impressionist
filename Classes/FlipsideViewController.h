//
//  FlipsideViewController.h
//  Impressionist
//
//  Created by Stephanie Abascal on 1/24/09.
//  Copyright Stephanie Abascal 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@class MainViewController;

@interface FlipsideViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	MainViewController* mainController;	
	
	IBOutlet UIPickerView* brushPicker;
	IBOutlet UISlider* size;
	IBOutlet UISlider* opacity;
	
	RootViewController* rootViewController;
}

@property (retain, nonatomic) MainViewController *mainController;
@property (retain, nonatomic) RootViewController *rootViewController;

@property (retain, nonatomic) UISlider* size;
@property (retain, nonatomic) UISlider* opacity;

- (IBAction)selectPicture;
- (IBAction)saveToAlbum;

@end
