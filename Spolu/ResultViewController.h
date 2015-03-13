//
//  ResultViewController.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-21.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>
#import "ChooseGroupView.h"
#import "EligibleGroupsDataSource.h"
#import "IRMatchServiceHandler.h"

@interface ResultViewController : UIViewController <MDCSwipeToChooseDelegate, EligibleGroupsDataSourceDelegate>
{
    __weak IBOutlet UIImageView *groupImageView;
    EligibleGroupsDataSource *eligibleGroupsDataSource;
    UIView *titleView;
    UILabel *distanceLabel;
    UILabel *ageLabel;
    IRMatchServiceHandler *matchServiceHandler;
}
@property (weak, nonatomic) UIImage *groupImage;

@property (nonatomic, strong) IRGroup *currentGroup;
@property (nonatomic, strong) ChooseGroupView *frontCardView;
@property (nonatomic, strong) ChooseGroupView *backCardView;

- (void)showStatusBar:(BOOL)show;

@end
