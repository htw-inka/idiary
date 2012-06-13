//
//  HandLayer.h
//  iDiary2
//
//  Created by Andreas Bilke on 07.09.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "ArrangeGameLayer.h"

#import "ManikinLayer.h"

@interface HandLayer : ManikinLayer {

}

-(id)initOnPageLayer:(PageLayer *)pPageLayer withImage:(NSString *)handImage atPos:(CGPoint)handPos successSound:(NSString *)successSnd unsuccessSound:(NSString *)unsuccessSnd;
-(void)setInfoSpriteWithImage:(NSString *)infoImg pos:(CGPoint)infoPos completeImage:(NSString *)completeImg pos:(CGPoint)completePos;

-(void)setHandPart:(CGPoint)ringPos;
-(void)addRingToHand:(NSString *)image beginPos:(CGPoint)beginPos isValid:(BOOL)pIsValid;
-(void)addRingToHand:(NSArray *)images beginPos:(CGPoint)beginPos bgOffset:(CGPoint)bgOffset targetOffset:(CGPoint)targetOffset isValid:(BOOL)pIsValid;
@end
