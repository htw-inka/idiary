//
//  PunchingBag.h
//  iDiary2
//
//  Created by Markus Konrad on 18.07.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//
//  Parts of the code taken from tutorial at http://www.cocos2d-iphone.org/archives/1112
//  by "PatrickC"
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"

#import "PhySprite.h"

//  Defines a physically behaving Punching Bag
//
//  Parts of the code taken from tutorial at http://www.cocos2d-iphone.org/archives/1112
//  by "PatrickC"
//  
@interface PunchingBag : PhySprite {
    b2Body *anchorBody;                 // from where the bag hangs
    CCSpriteBatchNode* ropeSpriteSheet; //sprite sheet for rope segments (weak ref)
    NSMutableArray* vRopes;             //array to hold rope references (VRope Objects)
}

- (id)initWithFile:(NSString *)file ropeSprite:(CCSpriteBatchNode *)ropeSprites atPos:(CGPoint)pos hangingFrom:(CGPoint)hangingPos inWorld:(b2World *)w;

- (void)tick:(ccTime)dt;

- (void)gotHitAt:(CGPoint)p velocity:(float)v angle:(float)a;

@end
