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
//  PhotoQuizLayer.h
//  iDiary2
//
//  Created by Erik Lippmann on 30.01.12.
//  Copyright 2012 INKA Forschungsgruppe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "ArrangeGameLayer.h"
#import "SoundHandler.h"

enum {
    kPhotoSpriteBackground = 0,
    kPhotoSpriteMoveable,
    kPhotoSpriteFinal,
    kPhotoSpriteCorners,
    kPhotoSpriteDone
};
    
    
@interface PhotoQuizLayer : ArrangeGameLayer {

    NSMutableDictionary *photos; // Dictionary with NSString age -> NSArray sprite set mapping 
    NSMutableArray *spriteSetKeys; // keep track of added keys
    NSString *imageFilePrefix;
    NSString *photoFilePostfix;
    NSString *targetFilePostfix;
    PageLayer *parentLayer;
    
    int chimeSoundId;
    SoundObject *chimeSound;
    
    int successSoundId;
    SoundObject *successSound;
    
    int oopsSoundId;
    SoundObject *oopsSound;
    
    float kScaleFactor;
    float kScaleDuration;
    
    CCSprite *activeSprite;
    CCSprite *activeTarget;
    CCSprite *activeTargetSprite;
    
    NSString *currentHighlightedTarget;
    NSString *activeSpriteSetKey;
    
    int finishedPhotos;
}

// init the photo quiz game with a prefix for the images and the target images
- (id)initOnPageLayer:(PageLayer *)layer withImageFilePrefix:(NSString *)imagePrefix photoFilePostfix:(NSString *)photo andTagetFilePostfix:(NSString *)target;

// add a new photo from a certain age with the its initial position and the position of the target
- (void)addPhotoForAge:(NSString *)age atPosition:(CGPoint)photoPosition targetPosition:(CGPoint)targetPosition andCornersPosition:(CGPoint)cornersPosition;

@end
