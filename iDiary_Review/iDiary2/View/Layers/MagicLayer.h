//
//  MagicLayer.h
//  iDiary
//
//  Created by Markus Konrad on 18.04.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"

#import "PageLayer.h"
#import "SoundHandler.h"

// MagicLayer implements a dynamically masked sprite layer.
// It allows you to "rub out" a sprite. This sprite will be masked using a render texture.
@interface MagicLayer : CCLayer {
    PageLayer *pageLayer;
    
	CCRenderTexture *renderTexture; // the render texture in which we draw
    
    CCSprite *maskedSprite;         // the sprite that will be masked using the render texture
	CCSprite *brush;                // the brush to draw into to the render texture
    
    int lastVertRubDirection;       // last vertical rubbing direction
    int lastHoriRubDirection;       // last horizontal rubbing direction
    CFTimeInterval lastRubTime;     // time when the last rub sound was played
    
    int rubSndId;                   // rub sound id
    SoundObject *rubSnd;            // rub sound object
}

@property (nonatomic,assign) CGRect interactionArea;    // interaction is only allowed in this area

// create a new layer with a sprite that can be "rubbed out" using a brush sprite
-(id)initOnPageLayer:(PageLayer *)pPage maskedSprite:(CCSprite *)pMaskedSprite brush:(CCSprite *)pBrush;

-(void)setRubSound:(NSString *)rubSndFile;

-(void)rubFromPos:(CGPoint)start to:(CGPoint)end;

@end
