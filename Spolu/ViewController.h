//
//  ViewController.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-20.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIVisualEffectView *beginView;

- (IBAction)beginButton:(id)sender;

@end

