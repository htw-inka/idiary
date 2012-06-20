// Copyright (c) 2012, HTW Berlin / Project HardMut
// (http://www.hardmut-projekt.de)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//
// * Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright
//   notice, this list of conditions and the following disclaimer in the
//   documentation and/or other materials provided with the distribution.
// * Neither the name of the HTW Berlin / INKA Research Group nor the names
//   of its contributors may be used to endorse or promote products derived
//   from this software without specific prior written permission.

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
// IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
// THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
