//
//  UITableView+LongPress.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-03-17.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "UITableView+LongPress.h"

@implementation UITableView (LongPress)
@dynamic delegate;

- (void)addLongPressRecognizer {
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.2; //seconds
    lpgr.delegate = self;
    [self addGestureRecognizer:lpgr];
}


- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self];
    
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:p];
    if (indexPath == nil) {
        NSLog(@"long press on table view but not on a row");
    }
    else {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            // I am not sure why I need to cast here. But it seems to be alright.
            [(id<UITableViewDelegateLongPress>)self.delegate tableView:self didRecognizeLongPressOnRowAtIndexPath:indexPath];
        }
    }
}

@end