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
//  PianoLayer.h
//  iDiary2
//
//  Created by Markus Konrad on 27.06.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"

#import "SoundObject.h"
#import "SoundHandler.h"

#define kPianoNoteDuration 0.75
#define kPianoHighlightColor ccc3(8, 200, 255)
#define kPianoAutoplayPreparationDelay 1.0
#define kPianoAutoplayStartDelay 2.5
#define kPianoAutoplayMinDelay 1.5
#define kPianoAutoplayIncreasePerTry 0.25
#define kPianoMaxNumberOfTries 3

// Defines a piano note
@interface PianoNote : NSObject {
    int step;   // key index
    float dur;  // duration to next note
}

@property (nonatomic,assign) int step;
@property (nonatomic,assign) float dur;

-(id)initPianoNoteAtStep:(int)s dur:(float)d;
+(id)pianoNoteAtStep:(int)s dur:(float)d;

@end

// Defines a piano key
@interface PianoKey : CCSprite {
    int hitCounter;
    float pitch;
}

@property (nonatomic,assign) float pitch;

// show that the key was hit. will increase the hit counter
-(void)hitNote;

// will decrease the hit counter and stop the highlighting if the counter is 0
-(void)releaseNote;

@end

@class PageLayer;

// Defines a piano
@interface PianoLayer : CCLayer {
    SoundHandler *sndHandler;          // shortcut to sound handler singleton
    
    PageLayer *pageLayer;               // page on which this game is running (weak ref)
    
    CCSprite *infoSpriteBeforeAutoplay; // will be shown before autoplay
    CCSprite *infoSpriteAfterAutoplay;  // will be shown after autoplay
    
    CCSprite *successSprite;    // image when the user played successfully
    CCSprite *failSprite;       // image when the user played wrong! :(

    NSMutableArray *keySprites; // array of piano keys as PainoKey objects
    
    NSMutableArray *playedNotes;    // array with NSNumbers containing the key indices that have been played so to check if it was played correctly

    int soundId;                  // sound that can be played a different pitches. It is a sound-id received from the SoundHandler
    SoundObject *sound;           // sound that can be played a different pitches
    int baseToneStep;           // tone step of the first key
    
    int applauseSndId;          // applause sound id
    SoundObject *applauseSnd;   // applause sound object
    
    int failSndId;          // fail sound id
    SoundObject *failSnd;   // fail sound object
    
    NSMutableArray *autoplaySeq;     // notes to play for autoplay. consists of PianoNote objects
    int curAutoplayNoteIndex;
    
    BOOL isInteractionEnabled;  // to enable/disable interactions
    int numTries;   // number of tries the user already had
    BOOL userWasCorrect;    // YES if the user played correctly
    CFTimeInterval lastPlayedNoteTs;    // timestamp for last played note
}

@property (nonatomic,assign) BOOL isInteractionEnabled;

// initialize the piano with a sound file that can be pitched and the tone step of the first key
-(id)initOnPageLayer:(PageLayer *)layer withSoundFile:(NSString *)sndFile andBaseToneStep:(int)baseTone andApplauseSound:(NSString *)applauseFile andFailSound:(NSString *)failFile;

// set autoplay info images
-(void)setAutoplayInfoImagesBefore:(NSString *)beforeImg atPos:(CGPoint)beforePos andAfter:(NSString *)afterImg atPos:(CGPoint)afterPos;

// set success/fail images
-(void)setSuccessImage:(NSString *)successImg atPos:(CGPoint)successPos andFailImage:(NSString *)failImg atPos:(CGPoint)failPos;

// add a piano key image
-(void)addKeyWithImage:(NSString *)image andRect:(CGRect)rect;
-(void)addKeyWithImage:(NSString *)image andRect:(CGRect)rect onTop:(BOOL)top;

// add a note to the autoplay sequence
-(void)addAutoplayNoteAtStep:(int)step withDuration:(float)dur;

// prepare autoplay. will show infoSpriteBeforeAutoplay
-(void)prepareAutoplay;

// start playing the autoplay sequence. also disables all interactions for that time
-(void)startAutoplay;

// stop playing the autoplay sequence. also enables all interactions again
-(void)stopAutoplay;

@end
