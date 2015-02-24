//
//  MJRefreshConst.h
//  MJRefresh
//
//  Created by mj on 14-1-3.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef DEBUG
#define MJLog(...) NSLog(__VA_ARGS__)
#else
#define MJLog(...)
#endif

#define MJRefreshLabelTextColor [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1.0]
#define kSrcName(file) [MJRefreshBundleName stringByAppendingPathComponent:file]

extern const CGFloat MJRefreshViewHeight;
extern const CGFloat MJRefreshAnimationDuration;

extern NSString *const MJRefreshBundleName;


extern NSString *const MJRefreshFooterPullToRefresh;
extern NSString *const MJRefreshFooterReleaseToRefresh;
extern NSString *const MJRefreshFooterRefreshing;

extern NSString *const MJRefreshHeaderPullToRefresh;
extern NSString *const MJRefreshHeaderReleaseToRefresh;
extern NSString *const MJRefreshHeaderRefreshing;
extern NSString *const MJRefreshHeaderTimeKey;

extern NSString *const MJRefreshContentOffset;
extern NSString *const MJRefreshContentSize;