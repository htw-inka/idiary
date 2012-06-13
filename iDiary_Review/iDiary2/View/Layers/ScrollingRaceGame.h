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
