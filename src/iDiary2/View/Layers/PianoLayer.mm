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
//  PianoLayer.mm
//  iDiary2
//
//  Created by Markus Konrad on 27.06.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "PianoLayer.h"

#import "Config.h"
#import "Tools.h"
#import "CoreHolder.h"
#import "CommonActions.h"

@implementation PianoNote

@synthesize step;
@synthesize dur;

-(id)initPianoNoteAtStep:(int)s dur:(float)d {
    self = [super init];
    if (self) {
        step = s;
        dur = d;
    }
    return self;
}

+(id)pianoNoteAtStep:(int)s dur:(float)d {
    return [[[PianoNote alloc] initPianoNoteAtStep:s dur:d] autorelease];
}

@end

@implementation PianoKey

@synthesize pitch;

- (id)init {
    self = [super init];
    if (self) {
        hitCounter = 0;
        pitch = 1.0f;
    }
    return self;
}

-(void)hitNote {
    hitCounter++;
    
    [self setColor:kPianoHighlightColor];
    
    if (hitCounter <= 1) {
        [self runAction:[CommonActions highlightForInteractiveElement:self]];
    }
}

-(void)releaseNote {
    hitCounter--;
    
    
    if (hitCounter <= 0) {
        hitCounter = 0;
        [self setColor:ccc3(255, 255, 255)];
    }
}

@end

@interface PianoLayer(PrivateMethods)
// play a tone with the key at the index "index".
-(void)playToneAtIndex:(int)index;

// calculate the pitch from a note step
-(float)getPitchForStep:(int)step;

// play next note in autoplay sequence. will call itself again until all notes are played
-(void)playNextAutoplayNote;

// handle received touches, return number of hit sprites
-(int)handleTouches:(NSSet *)touches;

// Will be called when the full sequence has been played CORRECTLY by the user.
-(void)sequenceWasPlayed;

// Will be called when the user made a mistake playing the piano
-(void)userMadeMistake;

// Checks if the maximum number of tries have been reached. turn page.
-(void)checkIfGameFinishedAndTurnPage;
@end

static const int kPianoLayerBlackKeyZ = 100;
static const float kPianoLayerMinNoteRepeatTime = 0.3;  // in sec.

@implementation PianoLayer

@synthesize isInteractionEnabled;
#pragma mark init/dealloc

-(id)initOnPageLayer:(PageLayer *)layer withSoundFile:(NSString *)sndFile andBaseToneStep:(int)baseTone andApplauseSound:(NSString *)applauseFile andFailSound:(NSString *)failFile {
    self = [super init];
    if (self) {
        // set defaults
        sndHandler = [SoundHandler shared];
        
        pageLayer = layer;
    
        keySprites = [[NSMutableArray alloc] init];
        playedNotes = [[NSMutableArray alloc] init]; 
        autoplaySeq = [[NSMutableArray alloc] init];
        
        curAutoplayNoteIndex = 0;
        
        lastPlayedNoteTs = 0;
        
        numTries = 0;
        userWasCorrect = YES;
        
        isInteractionEnabled = YES;
        
        // set the sounds
        baseToneStep = baseTone;
        soundId = [sndHandler registerSoundToLoad:sndFile looped:NO gain:kFxSoundVolume];
        applauseSndId = [sndHandler registerSoundToLoad:applauseFile looped:NO gain:kFxSoundVolume];
        failSndId = [sndHandler registerSoundToLoad:failFile looped:NO gain:kFxSoundVolume];
        
        // get the sounds
        [sndHandler loadRegisteredSounds];
        sound = [[sndHandler getSound:soundId] retain];
        applauseSnd = [[sndHandler getSound:applauseSndId] retain];
        failSnd = [[sndHandler getSound:failSndId] retain];
        
        // set CCLayer properties
        [self setIsTouchEnabled:YES];
    }
    return self;
}

-(void)dealloc {
    [self stopAutoplay];
    
    [sndHandler unloadSound:soundId];
    [sndHandler unloadSound:applauseSndId];
    [sndHandler unloadSound:failSndId];
    
    [sound release];
    [applauseSnd release];
    [failSnd release];
    
    [autoplaySeq release];
    [playedNotes release];
    [keySprites release];
    
    [infoSpriteAfterAutoplay release];
    [infoSpriteBeforeAutoplay release];
    
    [successSprite release];
    [failSprite release];
    
    [super dealloc];
}

#pragma mark public methods

