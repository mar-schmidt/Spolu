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
}
@property (weak, nonatomic) IBOutlet UISlider *distanceSlideControl;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;


@property (weak, nonatomic) IBOutlet UISlider *ageSlideControl;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;

- (IBAction)startCamera:(id)sender;
- (IBAction)dismissViewController:(id)sender;


@end
