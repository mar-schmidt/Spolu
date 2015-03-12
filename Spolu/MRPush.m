//
//  MRPush.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-03-12.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "MRPush.h"

@implementation MRPush

+ (void)handlePush:(NSDictionary *)userInfo
{
    NSInteger pushCode = [userInfo[@"push_Code"] integerValue];
    NSDictionary *aps = userInfo[@"aps"];
    NSInteger groupId = [userInfo[@"id"] integerValue];
    NSString *alertMessage = aps[@"alert"];
    
    if (pushCode == 1) { // pushCode 1 = New match
        NSLog(@"Push Notification received: %@ from group %ld", alertMessage, groupId);
        /*
         UILocalNotification *localNotif = [[UILocalNotification alloc] init];
         localNotif.fireDate = [NSDate date];
         localNotif.timeZone = [NSTimeZone defaultTimeZone];
         localNotif.alertBody = alertMessage;
         localNotif.alertAction = @"OK";
         localNotif.soundName = @"sonar.aiff";
         localNotif.applicationIconBadgeNumber += 1;
         localNotif.userInfo = nil;
         [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
         */
        
    }
    else  if (pushCode == 2) {
        //[[MobileControlService sharedService] logoutUser];
        //[[MobileControlService sharedService] cloudAcknowledge_whoSend:pushCode];
    }
    else if (pushCode == 3) {
        //[[MobileControlService sharedService] saveLocation];
    }
    else if (pushCode == 4) {
        //[[MobileControlHandler sharedInstance] playMobileControlAlertSound];
        // [[MobileControlHandler sharedInstance] makeAlarm];
        //[[MobileControlService sharedService] cloudAcknowledge_whoSend:pushCode];
    }
    else if (pushCode == 5) {
        /*
         if ([MobileControlHandler sharedInstance].isRecordingNow) {
         [[MobileControlHandler sharedInstance] stopRecord];
         } else {
         [[MobileControlHandler sharedInstance] startRecord];
         }
         [[MobileControlService sharedService] cloudAcknowledge_whoSend:pushCode];
         */
    }

}

@end
