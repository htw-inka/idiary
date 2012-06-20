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
//  SoundHandler.mm
//  iDiary2
//
//  Created by Markus Konrad on 07.06.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "SoundHandler.h"

static const float kBufferCheckInterval = 0.5f;

@interface SoundHandler(PrivateMethods)
-(void)checkBufferLoadingState:(id)paramObj;
@end

@implementation SoundHandler

@synthesize delegate;
@synthesize soundObjects;

#pragma mark init/dealloc

- (id)init {
    self = [super init];
    
    if (self) {
        audio = [CDAudioManager sharedManager].soundEngine;
        
        soundObjects = [[NSMutableDictionary alloc] init];
        registeredSoundObjects = [[NSMutableArray alloc] init];
    }
    
    return self;
}

// dealloc unused, because this is a singleton!
//- (void)dealloc {
//    
//    [super dealloc];
//}

#pragma mark public messages

-(int)registerSoundToLoad:(NSString *)pFile looped:(BOOL)looped gain:(float)gain {
    // load and configure sound object
    int sId = soundIdCounter++;
    SoundObject *sObj = [[SoundObject alloc] initWithSoundId:sId andFile:pFile];
    [sObj setPlayLooped:looped];
    [sObj setGain:gain];
    
    // add it to the registered sound objects
    [registeredSoundObjects addObject:sObj];
    
    // cleanup
    [sObj release];
    
    return sId;
}

-(void)loadRegisteredSounds {
    NSMutableArray *loadRequests = [[NSMutableArray alloc] initWithCapacity:[registeredSoundObjects count]];

    // create the load request array and add the registered objects to the soundObjects array
    for (SoundObject *sObj in registeredSoundObjects) {
        NSLog(@"Loading registered sound#%d: %@", sObj.soundId, sObj.file);
    
        // add a load request
        [loadRequests addObject:[sObj createBufferLoadRequest]];
        
        // add a sound object
        [soundObjects setObject:sObj forKey:[NSNumber numberWithInt:sObj.soundId]];
    }
    
    // load the buffers in background
    [audio loadBuffersAsynchronously:loadRequests];
    
    // start checking for the loading state
    [self checkBufferLoadingState:nil];
    
    // cleanup
    [loadRequests release];
    [registeredSoundObjects removeAllObjects];
}

-(void)unloadSounds:(NSArray *)soundIds {
    for (NSNumber *sId in soundIds) {
        [self unloadSound:[sId intValue]];
    }
}

-(void)unloadSound:(int)soundId {
    [[self getSound:soundId] unloadBuffer];
    [soundObjects removeObjectForKey:[NSNumber numberWithInt:soundId]];
}

-(void)unloadAllSounds {
//    for (SoundObject *sObj in [soundObjects allValues]) {
//        [sObj unloadBuffer];
//    }
    
    [soundObjects removeAllObjects];
}

-(SoundObject *)getSound:(int)soundId {
    return [soundObjects objectForKey:[NSNumber numberWithInt:soundId]];
}

-(SoundObject *)getSoundByFile:(NSString *)pFile {
    for (SoundObject *sObj in [soundObjects allValues]) {
        if ([sObj.file isEqualToString:pFile]) {
            return sObj;
        }
    }
    
    return nil;
}

-(void)unregisterDelegate:(id)oldDelegate {
    if (oldDelegate == delegate) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];    // stop checkBufferLoadingState: method
        delegate = nil;
    }
}

#pragma mark private messages

-(void)checkBufferLoadingState:(id)paramObj {
    float bufferState = audio.asynchLoadProgress;
    
//    NSLog(@"Audio buffer loading state is now %f", bufferState);

    if (bufferState >= 1.0f) {
        [delegate readyToPlaySounds:[soundObjects allKeys]];
    } else {
        // check again after some time
        [self performSelector:@selector(checkBufferLoadingState:) withObject:nil afterDelay:kBufferCheckInterval];
    }
}

#pragma mark singleton stuff

static SoundHandler* sharedObject;

+ (SoundHandler*)shared {
    if (sharedObject == nil) {
        sharedObject = [[super allocWithZone:NULL] init];
    }
    return sharedObject;    
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self shared] retain];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}


@end
