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
//  HandLayer.m
//  iDiary2
//
//  Created by Andreas Bilke on 07.09.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "HandLayer.h"

#import "Config.h"
#import "CommonActions.h"

enum {
    kClothesBgMaxZ = 0,
    kHandZ,
    kInfoSpriteZ
};

@interface HandLayer(PrivateMethods)
-(void)gameCompleted;
-(void)gameCompletedEndAnim;
@end

@implementation HandLayer
-(id)initOnPageLayer:(PageLayer *)pPageLayer withImage:(NSString *)handImage atPos:(CGPoint)handPos successSound:(NSString *)successSnd unsuccessSound:(NSString *)unsuccessSnd {
    self = [super initOnPageLayer:pPageLayer withMagneticDistance:kDefaultSnappingDistance targetAreaZBegin:100 arrangableObjectsZBegin:1000];
    if (self) {
        // defaults
        moveObjectsToStartPosOnNoMatch = YES;
        
        // add group for manikin
        TargetGroup *grp = [self addGroup:@"hand" successSound:successSnd successTarget:self successAction:@selector(gameCompleted) unsuccessSound:unsuccessSnd];
        [grp setObjectMatchedTarget:self action:@selector(clothesMatchedForGroup:target:)];
        
        // add image for manikin
        CCSprite *handSprite = [CCSprite spriteWithFile:handImage];
        [handSprite setPosition:handPos];
        [self addChild:handSprite z:kHandZ];
    }
    
    return self;
}

-(void)setInfoSpriteWithImage:(NSString *)infoImg pos:(CGPoint)infoPos completeImage:(NSString *)completeImg pos:(CGPoint)completePos {
    startInfoSprite = [[CCSprite alloc] initWithFile:infoImg];
    [startInfoSprite setPosition:infoPos];
    [self addChild:startInfoSprite z:kInfoSpriteZ];
    
    completeInfoSprite = [[CCSprite alloc] initWithFile:completeImg];
    [completeInfoSprite setPosition:completePos];
    [completeInfoSprite setScale:0.0f];
    [self addChild:completeInfoSprite z:kInfoSpriteZ];
}

-(void)setHandPart:(CGPoint)ringPos {
    [self addTargetArea:@"ring" targetPoint:ringPos toGroup:@"hand"];
}

-(void)addRingToHand:(NSString *)image beginPos:(CGPoint)beginPos isValid:(BOOL)pIsValid {
    NSArray *target = [NSArray arrayWithObject:@"ring"];
    
    [self addArrangableObject:image pos:beginPos matchingTo:target isValid:pIsValid];
}

-(void)addRingToHand:(NSArray *)images beginPos:(CGPoint)beginPos bgOffset:(CGPoint)bgOffset targetOffset:(CGPoint)targetOffset isValid:(BOOL)pIsValid {
    NSArray *target = [NSArray arrayWithObject:@"ring"];
    
    // set foreground and background images
    NSString *fgImg = [images objectAtIndex:0];
    NSString *bgImg = nil;
    if ([images count] > 1) { // background really exists
        bgImg = [images objectAtIndex:1];
    }
    
    // create ArrangableClothes object 
    ArrangableClothes *arrObj = [self addArrangableClothes:fgImg
                                                background:bgImg
                                                       pos:beginPos
                                                  bgOffset:bgOffset
                                                matchingTo:target];
    
    [arrObj setTargetOffset:targetOffset];
    arrObj.isValid = pIsValid;
    
}

-(void)gameCompleted {
    CCEaseElasticOut *fadeOut = [CommonActions popupElement:startInfoSprite toScale:0.0f];
    
    CCSequence *seq = [CCSequence actions:fadeOut, [CCHide action], [CCCallFunc actionWithTarget:self selector:@selector(gameCompletedEndAnim)], nil];
    
    self.isActive = NO;
    
    [startInfoSprite runAction:seq];
}

-(void)gameCompletedEndAnim {
    CCEaseElasticOut *fadeIn = [CommonActions popupElement:startInfoSprite toScale:1.0f];
    
    CCSequence *seq = [CCSequence actions:[CCShow action], fadeIn, nil];
    
    [completeInfoSprite runAction:seq];
}
@end
