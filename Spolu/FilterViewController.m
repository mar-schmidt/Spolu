//
//  FilterViewController.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-20.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "FilterViewController.h"
#import "ResultViewController.h"

@interface FilterViewController ()

@end

@implementation FilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Setup of initial design
    [self designSetup];
    
    // Add targets to distance and age sliders so that we can update corresponding labels when dragging
    [_distanceSlideControl addTarget:self action:@selector(distanceSlideControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_ageSlideControl addTarget:self action:@selector(ageSlideControlValueChanged:) forControlEvents:UIControlEventValueChanged];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

- (void)designSetup
{
    // Slider for distance and age
    [_distanceSlideControl setThumbImage:[UIImage imageNamed:@"knob"] forState:UIControlStateNormal];
    [_distanceSlideControl setMaximumTrackTintColor:[UIColor colorWithRed:220/255.0f green:237/255.0f blue:200/255.0f alpha:1]];
    [_ageSlideControl setThumbImage:[UIImage imageNamed:@"knob"] forState:UIControlStateNormal];
    [_ageSlideControl setMaximumTrackTintColor:[UIColor colorWithRed:220/255.0f green:237/255.0f blue:200/255.0f alpha:1]];
    
    ////////////////
    // Set distanceLabels value to current distanceSlide-value
    //
    // Round float to an integer
    int distanceDiscreteValue = roundl(_distanceSlideControl.value);
    int ageDiscreteValue = roundl(_ageSlideControl.value);
    
    // Update distanceLabel and ageLabel
    _distanceLabel.text = [NSString stringWithFormat:@"%d km", distanceDiscreteValue];
    _ageLabel.text = [NSString stringWithFormat:@"%d isch", ageDiscreteValue];
    
    // Set status bar dark for this viewcontroller
    [self setNeedsStatusBarAppearanceUpdate];
}

- (IBAction)distanceSlideControlValueChanged:(UISlider *)sender
{
    // Rounds float to an integer
    int discreteValue = roundl([sender value]);
    
    // Update distanceLabel
    _distanceLabel.text = [NSString stringWithFormat:@"%d km", discreteValue];
}

- (IBAction)ageSlideControlValueChanged:(UISlider *)sender
{
    // Rounds float to an integer
    int discreteValue = roundl([sender value]);
    
    // Update distanceLabel
    _ageLabel.text = [NSString stringWithFormat:@"%d isch", discreteValue];
}





- (IBAction)startCamera:(id)sender {
    if ([self deviceHasCamera]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        
        [self presentViewController:imagePicker animated:YES completion:^{
            
        }];
    }
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Dismiss camera
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // Grab the image from camera
    UIImage *initialImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // Orient image "up"
    takenGroupImage = [self normalizedImage:initialImage];
    
    // Upload the image and make searchable (active)
    [self uploadImageAndMakeActive:takenGroupImage];
    
    // Go to ResultViewController
    [self performSegueWithIdentifier:@"showResultViewController" sender:self];

}

- (UIImage *)normalizedImage:(UIImage *)image {
    // Make sure image gets correctly oriented
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:(CGRect){0, 0, image.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

- (BOOL)deviceHasCamera
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // Current device has no camera, oops
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No Camera" message:@"This device has no camera" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
        return NO;
    } else return YES;
}

- (void)uploadImageAndMakeActive:(UIImage *)image
{
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ResultViewController *destViewController = [segue destinationViewController];
    destViewController.groupImage = takenGroupImage;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)dismissViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}



@end
