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
