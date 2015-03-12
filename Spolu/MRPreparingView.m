//
//  MRPreparingView.m
//  test
//
//  Created by Marcus Ronélius on 2015-03-09.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "MRPreparingView.h"

#define kAnimationCompletionBlock @"animationProfileCompletionBlock"

@implementation MRPreparingView
{
    CGFloat p;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupRoundProgressViews];
        [self setupLetsGoButton];
        [self setupCircleViewsInsideRoundProgressViews];
        [self setupPreparingTextsInsideCircleViews];
    }
    return self;
}

- (void)setupRoundProgressViews
{
    // roundProgressView is a pie-progress chart for displaying the loading of the profileimage
    roundProgressViewProfile = [[CERoundProgressView alloc] initWithFrame:CGRectMake(self.center.x - 40,
                                                                                     100,
                                                                                     80,
                                                                                     80)];
    roundProgressViewProfile.tintColor = [UIColor colorWithRed:124/255.0f green:179/255.0f blue:66/255.0f alpha:1];
    roundProgressViewProfile.trackColor = [UIColor whiteColor];
    roundProgressViewProfile.startAngle = M_PI/2;
    roundProgressViewProfile.layer.masksToBounds = YES;
    roundProgressViewProfile.layer.cornerRadius = roundProgressViewProfile.bounds.size.height/2;
    [self addSubview:roundProgressViewProfile];
    
    roundProgressViewMatches = [[CERoundProgressView alloc] initWithFrame:CGRectMake(self.center.x - 40,
                                                                                     roundProgressViewProfile.frame.origin.y + 120,
                                                                                     80,
                                                                                     80)];
    roundProgressViewMatches.tintColor = [UIColor colorWithRed:124/255.0f green:179/255.0f blue:66/255.0f alpha:1];
    roundProgressViewMatches.trackColor = [UIColor whiteColor];
    roundProgressViewMatches.startAngle = M_PI/2;
    roundProgressViewMatches.layer.masksToBounds = YES;
    roundProgressViewMatches.layer.cornerRadius = roundProgressViewMatches.bounds.size.height/2;
    [self addSubview:roundProgressViewMatches];
}

- (void)setupLetsGoButton
{
    _letsGoButton = [[UIButton alloc] initWithFrame:CGRectMake(self.center.x - 40,
                                                              roundProgressViewMatches.frame.origin.y + 120,
                                                              80,
                                                              20)];
    _letsGoButton.backgroundColor = [UIColor colorWithRed:124/255.0f green:179/255.0f blue:66/255.0f alpha:1];
    _letsGoButton.titleLabel.textColor = [UIColor whiteColor];
    [_letsGoButton setTitle:@"Lets go" forState:UIControlStateNormal];
    _letsGoButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _letsGoButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:12.f];
    [self addSubview:_letsGoButton];
}

- (void)setupCircleViewsInsideRoundProgressViews
{
    
    circleViewProfile = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    circleViewProfile.backgroundColor = [UIColor clearColor];
    circleViewProfile.layer.borderWidth = 1;
    circleViewProfile.layer.borderColor = [UIColor whiteColor].CGColor;
    //circleViewProfile.layer.borderColor = [UIColor colorWithRed:124/255.0f green:179/255.0f blue:66/255.0f alpha:1].CGColor;
    circleViewProfile.layer.cornerRadius = circleViewProfile.bounds.size.height/2;
    circleViewProfile.clipsToBounds = YES;
    [roundProgressViewProfile addSubview:circleViewProfile];
    
    circleViewMatches = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    circleViewMatches.backgroundColor = [UIColor clearColor];
    circleViewMatches.layer.borderWidth = 1;
    circleViewMatches.layer.borderColor = [UIColor whiteColor].CGColor;
    //circleViewMatches.layer.borderColor = [UIColor colorWithRed:124/255.0f green:179/255.0f blue:66/255.0f alpha:1].CGColor;
    circleViewMatches.layer.cornerRadius = circleViewMatches.bounds.size.height/2;
    circleViewMatches.clipsToBounds = YES;
    [roundProgressViewMatches addSubview:circleViewMatches];
    
}

- (void)setupPreparingTextsInsideCircleViews
{
    UILabel *profileLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    profileLabel.adjustsFontSizeToFitWidth = YES;
    profileLabel.textColor = [UIColor whiteColor];
    profileLabel.text = @"Broadcasting your group";
    profileLabel.numberOfLines = 3;
    profileLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:12.f];
    profileLabel.textAlignment = NSTextAlignmentCenter;
    [circleViewProfile addSubview:profileLabel];
    
    UILabel *matchesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    matchesLabel.adjustsFontSizeToFitWidth = YES;
    matchesLabel.textColor = [UIColor whiteColor];
    matchesLabel.text = @"Finding matches";
    matchesLabel.numberOfLines = 3;
    matchesLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:12.f];
    matchesLabel.textAlignment = NSTextAlignmentCenter;
    [circleViewMatches addSubview:matchesLabel];
}


