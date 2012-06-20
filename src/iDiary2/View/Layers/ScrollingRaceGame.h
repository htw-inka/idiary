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
//  ScrollingRaceGame.h
//  iDiary2
//
//  Created by Markus Konrad on 07.02.12.
//  Copyright (c) 2012 INKA Forschungsgruppe. All rights reserved.
//

#import "cocos2d.h"
#import "SoundHandler.h"

@interface ScrollingRaceGameObstacle : NSObject

@property (nonatomic,retain) CCTexture2D *texture;
@property (nonatomic,assign) BOOL isGood;
@property (nonatomic,assign) float minScale;
@property (nonatomic,assign) float maxScale;

@end


@interface ScrollingRaceGameObstacleSprite : CCSprite

@property (nonatomic,assign) ScrollingRaceGameObstacle *spawnedFromObject;
@property (nonatomic,assign) float speedX;
@property (nonatomic,assign) float speedY;

@end

@class PageLayer;

@interface ScrollingRaceGame : CCLayer {
    CGRect dispRect;
    float obstaclePossibility;
    float goodObstaclePossibility;
    
    NSMutableArray *goodObstacles;  // array with objects of type ScrollingRaceGameObstacle with isGood = YES
    NSMutableArray *badObstacles;   // array with objects of type ScrollingRaceGameObstacle with isGood = NO
    
    NSMutableSet *spawnedObstacles; // set with objects of type ScrollingRaceGameObstacleSprite
    
    CCSprite *controlLeft;
    CCSprite *controlRight;
    
    CCSprite *racer;
    CCSprite *racerTail;
    
    BOOL racerIsCrashing;
    
    int lastCollisionObstacleTag;
    
    float aspiredTailAngle;     // angle for the tail to move to
    int movementDirection;      // -1 = left, 0 = no movement, 1 = right
    float movementVelocity;
    
    BOOL isRunning;
    
    ccBlendFunc crashBlendFunc;
    ccBlendFunc originalBlendFunc;
    
    PageLayer *pageLayer; // The parent page the game is added to
    int collisionCount; // counting collisions
    
    //sounds
    SoundHandler *sndHandler;
    int ooohhhhSoundId;
    SoundObject *ooohhhSound;
    int applauseSoundId;
    SoundObject *applauseSound;
}

@property (nonatomic,assign) CGPoint spawnOffset;
@property (nonatomic,assign) id crashCallbackObj;
@property (nonatomic,assign) SEL crashCallbackMethod;

-(id)initOnPageLayer:(PageLayer *)page inRect:(CGRect)rect obstaclesPerSecond:(float)obstaclePsblty goodBadRatio:(float)goodObstaclePsblty;
//-(id)initInRect:(CGRect)rect obstaclesPerSecond:(float)obstaclePsblty goodBadRatio:(float)goodObstaclePsblty;


-(void)setControlsForLeft:(NSString *)ctrlLeftImg pos:(CGPoint)leftPos andRight:(NSString *)ctrlRightImg pos:(CGPoint)rightPos;

-(void)setRacer:(NSString *)racerImg pos:(CGPoint)p;
-(void)setRacerTail:(NSString *)racerTailImg offsetToRacer:(CGPoint)offset;

-(void)setObstacle:(NSString *)obstacleImg good:(BOOL)good minScale:(float)minScale maxScale:(float)maxScale;

-(void)startGame;
-(void)stopGame;

@end
