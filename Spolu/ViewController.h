//
//  ViewController.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-20.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MZFayeClient.h>
#import "IRWebSocketServiceHandler.h"

@interface ViewController : UIViewController
{
    IRWebSocketServiceHandler *webSocketHandler;
}

@property (weak, nonatomic) IBOutlet UIVisualEffectView *beginView;

- (IBAction)beginButton:(id)sender;

- (IBAction)test:(id)sender;
- (IBAction)connect:(id)sender;
- (IBAction)channel1:(id)sender;

@end

