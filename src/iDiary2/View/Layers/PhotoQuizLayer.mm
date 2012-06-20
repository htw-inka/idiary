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
//  PhotoQuizLayer.m
//  iDiary2
//
//  Created by Erik Lippmann on 30.01.12.
//  Copyright 2012 INKA Forschungsgruppe. All rights reserved.
//

#import "PhotoQuizLayer.h"

#import "Config.h"
#import "CommonActions.h"
#import "Tools.h"

static NSString *kGroupIdentifier = @"photoquiz";

@interface PhotoQuizLayer (PrivateMethods)

// will be called when every photo has been placed on its target
- (void)gameFinished;
// will be called when a photo reaches any target area
- (void)magneticDistReached:(NSString *)age;
// will be called when a photo left any target area
- (void)magneticDistLeft:(NSString *)age;
// will be called when the touch ended in the target area the current touched photo
- (void)objectMatched:(NSString *)age;
// will be called when the touch enden in another target area than the one defined for the current touched photo
- (void)objectNotMatched:(NSString *)age;
// will be called when the current touched photo has been put into the right target area
- (void)removeSprite:(id)sender;

@end

@implementation PhotoQuizLayer

- (id)initOnPageLayer:(PageLayer *)layer withImageFilePrefix:(NSString *)imagePrefix photoFilePostfix:(NSString *)photo andTagetFilePostfix:(NSString *)target {
    
    self = [super initOnPageLayer:layer withMagneticDistance:kDefaultSnappingDistance targetAreaZBegin:0 arrangableObjectsZBegin:100];
    
    if (self) {
        imageFilePrefix = [imagePrefix retain];
        photoFilePostfix = [photo retain];
        targetFilePostfix = [target retain];
        parentLayer = [layer retain];
        
        kScaleFactor = 1.05;
        kScaleDuration = 0.15;
        
        photos = [[NSMutableDictionary alloc] init];
        spriteSetKeys = [[NSMutableArray alloc] init];
        finishedPhotos = 0;
        
        // load sounds
        chimeSoundId = [sndHandler registerSoundToLoad:@"blopp1.mp3" looped:NO gain:kFxSoundVolume];
        oopsSoundId = [sndHandler registerSoundToLoad:@"oops1.mp3" looped:NO gain:kFxSoundVolume];
        successSoundId = [sndHandler registerSoundToLoad:@"applause1.mp3" looped:NO gain:kFxSoundVolume];
        [sndHandler loadRegisteredSounds];
        
        chimeSound = [[sndHandler getSound:chimeSoundId] retain];
        oopsSound = [[sndHandler getSound:oopsSoundId] retain];
        successSound = [[sndHandler getSound:successSoundId] retain];
        
        currentHighlightedTarget = @"none";
    }
    
    return self;
}

- (void)dealloc {
    [sndHandler unloadSound:chimeSoundId];
    [chimeSound release];
    [sndHandler unloadSound:oopsSoundId];
    [oopsSound release];
    [sndHandler unloadSound:successSoundId];
    [successSound release];
    
    [photos release];
    [spriteSetKeys release];
    [imageFilePrefix release];
    [photoFilePostfix release];
    [targetFilePostfix release];
    
    [parentLayer release];
    
    [super dealloc];
}


- (void) addPhotoForAge:(NSString *)age atPosition:(CGPoint)photoPosition targetPosition:(CGPoint)targetPosition andCornersPosition:(CGPoint)cornersPosition {
    
    NSString *photoBgImg = [NSString stringWithFormat:@"%@__%@__%@.png", imageFilePrefix, age, targetFilePostfix];
    CCSprite *photoBgSprite = [CCSprite spriteWithFile:photoBgImg];
    [photoBgSprite setPosition:targetPosition];
    [self addChild:photoBgSprite z:100];
    
    NSString *photoImg = [NSString stringWithFormat:@"%@__%@__%@.png", imageFilePrefix, age, photoFilePostfix];
    CCSprite *photoFinalSprite = [CCSprite spriteWithFile:photoImg];
    [photoFinalSprite setPosition:targetPosition];
    [photoFinalSprite setOpacity:0];
    [self addChild:photoFinalSprite z:200];
    
    NSString *cornersImg = [NSString stringWithFormat:@"%@__%@__fotoecken.png", imageFilePrefix, age];
    CCSprite *cornersSprite = [CCSprite spriteWithFile:cornersImg];
    [cornersSprite setPosition:cornersPosition];
    [self addChild:cornersSprite z:300];
    
    CCSprite *photoMoveableSprite = [CCSprite spriteWithFile:photoImg];
    [photoMoveableSprite setPosition:photoPosition];
    int photoCnt = [photos count];
    [self addChild:photoMoveableSprite z:(400-photoCnt) ];
    [parentLayer.interactiveElements addObject:photoMoveableSprite];
    
    NSString *done = @"NO";
    
    // add photo and background into one set
    NSMutableArray *spriteSet = [NSMutableArray arrayWithObjects:photoBgSprite, photoMoveableSprite, photoFinalSprite, cornersSprite, done, nil];
    
    // add the sprite set to the sprite dictionary
    [photos setObject:spriteSet forKey:age];
    [spriteSetKeys addObject:age];
}

# pragma mark private methods

