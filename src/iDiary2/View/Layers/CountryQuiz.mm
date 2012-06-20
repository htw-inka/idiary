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
//  CountryQuiz.mm
//  iDiary2
//
//  Created by Markus Konrad on 09.08.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "CountryQuiz.h"

#import "Config.h"
#import "CommonActions.h"

#pragma mark constants

static NSString *kGroupIdentifier = @"countryquiz"; 

static const NSString *kFileNamePartNote = @"zettel"; 
static const NSString *kFileNamePartBackground = @"hintergrund"; 
static const NSString *kFileNamePartOutline = @"outline"; 
static const NSString *kFileNamePartArea = @"flaeche"; 

#pragma mark CountryQuiz private declarations

@interface CountryQuiz (PrivateMethods)
// called when the game has finished
-(void)gameFinished;

// called when the magnetic distance of a country has been reached
-(void)magneticDistReached:(NSString *)group country:(NSString *)country;

// called when the magnetic distance of a country has been left
-(void)magneticDistLeft:(NSString *)group country:(NSString *)country;

// called when a country has been correctly matched
-(void)objectMatched:(NSString *)group country:(NSString *)country;
@end

#pragma mark CountryQuiz implementation

@implementation CountryQuiz

#pragma mark init/dealloc

-(id)initOnPageLayer:(PageLayer *)layer withImageFilePrefix:(NSString *)prefix {
    self = [super initOnPageLayer:layer withMagneticDistance:kDefaultSnappingDistance targetAreaZBegin:0 arrangableObjectsZBegin:100];
    if (self) {
        // set defaults
        imgFilePrefix = [prefix retain];
        sprites = [[NSMutableDictionary alloc] init];
        
        // load sounds
        scribbleSndId = [sndHandler registerSoundToLoad:@"scribble_1.5sec.mp3" looped:NO gain:kFxSoundVolume]; 
        [sndHandler loadRegisteredSounds];   
        scribbleSnd = [[sndHandler getSound:scribbleSndId] retain];
        
        // add the only group
        TargetGroup *group = [self addGroup:kGroupIdentifier successSound:@"applause1.mp3" successTarget:self successAction:@selector(gameFinished)];
        [group setMagneticDistReachedTarget:self action:@selector(magneticDistReached:country:)];
        [group setMagneticDistLeftTarget:self action:@selector(magneticDistLeft:country:)];
        [group setObjectMatchedTarget:self action:@selector(objectMatched:country:)];
    }
    
    return self;
}

-(void)dealloc {
    [sndHandler unloadSound:scribbleSndId];
    [scribbleSnd release];

    [sprites release];
    [imgFilePrefix release];
    
    [super dealloc];
}

#pragma mark public methods

-(void)addCountry:(NSString *)country notePos:(CGPoint)notePos countryPos:(CGPoint)countryPos {
    [self addCountry:country notePos:notePos countryPos:countryPos useDivergentTargetPos:countryPos];
}

-(void)addCountry:(NSString *)country notePos:(CGPoint)notePos countryPos:(CGPoint)countryPos useDivergentTargetPos:(CGPoint)targetPos {
    // add the target area (the country area)
    NSString *countryBgImg = [NSString stringWithFormat:@"%@%@_%@.png", imgFilePrefix, country, kFileNamePartBackground];
    [self addTargetArea:country targetPoint:targetPos toGroup:kGroupIdentifier image:countryBgImg pos:countryPos];
    
    // add an arrangable object (the note)
    NSString *countryNoteImg = [NSString stringWithFormat:@"%@%@_%@.png", imgFilePrefix, country, kFileNamePartNote];
    [self addArrangableObject:countryNoteImg pos:notePos matchingTo:[NSArray arrayWithObject:country]];
    
    // create the outline sprite
    NSString *countryOutlineImg = [NSString stringWithFormat:@"%@%@_%@.png", imgFilePrefix, country, kFileNamePartOutline];
    CCSprite *countryOutlineSprite = [CCSprite spriteWithFile:countryOutlineImg];
    [countryOutlineSprite setOpacity:0];
    [countryOutlineSprite setPosition:countryPos];
    [self addChild:countryOutlineSprite];

    // create the area progresstimer
    NSString *countryAreaImg = [NSString stringWithFormat:@"%@%@_%@.png", imgFilePrefix, country, kFileNamePartArea];
    CCProgressTimer *countryAreaProgress = [CCProgressTimer progressWithFile:countryAreaImg];
    [countryAreaProgress setType:kCCProgressTimerTypeHorizontalBarLR];
    [countryAreaProgress setPosition:countryPos];    
    [self addChild:countryAreaProgress];
    
    // add the sprites to the sprites dictionary
    NSArray *spriteSet = [NSArray arrayWithObjects:countryOutlineSprite, countryAreaProgress, nil];
    [sprites setObject:spriteSet forKey:country];
}

#pragma mark private methods

-(void)magneticDistReached:(NSString *)group country:(NSString *)country {
    NSLog(@"magnetic distance reached for %@, %@ ", group, country);
    
    // fade in outline
    NSArray *spriteSet = [sprites objectForKey:country];    
    [CommonActions fadeElement:[spriteSet objectAtIndex:kCountrySpriteSetOutline] in:YES];
}

-(void)magneticDistLeft:(NSString *)group country:(NSString *)country {
    NSLog(@"magnetic distance left for %@, %@ ", group, country);
    
    // fade out outline
    NSArray *spriteSet = [sprites objectForKey:country];    
    [CommonActions fadeElement:[spriteSet objectAtIndex:kCountrySpriteSetOutline] in:NO];
    
    // reset progress
    CCProgressTo *progressAction = [CCProgressTo actionWithDuration:0.5f percent:0.0f];
    [[spriteSet objectAtIndex:kCountrySpriteSetArea] runAction:progressAction];    
}

-(void)objectMatched:(NSString *)group country:(NSString *)country {
    NSLog(@"object matched for %@, %@ ", group, country);
    
    // play scribble sound
    [scribbleSnd play];
    
    // show progress like "scribble"
    NSArray *spriteSet = [sprites objectForKey:country];
    CCProgressTo *progressAction = [CCProgressTo actionWithDuration:1.5f percent:100.0f];
    [[spriteSet objectAtIndex:kCountrySpriteSetArea] runAction:progressAction];
}

-(void)gameFinished {
    NSLog(@"game finished");
}

@end
