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
//  BoxingLayer.h
//  iDiary2
//
//  Created by Markus Konrad on 18.07.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"

#import "PageLayer.h"
#import "PunchingBag.h"
#import "SoundHandler.h"

#define kPunchingBagMinPunchImpulse 500
#define kPunchingBagMaxPunchImpulse 800
#define kPunchingBagMoveBackDur 0.5
#define kPunchingBagShowPowDur 0.8

@interface BoxingLayer : CCLayer {
    SoundHandler *sndHandler;   // shortcut to SoundHandler
    PageLayer *pageLayer;       // page layer on which this layer resides (weak ref)
    b2World *world;             // box2d physical world
    
    PunchingBag *punchingBag;           // Punching Bag physical sprite
    CCSpriteBatchNode *ropeSpriteSheet; // SpriteSheet for rope
    
    CCSprite *boxingGloves[2];          // boxing gloves for left and right
    CGPoint initialGlovePositions[2];   // boxing gloves' initial position
    CCSprite *activeGlove;              // boxing glove that is currently moved
    int activeGloveIndex;               // index of boxing glove that is currently moved

    NSMutableArray *hitEffectSprites;   // Array of CCSprites for hit effects
    CGRect hitEffectDisplayRect;        // area where the hit effect can appear
    
    BOOL gloveIsMovingBack; // is YES when the glove is moving back to the initial position
    
    int punchSndId;         // punch sound id
    SoundObject *punchSnd;  // punch sound object
}

- (id)initOnPageLayer:(PageLayer *)layer withBox2DWorld:(b2World *)w;

- (void)createPunchingBagFromImage:(NSString *)img ropeImage:(NSString *)ropeImg atPos:(CGPoint)pos hangingFrom:(CGPoint)hangingPos;

- (void)createBoxingGlovesFromImageForLeft:(NSString *)imgLeft pos:(CGPoint)posLeft andRight:(NSString *)imgRight pos:(CGPoint)posRight;

- (void)createHitEffectsFromImages:(NSArray *)imgArray displayableInRect:(CGRect)displayRect;

// update physics
- (void)tick:(ccTime)dt;

@end
