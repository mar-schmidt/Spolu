//
//  ResultViewController.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-21.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultViewController : UIViewController <UIGestureRecognizerDelegate>
{
    __weak IBOutlet UIImageView *groupImageView;
    IBOutlet UISwipeGestureRecognizer *rightSwipeGesture;
    IBOutlet UISwipeGestureRecognizer *leftSwipeGesture;
}
@property (weak, nonatomic) UIImage *groupImage;

- (IBAction)rightSwipe:(id)sender;
- (IBAction)leftSwipe:(id)sender;
@end
