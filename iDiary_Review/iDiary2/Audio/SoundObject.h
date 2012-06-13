//
//  SoundObject.h
//  iDiary2
//
//  Created by Markus Konrad on 07.06.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CDAudioManager.h"

@interface SoundObject : NSObject {
    CDSoundEngine *audio;   // Shortcut to CDSoundEngine singleton

    int soundId;
    NSString *file;
    BOOL playLooped;
    BOOL isPlaying;
    
    float gain;
    float pitch;
}

@property (nonatomic,assign) int soundId;
@property (nonatomic,retain) NSString *file;
@property (nonatomic,assign) BOOL playLooped;
@property (nonatomic,readonly) BOOL isPlaying;
@property (nonatomic,assign) float gain;
@property (nonatomic,assign) float pitch;

-(id)initWithSoundId:(int)pSoundId andFile:(NSString *)pFile;

-(CDBufferLoadRequest *)createBufferLoadRequest;
-(void)unloadBuffer;

-(void)playWithCallback:(SEL)callback atObject:(id)object;
-(void)play;
-(void)playAtPitch:(float)pPitch;

//-(void)pause;
-(void)stop;

@end
