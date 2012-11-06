//
//  MainViewController.h
//  Impressionist
//
//  Created by Stephanie Abascal on 1/24/09.
//  Copyright Stephanie Abascal 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainView.h"

@interface MainViewController : UIViewController {
    IBOutlet MainView* mainView;
}

- (void) setBrush:(unsigned)brush;
- (void) setImage:(UIImage*)image;
- (void) setOpacity:(UISlider*)opacity;
- (void) setSize:(UISlider*)size;

- (void)saveToAlbum;

@end
