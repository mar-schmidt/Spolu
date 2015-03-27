//
//  ViewController.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-20.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "ViewController.h"
#import "IROwnGroup.h"
#import "ResultViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Set border radius on begin button
    _beginView.layer.cornerRadius = 7;
    _beginView.layer.masksToBounds = YES;
    
    // Set status bar to light for this viewcontroller
    [self setNeedsStatusBarAppearanceUpdate];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)beginButton:(id)sender {

}

@end
