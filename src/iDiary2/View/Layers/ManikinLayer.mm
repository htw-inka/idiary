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
//  ManikinLayer.mm
//  iDiary2
//
//  Created by Markus Konrad on 25.08.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "ManikinLayer.h"

#import "Config.h"
#import "CommonActions.h"

enum {
    kClothesBgMaxZ = 0,
    kManikinZ
};

static int clothesSpriteBgTagCounter = 1;

#pragma mark ---
#pragma mark ArrangableClothes implementation
#pragma mark ---

@implementation ArrangableClothes

@synthesize spriteBg;
@synthesize spriteBgOffset;

-(void)dealloc {
    [spriteBg release];
    
    [super dealloc];
}

#pragma mark public messages

-(void)setSpriteBgOffset:(CGPoint)pSpriteBgOffset {
    spriteBgOffset = pSpriteBgOffset;
    
    // align position to center of the foreground sprite
    CGPoint fgCenter = ccp(sprite.contentSize.width / 2.0f, sprite.contentSize.height / 2.0f);
    CGPoint realOffset = ccpAdd(spriteBgOffset, fgCenter);
    [spriteBg setPosition:realOffset];
}

-(void)setSpriteBg:(CCSprite *)pSpriteBg {
    if (spriteBg == pSpriteBg) return;
    
    [spriteBg release];
    [spriteBg removeFromParentAndCleanup:YES];
    
    spriteBg = [pSpriteBg retain];
    [spriteBg setTag:clothesSpriteBgTagCounter++];
    [sprite addChild:spriteBg z:-1 tag:spriteBg.tag];    // set as child of foreground
}

#pragma mark parent messages

-(void)gotSelected {
    if (matchedTarget) {
        [spriteBg setVisible:YES];
    }
    
    [super gotSelected];
}

@end

#pragma mark ---
#pragma mark ManikinLayer private declarations
#pragma mark ---

@interface ManikinLayer(PrivateMethods)
-(void)clothesMatchedForGroup:(NSString *)groupId target:(NSString *)targetId;
-(void)gameCompleted;
-(void)gameCompletedEndAnim;
-(void)commonInitWithSuccessSnd:(NSString *)successSnd
                  successTarget:(id)successTarget
                         action:(SEL)successAction
                     manikinImg:(NSString *)manikinImg
                            pos:(CGPoint)manikinPos
               objMatchedTarget:(id)objMatchedTarget
                         action:(SEL)objMatchedAction;
@end

#pragma mark ---
#pragma mark ManikinLayer implementation
#pragma mark ---

@implementation ManikinLayer

#pragma mark init/dealloc

-(id)initOnPageLayer:(PageLayer *)pPageLayer withImage:(NSString *)manikinImage atPos:(CGPoint)manikinPos successSound:(NSString *)successSnd {
    self = [super initOnPageLayer:pPageLayer withMagneticDistance:kDefaultSnappingDistance targetAreaZBegin:100 arrangableObjectsZBegin:1000];
    if (self) {        
        [self commonInitWithSuccessSnd:successSnd
                         successTarget:self
                                action:@selector(gameCompleted)
                            manikinImg:manikinImage
                                   pos:manikinPos
                      objMatchedTarget:self
                                action:@selector(clothesMatchedForGroup:target:)];
    }
    
    return self;
}

-(id)  initOnPageLayer:(PageLayer *)pPageLayer
             withImage:(NSString *)manikinImage
                 atPos:(CGPoint)manikinPos
          successSound:(NSString *)successSnd
   gameCompletedTarget:(id)gameCompletedTarget
   gameCompletedAction:(SEL)gameCompletedAction
customObjMatchedTarget:(id)objMatchedTarget
customObjMatchedAction:(SEL)objMatchedAction {
    self = [super initOnPageLayer:pPageLayer withMagneticDistance:kDefaultSnappingDistance targetAreaZBegin:100 arrangableObjectsZBegin:1000];
    if (self) {
        [self commonInitWithSuccessSnd:successSnd
                         successTarget:gameCompletedTarget
                                action:gameCompletedAction
                            manikinImg:manikinImage
                                   pos:manikinPos
                      objMatchedTarget:objMatchedTarget
                                action:objMatchedAction];
    }
    
    return self;
}

-(void)dealloc {
    [startInfoSprite release];
    [completeInfoSprite release];

    [super dealloc];
}

#pragma mark public methods

-(void)setInfoSpriteWithImage:(NSString *)infoImg pos:(CGPoint)infoPos completeImage:(NSString *)completeImg pos:(CGPoint)completePos {
    startInfoSprite = [[CCSprite alloc] initWithFile:infoImg];
    [startInfoSprite setPosition:infoPos];
    [self addChild:startInfoSprite];
    
    completeInfoSprite = [[CCSprite alloc] initWithFile:completeImg];
    [completeInfoSprite setPosition:completePos];
    [completeInfoSprite setScale:0.0f];
    [self addChild:completeInfoSprite];
}

-(void)addBodyPart:(NSString *)bodyPart targetPos:(CGPoint)targetPos {
    [self addTargetArea:bodyPart targetPoint:targetPos toGroup:@"manikin"];
}

