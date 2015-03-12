//
//  MRPreparingView.h
//  test
//
//  Created by Marcus Ronélius on 2015-03-09.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CERoundProgressView.h"

typedef enum {
    ProfileProgress    = 0,
    MatchesProgress    = 1,
} ProgressType;

@interface MRPreparingView : UIView <CAAction>
{
    double percent;
    CERoundProgressView *roundProgressViewProfile;
    UIView *circleViewProfile;
    CERoundProgressView *roundProgressViewMatches;
    UIView *circleViewMatches;
    
    CAShapeLayer *pathLayer;
    
    NSTimer *t;
}

@property (nonatomic, strong) UIButton *letsGoButton;

typedef void (^animationCompletionBlock)(void);

- (void)startAnimationsForProgressType:(ProgressType)progressType;

@end
