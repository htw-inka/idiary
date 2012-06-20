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
