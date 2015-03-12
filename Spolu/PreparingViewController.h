//
//  PreparingViewController.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-03-10.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRPreparingView.h"
#import "IRMatchServiceHandler.h"

@interface PreparingViewController : UIViewController
{
    IBOutlet UIImageView *groupImageView;
}
@property (nonatomic, strong) UIImage *groupImage;

@end
