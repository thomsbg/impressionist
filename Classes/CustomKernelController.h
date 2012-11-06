//
//  CustomKernelEntryController.h
//  Impressionist
//
//  Created by Blake Thomson on 4/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;
@class RootViewController;

@interface CustomKernelController : UIViewController <UITextFieldDelegate> {
	MainViewController* mainController;
	RootViewController* rootController;
	
	IBOutlet UITextField* divisor;
	IBOutlet UITextField* offset;
	
	IBOutlet UITextField* val0;
	IBOutlet UITextField* val1;
	IBOutlet UITextField* val2;
	IBOutlet UITextField* val3;
	IBOutlet UITextField* val4;
	IBOutlet UITextField* val5;
	IBOutlet UITextField* val6;
	IBOutlet UITextField* val7;
	IBOutlet UITextField* val8;
	IBOutlet UITextField* val9;
	IBOutlet UITextField* val10;
	IBOutlet UITextField* val11;
	IBOutlet UITextField* val12;
	IBOutlet UITextField* val13;
	IBOutlet UITextField* val14;
	IBOutlet UITextField* val15;
	IBOutlet UITextField* val16;
	IBOutlet UITextField* val17;
	IBOutlet UITextField* val18;
	IBOutlet UITextField* val19;
	IBOutlet UITextField* val20;
	IBOutlet UITextField* val21;
	IBOutlet UITextField* val22;
	IBOutlet UITextField* val23;
	IBOutlet UITextField* val24;
}

@property(retain, nonatomic) MainViewController *mainController;
@property(retain, nonatomic) RootViewController *rootController;

- (IBAction)saveAndReturn;
- (IBAction)cancel;

@end