-(void)setAutoplayInfoImagesBefore:(NSString *)beforeImg atPos:(CGPoint)beforePos andAfter:(NSString *)afterImg atPos:(CGPoint)afterPos {
    [infoSpriteBeforeAutoplay release];
    [infoSpriteAfterAutoplay release];
    
    // set "before" sprite
    infoSpriteBeforeAutoplay = [[CCSprite spriteWithFile:beforeImg] retain];
    [infoSpriteBeforeAutoplay setPosition:beforePos];
    [infoSpriteBeforeAutoplay setOpacity:0];  // will be faded in!
    [self addChild:infoSpriteBeforeAutoplay];

    // set "after" sprite
    infoSpriteAfterAutoplay = [[CCSprite spriteWithFile:afterImg] retain];
    [infoSpriteAfterAutoplay setPosition:afterPos];
    [infoSpriteAfterAutoplay setOpacity:0];
    [self addChild:infoSpriteAfterAutoplay];    
}

-(void)setSuccessImage:(NSString *)successImg atPos:(CGPoint)successPos andFailImage:(NSString *)failImg atPos:(CGPoint)failPos {
    [successSprite release];
    [failSprite release];
    
    // set "success" sprite
    successSprite = [[CCSprite spriteWithFile:successImg] retain];
    [successSprite setPosition:successPos];
    [successSprite setOpacity:0];  // will be faded in!
    [self addChild:successSprite];

    // set "fail" sprite
    failSprite = [[CCSprite spriteWithFile:failImg] retain];
    [failSprite setPosition:failPos];
    [failSprite setOpacity:0];
    [self addChild:failSprite];    
}

-(void)addKeyWithImage:(NSString *)image andRect:(CGRect)rect {
    [self addKeyWithImage:image andRect:rect onTop:NO];
}

-(void)addKeyWithImage:(NSString *)image andRect:(CGRect)rect onTop:(BOOL)top {
    // create the sprite
    PianoKey *keySpr = [PianoKey spriteWithFile:image];
    [keySpr setPosition:rect.origin];
    int keyIndex = [keySprites count];
    
    // calculate and set the pitch
    [keySpr setPitch:[self getPitchForStep:keyIndex]];
    
    // add it as child
    if (top) keyIndex += kPianoLayerBlackKeyZ;
    [self addChild:keySpr z:keyIndex];
    
    // add it to the array
    [keySprites addObject:keySpr];
}

-(void)addAutoplayNoteAtStep:(int)step withDuration:(float)dur {
    [autoplaySeq addObject:[PianoNote pianoNoteAtStep:step dur:dur]];
}

-(void)prepareAutoplay {
    [infoSpriteBeforeAutoplay runAction:[CCFadeIn actionWithDuration:kGeneralFadeDuration]];
    
    // clear the played notes
    [playedNotes removeAllObjects];
}

-(void)startAutoplay {
    if (curAutoplayNoteIndex > -1) {
        isInteractionEnabled = NO;
        curAutoplayNoteIndex = 0;
        [pageLayer cancelHighlightAnimations];
        [self playNextAutoplayNote];
    }
}

-(void)stopAutoplay {    
    curAutoplayNoteIndex = -1;
    isInteractionEnabled = YES;
}

#pragma mark touch interaction

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {    
    if ([self handleTouches:touches] > 0) {
        [pageLayer cancelHighlightAnimations];
        [[CoreHolder sharedCoreHolder] setInteractiveObjectWasTouched:YES];
    } else {
        [pageLayer ccTouchesBegan:touches withEvent:event];
    }
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self handleTouches:touches] > 0) {
        [pageLayer cancelHighlightAnimations];
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [pageLayer ccTouchesEnded:touches withEvent:event];
}

#pragma mark private methods

-(int)handleTouches:(NSSet *)touches {
    if (!isInteractionEnabled) return 1;

    int numHitElements = 0;

    // for each finger
    for (UITouch *touch in touches) {        
        // check if we've hit any key sprite
        int keyIndex = 0;   // key index is important for the pitch of the note
        for (PianoKey *keySpr in keySprites) {
            if ([Tools touch:touch isInNode:keySpr]) {
                CGPoint hitPoint = [Tools convertTouchToGLPoint:touch];
                CFTimeInterval now = CACurrentMediaTime();
                if ((now - lastPlayedNoteTs >= kPianoLayerMinNoteRepeatTime)
                && ((hitPoint.y < 290 && keySpr.zOrder < kPianoLayerBlackKeyZ) || (hitPoint.y >= 290 && keySpr.zOrder >= kPianoLayerBlackKeyZ))) {
                    // update timestamp
                    lastPlayedNoteTs = now;
                
                    // play the note
                    [self playToneAtIndex:keyIndex];
                    
                    if (playedNotes != nil) {   // only check the sequence if not in "free play" mode
                        // remember it!
                        [playedNotes addObject:[NSNumber numberWithInt:keyIndex]];
                        
                        // check if note was correct
                        PianoNote *seqNote = [autoplaySeq objectAtIndex:[playedNotes count] - 1];
                        
                        if (userWasCorrect && keyIndex != seqNote.step) {
                            userWasCorrect = NO;
                            
                            isInteractionEnabled = NO;
                            [infoSpriteAfterAutoplay runAction:[CCFadeOut actionWithDuration:kGeneralFadeDuration]];
                            
                            [self performSelector:@selector(userMadeMistake) withObject:nil afterDelay:kPianoNoteDuration / 2.0f];
                        }
                        
                        // check if we played the full sequence
                        if (userWasCorrect && [playedNotes count] == [autoplaySeq count]) {
                            [self sequenceWasPlayed];
                        }
                    }
                    
                    numHitElements++;
                }
                
    //            // only play the first note that has been hit
    //            return;
            }
            
            keyIndex++;
        }
    }
    
    return numHitElements;
}

