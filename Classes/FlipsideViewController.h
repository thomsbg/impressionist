//
//  FlipsideViewController.h
//  Impressionist
//
//  Created by Stephanie Abascal on 1/24/09.
//  Copyright Stephanie Abascal 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;
@class MainViewController;

@interface FlipsideViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	RootViewController* rootViewController;
	MainViewController* mainController;
	
	IBOutlet UIPickerView* brushPicker;
	IBOutlet UISlider* size;
	IBOutlet UISlider* opacity;
	IBOutlet UISwitch* scatter;
}

@property (retain, nonatomic) RootViewController *rootViewController;
@property (retain, nonatomic) MainViewController *mainController;

@property (retain, nonatomic) UISlider* size;
@property (retain, nonatomic) UISlider* opacity;
@property (retain, nonatomic) UISwitch* scatter;

- (IBAction)createFilter;
- (IBAction)selectPicture;
- (IBAction)saveToAlbum;

@end
