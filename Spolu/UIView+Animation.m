//
//  UIView+Animation.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-03-03.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "UIView+Animation.h"

@implementation UIView (Animation)

-(void)addSubviewWithBounce:(UIView *)theView
{
    theView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    
    [self addSubview:theView];
    
    [UIView animateWithDuration:0.3/2 animations:^{
        theView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2.5 animations:^{
            theView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2.5 animations:^{
                theView.transform = CGAffineTransformIdentity;
            }];
        }];
    }];
}

@end