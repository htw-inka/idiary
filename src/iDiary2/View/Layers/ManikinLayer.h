//
//  ManikinLayer.h
//  iDiary2
//
//  Created by Markus Konrad on 25.08.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "ArrangeGameLayer.h"

#import "PageLayer.h"

static NSString *kManikinBodyPartHead = @"head";
static NSString *kManikinBodyPartBody = @"body";
static NSString *kManikinBodyPartHand = @"hand";

// ArrangableClothes is a special ArrangeableObject with foreground and background sprite
@interface ArrangableClothes : ArrangeableObject {
//    CCNode *node;   // this node will be added to the node-tree. it contains the foreground and background sprites
    
    CCSprite *spriteBg;     // background sprite
    CGPoint spriteBgOffset; // pixel offset of the background sprite in relation to the foreground sprite's position
}

@property (nonatomic,retain) CCSprite *spriteBg;
@property (nonatomic,assign) CGPoint spriteBgOffset;

@end


// ManikinLayer implements an ArrangeGame for dragging clothes on body parts of a manikin.
@interface ManikinLayer : ArrangeGameLayer {
    CCSprite *startInfoSprite;      // sprite that is shown at the beginning
    CCSprite *completeInfoSprite;   // sprite that will be shown when the game is completed
}

// create a new manikin layer with a manikin image at a position
-(id)initOnPageLayer:(PageLayer *)pPageLayer withImage:(NSString *)manikinImage atPos:(CGPoint)manikinPos successSound:(NSString *)successSnd;

// create a new manikin layer with custom behaviour callbacks
-(id)  initOnPageLayer:(PageLayer *)pPageLayer
             withImage:(NSString *)manikinImage
                 atPos:(CGPoint)manikinPos
          successSound:(NSString *)successSnd
   gameCompletedTarget:(id)gameCompletedTarget
   gameCompletedAction:(SEL)gameCompletedAction
customObjMatchedTarget:(id)objMatchedTarget
customObjMatchedAction:(SEL)objMatchedAction;

// set the images for the info-sprite and the "game completed!"-sprite
-(void)setInfoSpriteWithImage:(NSString *)infoImg pos:(CGPoint)infoPos completeImage:(NSString *)completeImg pos:(CGPoint)completePos;

// add a body part (one of kManikinBodyPart*) with a target area position
-(void)addBodyPart:(NSString *)bodyPart targetPos:(CGPoint)targetPos;

// add new clothes for a body part (one of kManikinBodyPart*)
-(void)addClothesForBodyPart:(NSString *)bodyPart withImage:(NSString *)imgFile beginPos:(CGPoint)beginPos beginRotation:(CGFloat)beginRot targetOffset:(CGPoint)targetOffset;

// add clothes that consist of two part-images
// NSArray imgFiles contains NSStrings with 1. foreground and 2. background image file-name
-(void)addClothesForBodyPart:(NSString *)bodyPart withImages:(NSArray *)imgFiles beginPos:(CGPoint)beginPos beginRotation:(CGFloat)beginRot bgOffset:(CGPoint)bgOffset targetOffset:(CGPoint)targetOffset;

// add a condition that says that the manikin cannot wear image1 and image2 at the same time
-(void)addNoMatchConditionForImage1:(NSString *)img1 image2:(NSString *)img2;

// Create a new ArrangableClothes object
-(ArrangableClothes *)addArrangableClothes:(NSString *)fgImg background:(NSString *)bgImg pos:(CGPoint)pos bgOffset:(CGPoint)bgOffset matchingTo:(NSArray *)matchingTargets;

@end
