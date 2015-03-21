//
//  UITableView+LongPress.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-03-17.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UITableViewDelegateLongPress;

@interface UITableView (LongPress) <UIGestureRecognizerDelegate>
@property (nonatomic,assign) id <UITableViewDelegateLongPress>delegate;

- (void)addLongPressRecognizer;

@end


@protocol UITableViewDelegateLongPress <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didRecognizeLongPressOnRowAtIndexPath:(NSIndexPath *)indexPath;

@end