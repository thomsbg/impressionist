//
//  RootViewController.h
//  Impressionist
//
//  Created by Stephanie Abascal on 1/24/09.
//  Copyright Stephanie Abascal 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;
@class FlipsideViewController;

@interface RootViewController : UIViewController {
	MainViewController *mainViewController;
	FlipsideViewController *flipsideViewController;
	UIButton *infoButton;
	UIButton *clearButton;
	UINavigationBar *flipsideNavigationBar;
}

@property (nonatomic, retain) MainViewController *mainViewController;
@property (nonatomic, retain) FlipsideViewController *flipsideViewController;
@property (nonatomic, retain) IBOutlet UIButton *infoButton;
@property (nonatomic, retain) IBOutlet UIButton *clearButton;
@property (nonatomic, retain) UINavigationBar *flipsideNavigationBar;

- (IBAction)toggleView;
- (IBAction)clearImage;
- (void)loadFlipsideViewController;
- (void)toggleNavBar;
- (void)saveToAlbum;

@end
