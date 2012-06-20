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
//  Page_Alice_Example6.m
//  iDiary2
//
//  Created by Markus Konrad on 13.06.12.
//  Copyright (c) 2012 INKA Forschungsgruppe. All rights reserved.
//

#import "Page_Alice_Example6.h"

#import "CommonActions.h"

// Define z-orders
enum {
    kGameZ = 100,
    kArrowsZ,
    kBirdZ,
    kTargetHitSpriteZ,
};

static const float kTargetHitSpriteShowTime = 3.0f;

@interface Page_Alice_Example6(Private)
// called when player started to shoot
-(void)playerHasShot;
// called when arrow will be reset
-(void)playerArrowReset;
// called when the bird animation ended
-(void)birdAnimEnded;
// called when the bull eye target has been hit
-(void)bullEyeHit;
// hide the target hit sprite again after it was shown when the target was hit
-(void)targetHitSpriteHide;
@end


@implementation Page_Alice_Example6

#pragma mark init/dealloc

-(id)init {
    self = [super initWithEnabledPhysicsOfType:kB2dWorldTypeNoBorders]; // create page in "phys. world" with no virtual borders
    
    if (self) {
        // setup physics and arrow game
        box2DWorldAttribs->fixedGravity = YES;
        arrowGame = [[ArrowGameLayer alloc] initOnPageLayer:self withBox2DWorld:box2DWorldAttribs->world];
        
        // set te callbacks
        [arrowGame setShootCallbackObj:self];
        [arrowGame setShootCallbackFunc:@selector(playerHasShot)];
        
        [arrowGame setResetArrowCallbackObj:self];
        [arrowGame setResetArrowCallbackFunc:@selector(playerArrowReset)];
        
        // set the arrow
        [arrowGame setArrow:@"alice_example6__pfeil.png" atPos:ccp(231, 305) angle:0.0f withSound:@"arrow_fly.mp3"];
        CGPoint personPos = ccp(141, 269);
        CGPoint armPos = ccp(206, 311);
        [arrowGame setPersonAtPos:personPos body:@"alice_example6__koerper" isAnimated:YES offset:ccp(0,0)
                              arm:@"alice_example6__bogen.png" offset:ccpSub(armPos, personPos) turnPoint:ccp(0.15f, 0.45f)
                              numArrows:kNumArrows];

        // add a target
        [arrowGame addTarget:@"alice_example6__ziel.png" atPos:ccp(817, 320) willStopArrowOnContact:YES
                successSound:@"arrow_hit.mp3" successCallback:@selector(bullEyeHit) onObject:self];
        
        // add the arrow game
        [self addChild:arrowGame z:kGameZ];
        
        // create arrow sprites
        arrowsLeft[0] = [[CCSprite alloc] initWithFile:@"alice_example6__koecher_pfei_1.png"];
        [arrowsLeft[0] setPosition:ccp(157, 768 - 532)];
        [self addChild:arrowsLeft[0] z:kArrowsZ];
        
        arrowsLeft[1] = [[CCSprite alloc] initWithFile:@"alice_example6__koecher_pfei_5.png"];
        [arrowsLeft[1] setPosition:ccp(145, 768 - 526)];
        [self addChild:arrowsLeft[1] z:kArrowsZ];
        
        // create the target hit sprite
        targetHitSprite = [[CCSprite alloc] initWithFile:@"alice_example6__treffer.png"];
        [targetHitSprite setPosition:ccp(630, 569)];
        [targetHitSprite setVisible:NO];
        [targetHitSprite setScale:0.0f];
        
        [self addChild:targetHitSprite z:kTargetHitSpriteZ];
        
        // create the bird animation
        MediaDefinition *birdAnimDef = [MediaDefinition mediaDefinitionWithAnimation:@"alice_example6__vogel" numberOfPlistFiles:1 inRect:CGRectMake(492, 408, 1024, 768)];
        [birdAnimDef setStartDelay:-1];
        birdAnim = [[ContentElement contentElementOnPageLayer:self forMediaDefintion:birdAnimDef] retain];
        [self addChild:birdAnim.displayNode z:kBirdZ];
    }
    
    return self;
} 

-(void)dealloc {
    for (int i = 0; i < kNumArrows - 1; ++i) {
        [arrowsLeft[i] release];
    }

    [targetHitSprite release];
    [arrowGame release];
    [birdAnim release];

    [super dealloc];
}

#pragma mark parent methods

-(void)loadPageContents {
    // set individual properties
    pageBackgroundImg = @"alice_seiten_hintergrund.png";
    
    // text
    MediaDefinition *mDefWelcomeText = [MediaDefinition mediaDefinitionWithText:@"This page shows how to use the ArrowGame class and Sprite Animations."
                                                                           font:@"Courier New"
                                                                       fontSize:18
                                                                          color:ccBLACK
                                                                         inRect:CGRectMake(60, 700, 350, 100)];
    [mediaObjects addObject:mDefWelcomeText];
    
    // tree
    [mediaObjects addObject:[MediaDefinition mediaDefinitionOfType:MEDIA_TYPE_PICTURE withValue:@"alice_example6__baum.png" inRect:CGRectMake(820, 422, 347, 520)]];
    
    // common media objects will be loaded in the PageLayer
    [super loadPageContents];
}

#pragma mark private methods

-(void)playerArrowReset {
    if (numShotArrows < kNumArrows - 1) {
        [CommonActions fadeElement:arrowsLeft[numShotArrows] in:NO];

        numShotArrows++;
    }
}

-(void)playerHasShot {
    [birdAnim startAnimationWithCallbackAtEnd:@selector(birdAnimEnded) atObject:self];
}

-(void)birdAnimEnded {
    [birdAnim startAnimationBackwardsWithCallbackAtEnd:nil atObject:nil];
}

-(void)bullEyeHit {
    [targetHitSprite setVisible:YES];
    CCFiniteTimeAction *popupAction = [CommonActions popupElement:targetHitSprite toScale:1.0f];
    
    CCSequence *seq = [CCSequence actions:popupAction, [CCDelayTime actionWithDuration:kTargetHitSpriteShowTime], [CCCallFunc actionWithTarget:self selector:@selector(targetHitSpriteHide)], nil];
    [targetHitSprite runAction:seq];
}

-(void)targetHitSpriteHide {
    CCFiniteTimeAction *hideAction = [CommonActions popupElement:targetHitSprite toScale:0.0f];
    [targetHitSprite runAction:hideAction];
}


@end
