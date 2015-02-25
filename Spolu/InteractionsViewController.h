//
//  InteractionsViewController.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-21.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRWebSocketServiceHandler.h"

@interface InteractionsViewController : UIViewController
{
    IRWebSocketServiceHandler *webSocketHandler;
}
- (IBAction)dismissViewController:(id)sender;
@end