-(void)addClothesForBodyPart:(NSString *)bodyPart withImage:(NSString *)imgFile beginPos:(CGPoint)beginPos beginRotation:(CGFloat)beginRot  targetOffset:(CGPoint)targetOffset {
    NSArray *imgFiles = [NSArray arrayWithObject:imgFile];
    [self addClothesForBodyPart:bodyPart withImages:imgFiles beginPos:beginPos beginRotation:beginRot bgOffset:CGPointZero targetOffset:targetOffset];
}

-(void)addClothesForBodyPart:(NSString *)bodyPart withImages:(NSArray *)imgFiles beginPos:(CGPoint)beginPos beginRotation:(CGFloat)beginRot bgOffset:(CGPoint)bgOffset targetOffset:(CGPoint)targetOffset {
    NSArray *target = [NSArray arrayWithObject:bodyPart];
    
    // set foreground and background images
    NSString *fgImg = [imgFiles objectAtIndex:0];
    NSString *bgImg = nil;
    if ([imgFiles count] > 1) { // background really exists
        bgImg = [imgFiles objectAtIndex:1];
    }
    
    // create ArrangableClothes object 
    ArrangableClothes *arrObj = [self addArrangableClothes:fgImg
                                                background:bgImg
                                                       pos:beginPos
                                                  bgOffset:bgOffset
                                                matchingTo:target];
    [arrObj setBeginRot:beginRot];
    [arrObj setTargetOffset:targetOffset];
    
    
}

-(void)addNoMatchConditionForImage1:(NSString *)img1 image2:(NSString *)img2 {
    [self addNoMatchConditionForGroup:@"manikin" image1:img1 image2:img2];
}

-(ArrangableClothes *)addArrangableClothes:(NSString *)fgImg background:(NSString *)bgImg pos:(CGPoint)pos bgOffset:(CGPoint)bgOffset matchingTo:(NSArray *)matchingTargets {
    // create sprites
    CCSprite *spriteFg = [CCSprite spriteWithFile:fgImg];
    CCSprite *spriteBg = nil;
    if (bgImg) {
        spriteBg = [CCSprite spriteWithFile:bgImg];
    }

    // create target area
    ArrangableClothes *newObj = [[ArrangableClothes alloc] initWithIdentifier:fgImg matchingTargets:matchingTargets sprite:spriteFg beginPos:pos];
    [newObj setBeginPos:pos];
    
    if (spriteBg) {
        [newObj setSpriteBg:spriteBg];
        [newObj setSpriteBgOffset:bgOffset];
    }
    
    // add it
    [arrangableObjects addObject:newObj];
    
    if (!pageLayerIsSpriteParent) [self addChild:newObj.sprite z:(arrangableObjectsZ++)];
    else [pageLayer addChild:newObj.sprite z:(arrangableObjectsZ++)];
    
    // also make it "glow" in the page layer
    [pageLayer.interactiveElements addObject:newObj.sprite];
    
    return [newObj autorelease];
}

#pragma mark private methods

-(void)commonInitWithSuccessSnd:(NSString *)successSnd
                  successTarget:(id)successTarget
                         action:(SEL)successAction
                     manikinImg:(NSString *)manikinImg
                            pos:(CGPoint)manikinPos
               objMatchedTarget:(id)objMatchedTarget
                         action:(SEL)objMatchedAction {
    // defaults
    moveObjectsToStartPosOnNoMatch = YES;

    // add group for manikin
    TargetGroup *grp = [self addGroup:@"manikin" successSound:successSnd successTarget:successTarget successAction:successAction];
    [grp setObjectMatchedTarget:objMatchedTarget action:objMatchedAction];
    
    // add image for manikin
    CCSprite *manikinSprite = [CCSprite spriteWithFile:manikinImg];
    [manikinSprite setPosition:manikinPos];
    [self addChild:manikinSprite z:kManikinZ];
}

-(void)clothesMatchedForGroup:(NSString *)groupId target:(NSString *)targetId {
    // find out the clothes that matched
    TargetGroup *grp = [targetGroups objectForKey:groupId];
    ArrangableClothes *clothes = nil;
    for (TargetArea *area in grp.areas) {
        if ([area.identifier isEqualToString:targetId]) {
            clothes = (ArrangableClothes *)area.matchedBy;
        }
    }
    
    NSLog(@"clothes matched: %@", clothes.identifier);
    
    // hide background of the sprite to make it appear behind the manikin
    [clothes.spriteBg setVisible:NO];
}

-(void)gameCompleted {
    CCEaseElasticOut *fadeOut = [CommonActions popupElement:startInfoSprite toScale:0.0f];
    
    CCSequence *seq = [CCSequence actions:fadeOut, [CCHide action], [CCCallFunc actionWithTarget:self selector:@selector(gameCompletedEndAnim)], nil];
    
    [startInfoSprite runAction:seq];
}

-(void)gameCompletedEndAnim {
    CCEaseElasticOut *fadeIn = [CommonActions popupElement:startInfoSprite toScale:1.0f];
    
    CCSequence *seq = [CCSequence actions:[CCShow action], fadeIn, nil];
    
    [completeInfoSprite runAction:seq];
}


@end
