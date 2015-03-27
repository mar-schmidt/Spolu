//
//  FilterViewController.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-20.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "FilterViewController.h"
#import "PreparingViewController.h"
#import "IRLocationServiceHandler.h"
#import "NSData+Base64.h"
#import "MRInstallation.h"
#import "ResultViewController.h"

@interface FilterViewController ()

@end

@implementation FilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _ownGroup = [IROwnGroup sharedGroup];
    if (!_ownGroup.group) {
        _ownGroup.group = [[IRGroup alloc] init];
    }
    /*
    if (_ownGroup.group) {
        ResultViewController *resultViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ResultViewController"];
        [self.navigationController pushViewController:resultViewController animated:YES];
    }
    */
    
    // PickerView
    pickerView.delegate = self;
    [pickerView selectRow:2 inComponent:0 animated:YES];
    
    // Nav bar more blur
    UIColor *barColour = self.navigationController.navigationBar.backgroundColor;
    UIView *colourView = [[UIView alloc] initWithFrame:CGRectMake(0.f, -20.f, 320.f, 64.f)];
    colourView.opaque = NO;
    colourView.alpha = .4f;
    colourView.backgroundColor = barColour;
    self.navigationController.navigationBar.barTintColor = barColour;
    [self.navigationController.navigationBar.layer insertSublayer:colourView.layer atIndex:1];
    
    // Setup of initial design
    [self designSetup];
    
    // Add targets to distance and age sliders so that we can update corresponding labels when dragging
    [distanceSlideControl addTarget:self action:@selector(distanceSlideControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [ageSlideControl addTarget:self action:@selector(ageSlideControlValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Start fetching location
    _locationServiceHandler = [IRLocationServiceHandler sharedLocationServiceHandler];
    _locationServiceHandler.delegate = self;
    
    [_locationServiceHandler startUpdatingLocation];
    
    
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

- (void)designSetup
{
    // Slider for distance and age
    [distanceSlideControl setThumbImage:[UIImage imageNamed:@"knob_trans"] forState:UIControlStateNormal];
    [distanceSlideControl setMaximumTrackTintColor:[UIColor colorWithRed:220/255.0f green:237/255.0f blue:200/255.0f alpha:1]];
    [ageSlideControl setThumbImage:[UIImage imageNamed:@"knob_trans"] forState:UIControlStateNormal];
    [ageSlideControl setMaximumTrackTintColor:[UIColor colorWithRed:220/255.0f green:237/255.0f blue:200/255.0f alpha:1]];
    
    ////////////////
    // Set distanceLabels value to current distanceSlide-value
    //
    // Round float to an integer
    int distanceDiscreteValue = roundl(distanceSlideControl.value);
    int ageDiscreteValue = roundl(ageSlideControl.value);
    
    // Update distanceLabel and ageLabel
    distanceLabel.text = [NSString stringWithFormat:@"%d km", distanceDiscreteValue];
    ageLabel.text = [NSString stringWithFormat:@"%d ish", ageDiscreteValue];
    
    // Set status bar dark for this viewcontroller
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark LocationServiceHandler Delegates
- (void)locationServiceHandler:(IRLocationServiceHandler *)service didUpdateCurrentLocation:(NSString *)city latitude:(float)latitude longitude:(float)longitude
{
    areaLabel.text = [NSString stringWithFormat:@"Area (around %@)", city];
}

- (void)locationServiceHandler:(IRLocationServiceHandler *)service didFailGettingLocation:(NSError *)error
{
////////////////////////////
// Error codes:
// -1 = Not allowed to use location
//
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:error.localizedDescription
                                                                             message:[NSString stringWithFormat:@"%@ %@", error.localizedFailureReason, error.localizedRecoverySuggestion]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    // If error.code is -1 or 0 it means that the user has dissallowed using location service for this app. Then power up a new action helping them going to settings
    if (error.code == -1 || error.code == 0) {
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                        UIApplicationOpenSettingsURLString]];
        }];
        [alertController addAction:settingsAction];
    }
    
    // Present the alert
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark Sliders values changing methods
- (IBAction)distanceSlideControlValueChanged:(UISlider *)sender
{
    // Rounds float to an integer
    int discreteValue = roundl([sender value]);
    
    // Update distanceLabel
    distanceLabel.text = [NSString stringWithFormat:@"%d km", discreteValue];
}

- (IBAction)ageSlideControlValueChanged:(UISlider *)sender
{
    // Rounds float to an integer
    int discreteValue = roundl([sender value]);
    
    // Update distanceLabel
    ageLabel.text = [NSString stringWithFormat:@"%d ish", discreteValue];
}


#pragma mark Segmented Controllers values changing methods
- (IBAction)weAreSegmentedControl:(UISegmentedControl *)sender {
    UIColor *blueColor = [UIColor colorWithRed:41/255.0f green:182/255.0f blue:246/255.0f alpha:1];
    UIColor *greenColor = [UIColor colorWithRed:124/255.0f green:179/255.0f blue:66/255.0f alpha:1];
    UIColor *pinkColor = [UIColor colorWithRed:236/255.0f green:64/255.0f blue:122/255.0f alpha:1];
    
    switch ([sender selectedSegmentIndex]) {
        case 0:
            [self transitionColorOnSegmentedControl:sender toColor:blueColor duration:0.3];
            break;
        case 1:
            [self transitionColorOnSegmentedControl:sender toColor:greenColor duration:0.3];
            break;
        case 2:
            [self transitionColorOnSegmentedControl:sender toColor:pinkColor duration:0.3];
            break;
    }
}

- (IBAction)lookingForSegmentedControl:(UISegmentedControl *)sender {
    UIColor *blueColor = [UIColor colorWithRed:41/255.0f green:182/255.0f blue:246/255.0f alpha:1];
    UIColor *greenColor = [UIColor colorWithRed:124/255.0f green:179/255.0f blue:66/255.0f alpha:1];
    UIColor *pinkColor = [UIColor colorWithRed:236/255.0f green:64/255.0f blue:122/255.0f alpha:1];
    
    switch ([sender selectedSegmentIndex]) {
        case 0:
            [self transitionColorOnSegmentedControl:sender toColor:blueColor duration:0.3];
            break;
        case 1:
            [self transitionColorOnSegmentedControl:sender toColor:greenColor duration:0.3];
            break;
        case 2:
            [self transitionColorOnSegmentedControl:sender toColor:pinkColor duration:0.3];
            break;
    }
}

- (void)transitionColorOnSegmentedControl:(UISegmentedControl *)segmentedControl toColor:(UIColor *)color duration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration
                     animations:^{
                         segmentedControl.tintColor = color;
                     } completion:^(BOOL finished) {
                        
                     }];
}


