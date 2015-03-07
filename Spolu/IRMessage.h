//
//  IRMessage.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-23.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef enum {
    IRMessageTypeText     = 0,
    IRMessageTypePicture  = 1,
    IRMessageTypeVoice    = 2
} MessageType;


typedef enum {
    IRMessageFromMe    = 100,
    IRMessageFromOther = 101
} MessageFrom;


@interface IRMessage : NSObject

@property (nonatomic, copy) NSString *strIcon;
@property (nonatomic, copy) NSString *strId;
@property (nonatomic, copy) NSString *strTime;
@property (nonatomic, copy) NSString *strName;

@property (nonatomic, copy) NSString *strContent;
@property (nonatomic, copy) UIImage  *picture;
@property (nonatomic, copy) NSData   *voice;
@property (nonatomic, copy) NSString *strVoiceTime;

@property (nonatomic, assign) MessageType type;
@property (nonatomic, assign) MessageFrom from;

@property (nonatomic, assign) BOOL showDateLabel;

@property (nonatomic, assign) BOOL readFlag;

- (void)minuteOffSetStart:(NSString *)start end:(NSString *)end;

@end