-(void)playNextAutoplayNote {
    if (curAutoplayNoteIndex < 0 || curAutoplayNoteIndex >= [autoplaySeq count]) {
        [self stopAutoplay];
        
        // fade info sprites
        [infoSpriteBeforeAutoplay runAction:[CCFadeOut actionWithDuration:kGeneralFadeDuration]];
        [infoSpriteAfterAutoplay runAction:[CCFadeIn actionWithDuration:kGeneralFadeDuration]];
        
        // show an image
        if (!userWasCorrect && failSprite.opacity == 0) {
            [failSprite runAction:[CCFadeIn actionWithDuration:kGeneralFadeDuration]];
        }
        
        return; // stop playing
    }

    // get the current note
    PianoNote *note = [autoplaySeq objectAtIndex:curAutoplayNoteIndex];
    
    // play the note
    [self playToneAtIndex:note.step];
    
    // move on
    curAutoplayNoteIndex++;
    float speed = kPianoAutoplayMinDelay + numTries * kPianoAutoplayIncreasePerTry;
    [self performSelector:@selector(playNextAutoplayNote) withObject:nil afterDelay:(note.dur * speed)];
}

-(void)playToneAtIndex:(int)index {
    if (index < 0 || index >= [keySprites count]) {
        NSLog(@"WARNING: Invalid tone index for piano: %d", index);
        return;
    }
    
    // get the key
    PianoKey *keySpr = [keySprites objectAtIndex:index];
    
    // play the sound
    [sound playAtPitch:keySpr.pitch];
    
    // show it visually    
    [keySpr hitNote];
    
    // stop the note after a duration
    [keySpr performSelector:@selector(releaseNote) withObject:nil afterDelay:kPianoNoteDuration / 2.0f];
}

-(void)sequenceWasPlayed {
    isInteractionEnabled = NO;
    [infoSpriteAfterAutoplay runAction:[CCFadeOut actionWithDuration:kGeneralFadeDuration]];
    
    [playedNotes release];
    playedNotes = nil;

    NSLog(@"Perfect!");
    
    // show an image
    [successSprite runAction:[CCFadeIn actionWithDuration:kGeneralFadeDuration]];
    
    if (failSprite.opacity > 0) {   // hide any "fail" sprites
        [failSprite runAction:[CCFadeOut actionWithDuration:kGeneralFadeDuration]];
    }
    
    // play a sound
    [applauseSnd performSelector:@selector(play) withObject:nil afterDelay:0.5f];
    
    // reenable interactions
    [self performSelector:@selector(stopAutoplay) withObject:nil afterDelay:1.0f];
}

-(void)userMadeMistake {
    NSLog(@"ZONK!");
    
    // play a sound
    [failSnd performSelector:@selector(play) withObject:nil afterDelay:0.5f];
    
    // start next try
    numTries++;
    
    [self checkIfGameFinishedAndTurnPage];
    
    curAutoplayNoteIndex = 0;
    userWasCorrect = YES;   // reset
    [self performSelector:@selector(prepareAutoplay) withObject:nil afterDelay:kPianoAutoplayPreparationDelay];
    [self performSelector:@selector(startAutoplay) withObject:nil afterDelay:kPianoAutoplayStartDelay];
}

-(void)checkIfGameFinishedAndTurnPage {
    if (numTries >= kPianoMaxNumberOfTries) {
        // turn the page
        [[pageLayer core] showNextPage:nil];
    }
}

-(float)getPitchForStep:(int)step {
    return pow(2.0, (step + baseToneStep) / 12.0);
}

@end
