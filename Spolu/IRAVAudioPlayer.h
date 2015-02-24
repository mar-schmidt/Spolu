//
//  IRAVAudioPlayer.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-23.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>


@protocol IRAVAudioPlayerDelegate <NSObject>

- (void)IRAVAudioPlayerBeiginLoadVoice;
- (void)IRAVAudioPlayerBeiginPlay;
- (void)IRAVAudioPlayerDidFinishPlay;

@end

@interface IRAVAudioPlayer : NSObject

@property (nonatomic, assign)id <IRAVAudioPlayerDelegate>delegate;
+ (IRAVAudioPlayer *)sharedInstance;

-(void)playSongWithUrl:(NSString *)songUrl;
-(void)playSongWithData:(NSData *)songData;

- (void)stopSound;
@end

