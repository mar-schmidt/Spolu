//
//  FilterViewController.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-20.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImage *takenGroupImage;
    
    // Distance elements
    IBOutlet UISlider *distanceSlideControl;
    IBOutlet UILabel *distanceLabel;
    
    // Age elements
    IBOutlet UISlider *ageSlideControl;
    IBOutlet UILabel *ageLabel;
    
    // Segmented control properties
    IBOutlet UISegmentedControl *weAreSegmentedControl;
    IBOutlet UISegmentedControl *lookingForSegmentedControl;
}


// Navbar elements
- (IBAction)startCamera:(id)sender;
- (IBAction)dismissViewController:(id)sender;


@end
