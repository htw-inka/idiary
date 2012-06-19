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
