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
