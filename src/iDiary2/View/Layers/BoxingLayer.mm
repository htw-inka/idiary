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
//  BoxingLayer.mm
//  iDiary2
//
//  Created by Markus Konrad on 18.07.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "BoxingLayer.h"

#import "Tools.h"
#import "Config.h"
#import "CommonActions.h"

// define z-orders:
enum {
    kPunchingBagZ = 0,
    kBoxingGlovesZ,
    kPowZ
};

@interface BoxingLayer (PrivateMethods)
// make a hit
// make a punch sound and "popup" graphics
-(void)doPunchAtHitPoint:(CGPoint)hitPoint;

// start animation to move the active glove back to the initial position
-(void)moveActiveGloveBackToInitialPosition;

// reset glove defaults after moving it back
-(void)resetGloveDefaults;
@end

@implementation BoxingLayer

#pragma mark init/dealloc

- (id)initOnPageLayer:(PageLayer *)layer withBox2DWorld:(b2World *)w {
    self = [super init];
    if (self) {
        // init random
        srand(time(NULL));
    
        // set defaults
        pageLayer = layer;
        world = w;
        activeGloveIndex = -1;
        
        // load sounds
        sndHandler = [SoundHandler shared];
        punchSndId = [sndHandler registerSoundToLoad:@"punch.mp3" looped:NO gain:kFxSoundVolume];
        [sndHandler loadRegisteredSounds];
        punchSnd = [[sndHandler getSound:punchSndId] retain];
        
        // setup touches for the layer
        [self setIsTouchEnabled:YES];
    }
    return self;
}

- (void)dealloc {
    // sounds
    [punchSnd release];
    [sndHandler unloadSound:punchSndId];

    // sprites
    [ropeSpriteSheet release];
    [punchingBag release];
    
    for (int i = 0; i < 2; i++) {
        [boxingGloves[i] release];
    }
    
    // other
    [hitEffectSprites release];
    
    [super dealloc];
}

#pragma mark public methods

- (void)createPunchingBagFromImage:(NSString *)img ropeImage:(NSString *)ropeImg atPos:(CGPoint)pos hangingFrom:(CGPoint)hangingPos {    
    // create the rope
    [ropeSpriteSheet removeFromParentAndCleanup:YES];
    [ropeSpriteSheet release];
    ropeSpriteSheet = [[CCSpriteBatchNode batchNodeWithFile:ropeImg] retain];
    [self addChild:ropeSpriteSheet];
    
    // create the punching bag
    [punchingBag removeFromParentAndCleanup:YES];
    [punchingBag release];
    punchingBag = [[PunchingBag alloc] initWithFile:img ropeSprite:ropeSpriteSheet atPos:pos hangingFrom:hangingPos inWorld:world];
    
    // add it to the layer
    [self addChild:punchingBag z:kPunchingBagZ];
}

- (void)createBoxingGlovesFromImageForLeft:(NSString *)imgLeft pos:(CGPoint)posLeft andRight:(NSString *)imgRight pos:(CGPoint)posRight {
    for (int i = 0; i < 2; i++) {
        [boxingGloves[i] release];
    }
    
    // left glove
    boxingGloves[0] = [[CCSprite alloc] initWithFile:imgLeft];
    [boxingGloves[0] setPosition:posLeft];
    initialGlovePositions[0] = posLeft;
    [self addChild:boxingGloves[0] z:kBoxingGlovesZ];
    [pageLayer.interactiveElements addObject:boxingGloves[0]];
    
    // right glove
    boxingGloves[1] = [[CCSprite alloc] initWithFile:imgRight];
    [boxingGloves[1] setPosition:posRight];
    initialGlovePositions[1] = posRight;
    [self addChild:boxingGloves[1] z:kBoxingGlovesZ];
    [pageLayer.interactiveElements addObject:boxingGloves[1]];
}

- (void)createHitEffectsFromImages:(NSArray *)imgArray displayableInRect:(CGRect)displayRect {
    [hitEffectSprites release];
    
    // create array with hit effect sprites
    hitEffectSprites = [[NSMutableArray alloc] initWithCapacity:[imgArray count]];
    int i = 0;
    for (NSString *img in imgArray) {
        CCSprite *hitEffect = [CCSprite spriteWithFile:img];
        [hitEffect setVisible:NO];
        [self addChild:hitEffect z:kPowZ + i];
        
        [hitEffectSprites addObject:hitEffect];
        
        i++;
    }
    
    hitEffectDisplayRect = displayRect;
}

