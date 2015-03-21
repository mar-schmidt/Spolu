//
//  ViewController.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-20.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "ViewController.h"


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
    
    webSocketHandler = [IRWebSocketServiceHandler sharedWebSocketHandler];
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
- (IBAction)test:(id)sender {

    [webSocketHandler sendMessage:@{@"message": @"KNUUULLA till kanal chat2",
                                    @"user_id": @"2",
                                    @"other_user_id": @"9",
                                    @"text": @"carlos"} toGroup:nil toChannel:@"/chat2"];
}

- (IBAction)connect:(id)sender {
    [webSocketHandler connect];
}

- (IBAction)channel1:(id)sender {
    [webSocketHandler subscribeToChannel:@"/chat2"];
}

@end
