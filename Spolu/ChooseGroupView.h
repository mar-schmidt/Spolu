//
//  ChooseGroupView.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-03-07.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDCSwipeToChooseView.h"

@class IRGroup;

@interface ChooseGroupView : MDCSwipeToChooseView
{
    NSMutableArray *currentDownloads;
}
@property (nonatomic, strong, readonly) IRGroup *group;

- (instancetype)initWithFrame:(CGRect)frame
                       group:(IRGroup *)group
                      options:(MDCSwipeToChooseViewOptions *)options;

@end