- (IBAction)startCamera:(id)sender {
    
    if (!_ownGroup.group.name) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Enter group name"
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"The Jambalayas...";
        }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            UITextField *nameField = alertController.textFields.firstObject;
            _ownGroup.group.name = nameField.text;
            
            [self presentImagePickerView];
        }];
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [self presentImagePickerView];
    }
}

- (void)presentImagePickerView
{
    NSError *error = nil;
    
    error = [self deviceHasCamera];
    
    if (!error && !_locationServiceHandler.locationError) {
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    }
    else if (error) {
        //[self showAlertForCameraError:error]; THIS SHOULD BE UNCOMMENTED BEFORE GOING LIVE: ONLY USING TO ENABLE SIMULATOR
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else if (_locationServiceHandler.locationError) {
        [_locationServiceHandler sendCurrentErrorToDelegate];
    }
}

- (NSError *)deviceHasCamera
{
    NSError *error = nil;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    return error;
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
    [self uploadImageAndCreateGroup:takenGroupImage];
    
    // Go to ResultViewController
    [self performSegueWithIdentifier:@"showPreparingViewController" sender:self];
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

- (void)showAlertForCameraError:(NSError *)error
{
    // If user has denied access to camera. Prompt user to open settings app and approve it
    if ((error.code == AVErrorApplicationIsNotAuthorizedToUseDevice) &&
        UIApplicationOpenSettingsURLString)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Using Camera failed",
                                                                                                           @"Alert Title: Using camera failed")
                                              
                                                                                 message:NSLocalizedString(@"Access to Camera is denied by you. Open settings and allow it",
                                                                                                           @"Alert Message: Access to Camera is denied by you. Open settings and allow it")
                                              
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        // Cancel action
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];

        // Open settings action
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", @"Alert Button: Settings")
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [alertController addAction:settingsAction];
        
        // Present the alert
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"No Camera found",
                                                                                                           @"Alert Title: No camera found")
                                              
                                                                                 message:NSLocalizedString(@"Your device does not have a camera.",
                                                                                                           @"Alert Message: Your device does not have a camera")
                                              
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];

        // Present the alert
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithSeparateLines:YES];
}

