//
//  IRAVAudioPlayer.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-23.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "IRAVAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>


@interface IRAVAudioPlayer ()<AVAudioPlayerDelegate>
{
    AVAudioPlayer *player;
}
@end

@implementation IRAVAudioPlayer

+ (IRAVAudioPlayer *)sharedInstance
{
    static IRAVAudioPlayer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)playSongWithUrl:(NSString *)songUrl
{
    dispatch_async(dispatch_queue_create("dfsfe", NULL), ^{
        
        [self.delegate IRAVAudioPlayerBeiginLoadVoice];
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:songUrl]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (player) {
                [self.delegate IRAVAudioPlayerDidFinishPlay];
                [player stop];
                player.delegate = nil;
                player = nil;
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:@"VoicePlayHasInterrupt" object:nil];
            NSError *playerError;
            player = [[AVAudioPlayer alloc]initWithData:data error:&playerError];
            player.volume = 1.0f;
            if (player == nil){
                NSLog(@"ERror creating player: %@", [playerError description]);
            }
            [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategorySoloAmbient error: nil];
            player.delegate = self;
            [player play];
            [self.delegate IRAVAudioPlayerBeiginPlay];
        });
    });
}

-(void)playSongWithData:(NSData *)songData
{
    [self.delegate IRAVAudioPlayerDidFinishPlay];
    
    if (player) {
        [player stop];
        player.delegate = nil;
        player = nil;
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"VoicePlayHasInterrupt" object:nil];
    NSError *playerError;
    player = [[AVAudioPlayer alloc]initWithData:songData error:&playerError];
    player.volume = 1.0f;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategorySoloAmbient error: nil];
    player.delegate = self;
    [player play];
    [self.delegate IRAVAudioPlayerBeiginPlay];
    
}



- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.delegate IRAVAudioPlayerDidFinishPlay];
}

- (void)stopSound
{
    if (player && player.isPlaying) {
        [player stop];
    }
}

@end