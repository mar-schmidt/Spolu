//
//  FilterViewController.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-20.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "locationServiceHandler.h"
#import "DZImageEditingController.h"

@interface FilterViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, LocationServiceHandlerDelegate>
{
    __weak IBOutlet UIBarButtonItem *startCameraButton;
    UIImage *takenGroupImage;
    
    // Distance elements
    __weak IBOutlet UISlider *distanceSlideControl;
    __weak IBOutlet UILabel *distanceLabel;
    __weak IBOutlet UILabel *areaLabel;
    
    // Age elements
    __weak IBOutlet UISlider *ageSlideControl;
    __weak IBOutlet UILabel *ageLabel;
    
    // Segmented control properties
    __weak IBOutlet UISegmentedControl *weAreSegmentedControl;
    __weak IBOutlet UISegmentedControl *lookingForSegmentedControl;
}

@property (nonatomic, strong) LocationServiceHandler *locationServiceHandler;

// Navbar elements
- (IBAction)startCamera:(id)sender;
- (IBAction)dismissViewController:(id)sender;


@end
