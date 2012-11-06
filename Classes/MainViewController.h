//
//  MainViewController.h
//  Impressionist
//
//  Created by Stephanie Abascal on 1/24/09.
//  Copyright Stephanie Abascal 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainView;

@interface MainViewController : UIViewController {
    IBOutlet MainView* mainView;
}

- (void) setBrush:(unsigned)brush;
- (void) setImage:(UIImage*)image;
- (void) setOpacity:(UISlider*)opacity;
- (void) setSize:(UISlider*)size;
- (void) setScatter:(UISwitch*)scatter;
- (void) setCustomFilter:(double*)values divisor:(double)d offset:(double)o;
- (void) clearImage;
- (void) saveToAlbum;

@end