- (void)tick:(ccTime)dt {
	[punchingBag tick:dt];
}

#pragma mark touch handling

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (gloveIsMovingBack) return;

    UITouch *touch = [touches anyObject];
    
    // check if a boxing glove is hit
    for (int i = 0; i < 2; i++) {
        if ([Tools touch:touch isInNode:boxingGloves[i]]) {
            activeGlove = boxingGloves[i];
            activeGloveIndex = i;
            
            [[CoreHolder sharedCoreHolder] setInteractiveObjectWasTouched:YES];
        }
    }
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (activeGlove == nil) return;
    
    UITouch *touch = [touches anyObject];
    CGPoint pos = [Tools convertTouchToGLPoint:touch];
    
    // move the glove if not moving back:
    if (!gloveIsMovingBack) {
        [activeGlove setPosition:pos];
        
        NSValue *hitPoint = [Tools hitPointInNode:punchingBag forPoint:pos];
        if (hitPoint) {
            [self doPunchAtHitPoint:[hitPoint CGPointValue]];
        }
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (activeGloveIndex < 0) return;
        
    [self moveActiveGloveBackToInitialPosition];
}

#pragma mark private methods

-(void)doPunchAtHitPoint:(CGPoint)hitPoint {
    if (activeGloveIndex < 0) return;

    // hit the punching bag
    float punchDirection = ccpToAngle(ccpSub(activeGlove.position, initialGlovePositions[activeGloveIndex]));
    
//    NSLog(@"Punch direction: %f", CC_RADIANS_TO_DEGREES(punchDirection));
    
    [punchingBag gotHitAt:hitPoint
                 velocity:CCRANDOM_0_1() * (kPunchingBagMaxPunchImpulse - kPunchingBagMinPunchImpulse) + kPunchingBagMinPunchImpulse
                    angle:punchDirection];
                    
    // make a sound
    [punchSnd playAtPitch:1.0f + CCRANDOM_MINUS1_1() * 0.5f];                
    
    // show a hit effect
    if ([hitEffectSprites count] > 0) {
        int randHitEffectIdx = (int)(CCRANDOM_0_1() * 100) % [hitEffectSprites count];
        CCSprite *hitEffect = [hitEffectSprites objectAtIndex:randHitEffectIdx];
        
        [hitEffect setVisible:YES];
        [hitEffect setScale:0.01f];
        
        CGFloat randX = hitEffectDisplayRect.origin.x + CCRANDOM_0_1() * hitEffectDisplayRect.size.width;
        CGFloat randY = hitEffectDisplayRect.origin.y + CCRANDOM_0_1() * hitEffectDisplayRect.size.height;
        [hitEffect setPosition:ccp(randX, randY)];

        [hitEffect runAction:[CommonActions popupElement:hitEffect toScale:1.0f]];    
        
        // hide the effect later
        CCFiniteTimeAction *disappearPowAction = [CommonActions popupElement:hitEffect toScale:0.01f];
        CCSequence *disappearPowSeq = [CCSequence actions:disappearPowAction, [CCHide action], nil];
        [hitEffect performSelector:@selector(runAction:) withObject:disappearPowSeq afterDelay:kPunchingBagShowPowDur];
    }

    // make an animation to move the active glove back to its initial position
    [self moveActiveGloveBackToInitialPosition];
}

-(void)moveActiveGloveBackToInitialPosition {
    if (!activeGlove) return;
    
    gloveIsMovingBack = YES;
    
    CCMoveTo *moveAction = [CCMoveTo actionWithDuration:kPunchingBagMoveBackDur position:initialGlovePositions[activeGloveIndex]];
    CCEaseElasticOut *moveActionEased = [CCEaseElasticOut actionWithAction:moveAction];
    CCSequence *moveSeq = [CCSequence actions:moveActionEased, [CCCallFunc actionWithTarget:self selector:@selector(resetGloveDefaults)], nil];
    
    [activeGlove runAction:moveSeq];
}

-(void)resetGloveDefaults {
    gloveIsMovingBack = NO;
    activeGlove = nil;
    activeGloveIndex = -1;
}

@end
