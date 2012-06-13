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
