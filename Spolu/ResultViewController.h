//
//  ResultViewController.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-21.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>

@interface ResultViewController : UIViewController <MDCSwipeToChooseDelegate>
{
    __weak IBOutlet UIImageView *groupImageView;
}
@property (weak, nonatomic) UIImage *groupImage;

@end
