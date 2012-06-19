//
//  SoundObject.mm
//  iDiary2
//
//  Created by Markus Konrad on 07.06.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "SoundObject.h"

@interface SoundObject(PrivateMethods)
-(void)soundEnded;
@end

@implementation SoundObject

@synthesize soundId;
@synthesize file;
@synthesize playLooped;
@synthesize isPlaying;
@synthesize gain;
@synthesize pitch;

#pragma mark init / dealloc

- (id)init {
    self = [super init];
    if (self) {
        audio = [CDAudioManager sharedManager].soundEngine;
    
        // set default vars
        playLooped = NO;
        isPlaying = NO;
        pitch = 1.0f;
        gain = 1.0f;
    }
    return self;
}

-(id)initWithSoundId:(int)pSoundId andFile:(NSString *)pFile {
    if ((self = [self init])) {
        // set default vars
        soundId = pSoundId;
        file = [pFile retain];
    }
    
    return self;
}

- (void)dealloc {
    [self unloadBuffer];

    [file release];
    
    [super dealloc];
}

#pragma mark public messages

-(CDBufferLoadRequest *)createBufferLoadRequest {
    NSAssert(file != nil, @"Sound file cannot be nil!");
    
    return [[[CDBufferLoadRequest alloc] init:soundId filePath:file] autorelease];
}

-(void)unloadBuffer {
    [self stop];
    
//    NSLog(@"Unloading sound#%d %@", soundId, file);
    [audio unloadBuffer:soundId];
}

-(void)playWithCallback:(SEL)callback atObject:(id)object {
    [object performSelector:callback withObject:nil afterDelay:[audio bufferDurationInSeconds:soundId]];
    
    [self play];
}

-(void)play {
    NSLog(@"Playing sound#%d %@", soundId, file);
    [self playAtPitch:pitch];
}

-(void)playAtPitch:(float)pPitch; {
//    NSLog(@"Playing sound#%d %@", soundId, file);

    isPlaying = YES;

    [audio playSound:soundId
       sourceGroupId:0
               pitch:pPitch
                 pan:0.0f 
                gain:gain
                loop:playLooped];
                
    [self performSelector:@selector(soundEnded) withObject:nil afterDelay:[audio bufferDurationInSeconds:soundId]];
}

//-(void)pause {
//    [audio stopSound:soundId];
//}

-(void)stop {
    [audio stopSound:soundId];
    
    if (playLooped) {
        NSLog(@"Warning: Looped sounds can not be stopped or paused or anything!");
    } else {
        isPlaying = NO;
    }
//
//    CDSoundSource *src = [audio soundSourceForSound:soundId sourceGroupId:0];
//    
//    [src setMute:YES];
//    [src setGain:0.0f];
//    [src setLooping:NO];
//    [src stop];
//    
//    NSLog(@"Stopping sound#%d %@: %p", soundId, file, src);
//    
//    [src pause];
//    [src rewind];
}

#pragma mark private messages

-(void)soundEnded {
    isPlaying = NO;
}

@end
