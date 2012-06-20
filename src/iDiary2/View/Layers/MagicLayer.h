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
