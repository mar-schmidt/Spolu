//
//  FilterViewController.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-20.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "JFADoubleSlider.h"
#import "IRLocationServiceHandler.h"
#import "IRMatchServiceHandler.h"
#import "IROwnGroup.h"

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
    
    __weak IBOutlet JFADoubleSlider *lookingForAgeSlider;
    
    IROwnGroup *ownGroup;
}

@property (nonatomic, strong) IRLocationServiceHandler *locationServiceHandler;

// Navbar elements
- (IBAction)startCamera:(id)sender;
- (IBAction)dismissViewController:(id)sender;


@end