- (void)magneticDistReached:(NSString *)age {
    NSLog(@"Magnetic distance reached for age: %@", age);
    
    // scale background and corners
    NSArray *spriteSet = [photos objectForKey:age];
    
    CCSprite *tmpCorners = [spriteSet objectAtIndex:kPhotoSpriteCorners];
    [tmpCorners runAction:[CCScaleTo actionWithDuration:kScaleDuration scale:kScaleFactor]];
    CCSprite *tmpBg = [spriteSet objectAtIndex:kPhotoSpriteBackground];
    [tmpBg runAction:[CCScaleTo actionWithDuration:kScaleDuration scale:kScaleFactor]];
}

- (void)magneticDistLeft:(NSString *)age {
    NSLog(@"Magnetic distance left for age: %@", age);
    
    // scale back background and corners
    NSArray *spriteSet = [photos objectForKey:age];
    
    CCSprite *tmpCorners = [spriteSet objectAtIndex:kPhotoSpriteCorners];
    [tmpCorners runAction:[CCScaleTo actionWithDuration:kScaleDuration scale:1.0]];
    CCSprite *tmpBg = [spriteSet objectAtIndex:kPhotoSpriteBackground];
    [tmpBg runAction:[CCScaleTo actionWithDuration:kScaleDuration scale:1.0]];
}

- (void)objectMatched:(NSString *)age {
    NSLog(@"Magnetic object matched for age: %@", age);

    // play chime sound
    [chimeSound play];
    
    // scale back background and corners
    [self magneticDistLeft:age];
    
    NSArray *spriteSet = [photos objectForKey:age];
    
    CCSprite *final = [spriteSet objectAtIndex:kPhotoSpriteFinal];
    
    [final runAction:[CCFadeIn actionWithDuration:0.5]];
    [activeSprite runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.5],[CCCallFuncN actionWithTarget:self selector:@selector(removeSprite:)], nil]];
    
    currentHighlightedTarget = @"none";  
    [(NSMutableArray *)[photos objectForKey:age] replaceObjectAtIndex:kPhotoSpriteDone withObject:@"YES"];
    
    finishedPhotos ++;
    NSLog(@"%i of %i photos finished", finishedPhotos, [photos count]);
    if (finishedPhotos == [photos count]) [self gameFinished];
}

- (void) removeSprite:(id)sender {
    CCSprite *sprite = (CCSprite *)sender;
    [self removeChild:sprite cleanup:YES];
    NSLog(@"Active photo removed.");
}

- (void)objectNotMatched:(NSString *)age {
    NSLog(@"Magnetic object did not match for age: %@", age);
    
    //play oops sound
    [oopsSound play];  
    
    [self magneticDistLeft:age];
    
    NSArray *spriteSet = [photos objectForKey:activeSpriteSetKey];
    CCSprite *moveableSprite = [spriteSet objectAtIndex:kPhotoSpriteMoveable];
    [moveableSprite runAction:[CCMoveTo actionWithDuration:0.25 position:CGPointMake(1024/2, 768/2)]];
}

- (void)gameFinished {
    NSLog(@"Game finished");
    
    // play applause sound
    [successSound play];
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
        
    for (NSString *spriteSetKey in spriteSetKeys) {
        
        NSArray *spriteSet = [photos objectForKey:spriteSetKey];
        
        // check if current photo has been marked as done
        if ([spriteSet objectAtIndex:kPhotoSpriteDone] == @"NO") { 
            CCSprite *item = (CCSprite *)[spriteSet objectAtIndex:kPhotoSpriteMoveable];
            
            if ([Tools touch:touch isInNode:item]) {
                NSLog(@"Photo touched");
                activeSpriteSetKey = spriteSetKey;
                activeSprite = item;
                activeTarget = (CCSprite *)[spriteSet objectAtIndex:kPhotoSpriteBackground];
                
                [[CoreHolder sharedCoreHolder] setInteractiveObjectWasTouched:YES];
                
                break;
                
            } else NSLog(@"Photo not touched");
        }
        
        // if the photo has been marked as done
        else {
            NSLog(@"The photo for age %@ has been marked as done.", spriteSetKey);
        }
    }
}

- (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // check if there is a photo selected by the first tab
    if (activeSprite != nil) {
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [Tools convertTouchToGLPoint:touch];
        
        // move the photo where the tab is
        [activeSprite setPosition:touchPoint];
    
        // check if the touch is in any target area
        for (NSString *spriteSetKey in spriteSetKeys) {
            NSArray *spriteSet = [photos objectForKey:spriteSetKey];
        
            // check if the touch is in current target area
            if ([Tools touch:touch isInNode:(CCSprite *)[spriteSet objectAtIndex:kPhotoSpriteBackground]]) {
                // if there is no target area highlighted yet
                if (currentHighlightedTarget == @"none") {
                    NSLog(@"Target for age %@ reached.", spriteSetKey);
                    [self magneticDistReached:spriteSetKey];
                    currentHighlightedTarget = spriteSetKey;
                }             
            }
            // if the touch isn't in the current target area
            else  {
                // check if current target area is already highlighted
                if (currentHighlightedTarget == spriteSetKey) {
                    NSLog(@"Target for age %@ left.", spriteSetKey);
                    [self magneticDistLeft:spriteSetKey];
                    currentHighlightedTarget = @"none";
                }            
            }
        }
    }
}

- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (activeSprite != nil) {
        if ([Tools touch:touch isInNode:activeTarget]) {
            [self objectMatched:currentHighlightedTarget];
        }  
        else [self objectNotMatched:currentHighlightedTarget];
        
        currentHighlightedTarget = @"none";
        activeSprite = nil;
        activeTarget = nil;     
    }
}

@end
