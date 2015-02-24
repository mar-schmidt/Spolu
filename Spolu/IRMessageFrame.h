//
//  IRMessageFrame.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-23.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#define ChatMargin 10
#define ChatIconWH 44
#define ChatPicWH 200
#define ChatContentW 180

#define ChatTimeMarginW 0
#define ChatTimeMarginH 0

#define ChatContentTop 10
#define ChatContentLeft 25
#define ChatContentBottom 10
#define ChatContentRight 15

#define ChatTimeFont [UIFont systemFontOfSize:11]
#define ChatContentFont [UIFont systemFontOfSize:14]

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class IRMessage;

@interface IRMessageFrame : NSObject

@property (nonatomic, assign, readonly) CGRect nameF;
@property (nonatomic, assign, readonly) CGRect iconF;
@property (nonatomic, assign, readonly) CGRect timeF;
@property (nonatomic, assign, readonly) CGRect contentF;

@property (nonatomic, assign, readonly) CGFloat cellHeight;
@property (nonatomic, strong) IRMessage *message;
@property (nonatomic, assign) BOOL showTime;

@end