- (void)startAnimationsForProgressType:(ProgressType)progressType
{
    percent = 0;
    
    // Invalidate runner and nil it. Preventing it from running crazy
    [t invalidate];
    t = nil;
    
    NSDate *d = [NSDate dateWithTimeIntervalSinceNow:0];
    t = [[NSTimer alloc] initWithFireDate:d
                                 interval:0.2
                                   target:self
                                 selector:@selector(updateProgressForTimer:)
                                 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:progressType], @"progressType", nil]
                                  repeats:YES];
    
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer:t forMode:NSDefaultRunLoopMode];
}

- (void)updateProgressForTimer:(NSTimer *)timer
{
    percent = percent+0.09;
    ProgressType progressType = [[[timer userInfo] objectForKey:@"progressType"] intValue];
    
    [self progressForType:progressType progress:percent];
}

- (void)progressForType:(ProgressType)progressType progress:(double)percentDone
{
    if (progressType == ProfileProgress) {
        [roundProgressViewProfile setProgress:percentDone animated:YES];
        
        if (percentDone > 1) {
            
            // Invalidate runner
            [t invalidate];
            
            CGFloat roundProgressViewProfileX = roundProgressViewProfile.frame.origin.x + (roundProgressViewProfile.frame.size.width/2);
            CGFloat roundProgressViewProfileY = roundProgressViewProfile.frame.origin.y + roundProgressViewProfile.frame.size.height;
            
            CGFloat roundProgressViewMatchesX = roundProgressViewMatches.frame.origin.x + (roundProgressViewMatches.frame.size.width/2);
            CGFloat roundProgressViewMatchesY = roundProgressViewMatches.frame.origin.y;
            
            [self drawLineAfterProgressType:progressType
                                  fromPoint:CGPointMake(roundProgressViewProfileX, roundProgressViewProfileY)
                                    toPoint:CGPointMake(roundProgressViewMatchesX, roundProgressViewMatchesY)];
        }
        
    }
    else if (progressType == MatchesProgress) {
        [roundProgressViewMatches setProgress:percentDone animated:YES];
        
        if (percentDone > 1) {
            
            // Invalidate runner
            [t invalidate];
            
            CGFloat roundProgressViewMatchesX = roundProgressViewMatches.frame.origin.x + (roundProgressViewMatches.frame.size.width/2);
            CGFloat roundProgressViewMatchesY = roundProgressViewMatches.frame.origin.y + roundProgressViewMatches.frame.size.height;
            
            CGFloat letsGoButtonX = _letsGoButton.frame.origin.x + (_letsGoButton.frame.size.width/2);
            CGFloat letsGoButtonY = _letsGoButton.frame.origin.y;
            
            [self drawLineAfterProgressType:progressType
                                  fromPoint:CGPointMake(roundProgressViewMatchesX, roundProgressViewMatchesY)
                                    toPoint:CGPointMake(letsGoButtonX, letsGoButtonY)];
        }
    }
}

- (void)drawLineAfterProgressType:(ProgressType)progressType fromPoint:(CGPoint)from toPoint:(CGPoint)to
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:from];
    [path addLineToPoint:to];
    
    pathLayer = [CAShapeLayer layer];
    pathLayer.frame = self.bounds;
    pathLayer.path = path.CGPath;
    pathLayer.strokeColor = [[UIColor whiteColor] CGColor];
    //pathLayer.strokeColor = [[UIColor colorWithRed:124/255.0f green:179/255.0f blue:66/255.0f alpha:1] CGColor];
    pathLayer.fillColor = nil;
    pathLayer.lineWidth = 1.3f;
    pathLayer.lineJoin = kCALineJoinBevel;
    
    [self.layer addSublayer:pathLayer];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.delegate = self;
    pathAnimation.duration = 0.5;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    
    animationCompletionBlock profileCompletionBlock = ^void(void)
    {
        //Code to execute after the animation completes goes here
        NSLog(@"Animation completed");
        [self startAnimationsForProgressType:MatchesProgress];
    };
    animationCompletionBlock matchesCompletionBlock = ^void(void)
    {
        //Code to execute after the animation completes goes here
        NSLog(@"Animation completed");
    };
    
    if (progressType == ProfileProgress) [pathAnimation setValue:profileCompletionBlock forKey:kAnimationCompletionBlock];
    else if (progressType == MatchesProgress) [pathAnimation setValue:matchesCompletionBlock forKey:kAnimationCompletionBlock];
    
    
    // Finally add it
    [pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    animationCompletionBlock theBlock = [anim valueForKey:kAnimationCompletionBlock];
    if (theBlock)
        theBlock();
}

@end