- (void)uploadImageAndCreateGroup:(UIImage *)image
{
    IRMatchServiceHandler *matchServiceHandler = [IRMatchServiceHandler sharedMatchServiceHandler];
    
    _ownGroup.group.genderInt            = weAreSegmentedControl.selectedSegmentIndex;
    _ownGroup.group.lookingForGenderInt  = lookingForSegmentedControl.selectedSegmentIndex;
    _ownGroup.group.age                  = roundl(ageSlideControl.value);
    _ownGroup.group.lookingForAgeLower   = lookingForAgeSlider.curMinVal;
    _ownGroup.group.lookingForAgeUpper   = lookingForAgeSlider.curMaxVal;
    _ownGroup.group.locationLat          = _locationServiceHandler.currentLocationCoordinateX;
    _ownGroup.group.locationLong         = _locationServiceHandler.currentLocationCoordinateY;
    _ownGroup.group.lookingForInAreaWithDistanceInKm = roundl(distanceSlideControl.value);
    
    NSString *base64Image = [self encodeToBase64String:image];
    
    MRInstallation *installation = [MRInstallation currentInstallation];
    
    [matchServiceHandler postMyGroup:_ownGroup.group withBase64Image:base64Image withDeviceToken:installation.deviceToken andCompletionBlockSuccess:^(BOOL succeeded, NSInteger groupId) {
        if (succeeded) {
            // Successfully posted group to backend. Now its ok to assign ownGroup this new group. And then returning
            _ownGroup.group.groupId = groupId;
            return;
        }
    } failure:^(NSError *error) {
        NSLog(@"Issues posting group. BAD");
    }];
    
    /*
    // If our own group object doesnt exist, it means that we do not exist on backend since we checked that when loading this viewcontroller. We should then create a new group and send it to backend
    if (!ownGroup.group) {
        IRGroup *groupWithCurrentFilter = [[IRGroup alloc] initWithOwnGroupOfGender:weAreSegmentedControl.selectedSegmentIndex //0 = Males, 1 = Both, 2 = Females
                                                                   lookingForGender:lookingForSegmentedControl.selectedSegmentIndex //0 = Males, 1 = Both, 2 = Females
                                                                                age:roundl(ageSlideControl.value)
                                                                 lookingForAgeLower:lookingForAgeSlider.curMinVal
                                                                 lookingForAgeUpper:lookingForAgeSlider.curMaxVal
                                                                   locationLatitude:_locationServiceHandler.currentLocationCoordinateX
                                                                  locationLongitude:_locationServiceHandler.currentLocationCoordinateY
                                                   lookingForInAreaWithDistanceInKm:roundl(distanceSlideControl.value)];
    }
    
    else {

        // This means that we have a present group. But are about to update its filters (or cridentials if you will).
        IRGroup *groupWithCurrentFilter = [[IRGroup alloc] initWithOwnGroupOfGender:weAreSegmentedControl.selectedSegmentIndex //0 = Males, 1 = Both, 2 = Females
                                                                   lookingForGender:lookingForSegmentedControl.selectedSegmentIndex //0 = Males, 1 = Both, 2 = Females
                                                                                age:roundl(ageSlideControl.value)
                                                                 lookingForAgeLower:lookingForAgeSlider.curMinVal
                                                                 lookingForAgeUpper:lookingForAgeSlider.curMaxVal
                                                                   locationLatitude:_locationServiceHandler.currentLocationCoordinateX
                                                                  locationLongitude:_locationServiceHandler.currentLocationCoordinateY
                                                   lookingForInAreaWithDistanceInKm:roundl(distanceSlideControl.value)];

        [matchServiceHandler postUpdateForMyGroup:groupWithCurrentFilter withCompletionBlockSuccess:^(BOOL succeeded) {
            if (succeeded) {
                // Successfully posted group to backend. Now its ok to assign ownGroup this new group. And then returning
                ownGroup.group = groupWithCurrentFilter;
                return;
            }
        } failure:^(NSError *error) {
            NSLog(@"Issues posting group. BAD");
        }];
     
    }
     */
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PreparingViewController *destViewController = [segue destinationViewController];
    destViewController.groupImage = takenGroupImage;
}

#pragma mark UIPickerView Delegates and Datasource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 5;
}
/*
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *activity;
    switch (row) {
        case 0:
            activity = @"Partying";
            break;
        case 1:
            activity = @"Sports activities";
            break;
        case 2:
            activity = @"Exploring";
            break;
        case 3:
            activity = @"Relaxing";
            break;
        case 4:
            activity = @"Other";
            break;
    }
    return activity;
}
*/
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *activity = [[NSString alloc] init];
    
    switch (row) {
        case 0:
            activity = @"Partying";
            break;
        case 1:
            activity = @"Sports activities";
            break;
        case 2:
            activity = @"Exploring";
            break;
        case 3:
            activity = @"Relaxing";
            break;
        case 4:
            activity = @"Other";
            break;
    }
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:activity attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:85/255.0f green:139/255.0f blue:47/255.0f alpha:1]}];
    return attString;
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
