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
