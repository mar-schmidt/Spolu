//
//  PreparingViewController.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-03-10.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "PreparingViewController.h"

@implementation PreparingViewController

- (void)viewDidLoad
{
    // Nav bar more blur
    UIColor *barColour = self.navigationController.navigationBar.backgroundColor;
    UIView *colourView = [[UIView alloc] initWithFrame:CGRectMake(0.f, -20.f, 320.f, 64.f)];
    colourView.opaque = NO;
    colourView.alpha = .4f;
    colourView.backgroundColor = barColour;
    self.navigationController.navigationBar.barTintColor = barColour;
    [self.navigationController.navigationBar.layer insertSublayer:colourView.layer atIndex:1];

    // Set groupImageViews image
    groupImageView.image = _groupImage;
    
    // Fetch the nearby groups
    IRMatchServiceHandler *matchService = [IRMatchServiceHandler sharedMatchServiceHandler];
    [matchService getEligibleGroupsResultForGroup:nil];
    
    
    MRPreparingView *preparingView = [[MRPreparingView alloc] initWithFrame:self.view.frame];
    
    [[preparingView letsGoButton] addTarget:self action:@selector(letsGo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:preparingView];
    [preparingView startAnimationsForProgressType:ProfileProgress];
}

- (void)letsGo
{
    [self performSegueWithIdentifier:@"showResultViewController" sender:self];
}

@end
