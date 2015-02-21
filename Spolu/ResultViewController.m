//
//  ResultViewController.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-21.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "ResultViewController.h"

@interface ResultViewController ()

@end

@implementation ResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Just for test
    groupImageView.image = _groupImage;
}


- (IBAction)rightSwipe:(id)sender {
    NSLog(@"Right Swipe");
}

- (IBAction)leftSwipe:(id)sender {
    NSLog(@"Left Swipe");
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
