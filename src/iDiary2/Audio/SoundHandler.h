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
//  SoundHandler.h
//  iDiary2
//
//  Created by Markus Konrad on 07.06.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CDAudioManager.h"
#import "Singleton.h"

#import "SoundObject.h"

static int soundIdCounter = 0;

@protocol SoundHandlerDelegate <NSObject>
-(void)readyToPlaySounds:(NSArray *)soundObjects;
@end

@interface SoundHandler : NSObject<Singleton> {
    id<SoundHandlerDelegate> delegate;   // SoundHandlerDelegate
    NSMutableDictionary *soundObjects;   // NSMutableDictionary with LOADED SoundObjects: NSNumber soundId -> SoundObject mapping
    NSMutableArray *registeredSoundObjects;    // NSMutableArray with registered but NOT loaded SoundObjects
    
    CDSoundEngine *audio;   // Shortcut to CDSoundEngine singleton
}

@property (nonatomic,assign) id<SoundHandlerDelegate> delegate;
@property (nonatomic,readonly) NSMutableDictionary *soundObjects;

// load an array with NSStrings that point to sound files
// will return an array of sound ids in the order of the submitted sound files
//-(NSArray *)loadSounds:(NSArray *)soundFiles looped:(BOOL)looped gain:(float)gain;

// register a sound to be loaded afterwards. return the sound id
-(int)registerSoundToLoad:(NSString *)pFile looped:(BOOL)looped gain:(float)gain;

// load all registered sound objects and clear the registeredSoundObjects array
-(void)loadRegisteredSounds;

// will set the delegate to nil if oldDelegate == delegate
-(void)unregisterDelegate:(id)oldDelegate;

// unload a sound buffer
-(void)unloadSound:(int)soundId;
-(void)unloadSounds:(NSArray *)soundIds;

// unload all sound buffers
-(void)unloadAllSounds;

// get a sound object from a sound id
-(SoundObject *)getSound:(int)soundId;

// get a sound object from a file
-(SoundObject *)getSoundByFile:(NSString *)pFile;


@end
