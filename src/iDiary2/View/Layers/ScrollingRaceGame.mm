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
//  ScrollingRaceGame.m
//  iDiary2
//
//  Created by Markus Konrad on 07.02.12.
//  Copyright (c) 2012 INKA Forschungsgruppe. All rights reserved.
//


#import "ScrollingRaceGame.h"

#import "Tools.h"
#import "Makros.h"
#import "ShakeAction.h"
#import "CoreHolder.h"
#import "Config.h"


enum {
    kRacerTailZ = 1,
    kRacerZ,
    kObstacleZ,
    kControlsZ,
};

static const int kTailRotateActionTag = 42;
static const float kTailRotateDur = 1.0f;
static const float kTailRotateAngle = 25.0f;

static const float kUpdateGameInterval = 1.0f/12.0f;

static const float kMovementVelocityMin = 5.0f;
static const float kMovementVelocityStep = 1.0f;
static const float kMovementVelocityMax = 15.0f;

static const float kObstacleSpeedYMin = 5.0f;
static const float kObstacleSpeedYMax = 15.0f;
static const float kObstacleSpeedXMax = 3.0f;
static const float kObstacleXDirectionChangePerSecPossiblity = 0.1 * kUpdateGameInterval;

static const float kSmallerBBFactor = 0.75f;

static const float kCrashAnimDur = 2.0f;
static const float kCrashRotateDur = 0.75f;
static const float kCrashBlendFuncChangePerSecPossibility = 4.0f * kUpdateGameInterval;

static const int kMaxCollision = 3; // set the maximum number of collisions/crashes here
static const float kFlyAwayDur = 3.0f;
static const int kFlyAwayX = 1024;
static const int kFlyAwayY = 768;
static const float kMaxGameTime = 120.0f; // the time the game will run at max
Boolean gameIsOver = false;

static int obstacleSpriteTagNum = 0;

@implementation ScrollingRaceGameObstacle

@synthesize texture;
@synthesize isGood;
@synthesize minScale;
@synthesize maxScale;

-(void)dealloc {
    [texture release];
    
    [super dealloc];
}

@end

@implementation ScrollingRaceGameObstacleSprite

@synthesize spawnedFromObject;
@synthesize speedX;
@synthesize speedY;

@end

@interface ScrollingRaceGame(PrivateMethods)
-(void)updateGame:(ccTime)dt;
-(void)startCrashAnimation;
-(void)crashAnimEnded;
-(void)rotateTailInDirection:(int)dir;
-(void)gameOver;
@end

@implementation ScrollingRaceGame

@synthesize spawnOffset;
@synthesize crashCallbackObj;
@synthesize crashCallbackMethod;

#pragma mark init / dealloc

-(id)initOnPageLayer:(PageLayer *)page inRect:(CGRect)rect obstaclesPerSecond:(float)obstaclePsblty goodBadRatio:(float)goodObstaclePsblty {
    self = [super init];
    
    if (self) {
        // random seed
        srand(time(NULL));
    
        // set defaults
        dispRect = rect;
        obstaclePossibility = obstaclePsblty * kUpdateGameInterval;
        goodObstaclePossibility = goodObstaclePsblty;
        isRunning = NO;
        racerIsCrashing = NO;
        lastCollisionObstacleTag = -1;
        spawnOffset = CGPointZero;
        crashBlendFunc = (ccBlendFunc){GL_ONE, GL_ONE};
        
        pageLayer = page;
        // create the timer for the end of the game
        [self performSelector:@selector(gameOver) withObject:nil afterDelay:kMaxGameTime];
        [self setIsTouchEnabled:YES];
        
        sndHandler = [SoundHandler shared];
        // load sounds
        applauseSoundId = [sndHandler registerSoundToLoad:@"applause2.mp3" looped:NO gain:kFxSoundVolume];
        ooohhhhSoundId = [sndHandler registerSoundToLoad:@"epic_fail.mp3" looped:NO gain:kFxSoundVolume];
        [sndHandler loadRegisteredSounds];
        
        applauseSound = [[sndHandler getSound:applauseSoundId] retain];
        ooohhhSound = [[sndHandler getSound:ooohhhhSoundId] retain];
        
        // create objects
        goodObstacles = [[NSMutableArray alloc] init];
        badObstacles = [[NSMutableArray alloc] init];
        
        spawnedObstacles = [[NSMutableSet alloc] init];
    }

    return self;
}

-(void)dealloc {
    [goodObstacles release];
    [badObstacles release];
    
    [spawnedObstacles release];
    
    [controlLeft release];
    [controlRight release];
    
    [racer release];
    [racerTail release];
    
    [sndHandler unloadSound:applauseSoundId];
    [applauseSound release];
    [sndHandler unloadSound:ooohhhhSoundId];
    [ooohhhSound release];

    [super dealloc];
}

#pragma mark public methods

-(void)startGame {
    if (isRunning) return;

    // set update method
    [self schedule:@selector(updateGame:) interval:kUpdateGameInterval];
    
    isRunning = YES;
}

-(void)stopGame {
    if (!isRunning) return;

    // set update method
    [self unschedule:@selector(updateGame:)];
    
    isRunning = NO;
}

-(void)setControlsForLeft:(NSString *)ctrlLeftImg pos:(CGPoint)leftPos andRight:(NSString *)ctrlRightImg pos:(CGPoint)rightPos {
    [controlLeft removeFromParentAndCleanup:YES];
    [controlLeft release];
    [controlRight removeFromParentAndCleanup:YES];
    [controlRight release];
    
    controlLeft = [[CCSprite alloc] initWithFile:ctrlLeftImg];
    [controlLeft setPosition:leftPos];
    [self addChild:controlLeft z:kControlsZ];
    
    controlRight = [[CCSprite alloc] initWithFile:ctrlRightImg];
    [controlRight setPosition:rightPos];
    [self addChild:controlRight z:kControlsZ];
}

-(void)setRacer:(NSString *)racerImg pos:(CGPoint)p {
    [racer removeFromParentAndCleanup:YES];
    [racer release];
    
    racer = [[CCSprite alloc] initWithFile:racerImg];
    [racer setPosition:p];
    [self addChild:racer z:kRacerZ];
}

-(void)setRacerTail:(NSString *)racerTailImg offsetToRacer:(CGPoint)offset {
    [racerTail removeFromParentAndCleanup:YES];
    [racerTail release];
    
    racerTail = [[CCSprite alloc] initWithFile:racerTailImg];
    [racerTail setAnchorPoint:ccp(0.5f, 0.0f)];
    [racerTail setPosition:offset];
    [racer addChild:racerTail z:-1];
}

-(void)setObstacle:(NSString *)obstacleImg good:(BOOL)good minScale:(float)minScale maxScale:(float)maxScale {
    ScrollingRaceGameObstacle *obstacle = [[[ScrollingRaceGameObstacle alloc] init] autorelease];
    
    [obstacle setTexture:[[CCTextureCache sharedTextureCache] addImage:obstacleImg]];
    [obstacle setIsGood:good];
    [obstacle setMinScale:minScale];
    [obstacle setMaxScale:maxScale];
    
    NSMutableArray *arr = (good ? goodObstacles : badObstacles);
    [arr addObject:obstacle];
}

#pragma mark touch handling

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!isRunning || racerIsCrashing) return;

    UITouch *touch = [touches anyObject];
    
    if ([Tools touch:touch isInNode:controlLeft]) {
        movementDirection = -1;
        
        if (racerTail) {
            [self rotateTailInDirection:movementDirection];
        }
    } else if ([Tools touch:touch isInNode:controlRight]) {
        movementDirection = 1;
        
        if (racerTail) {
            [self rotateTailInDirection:movementDirection];
        }
    }
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!isRunning) return;

    movementDirection = 0;
    movementVelocity = kMovementVelocityMin;
    
    if (racerTail && !racerIsCrashing) {
        [self rotateTailInDirection:movementDirection];
    }
}


#pragma mark private methods

-(void)updateGame:(ccTime)dt {
    if (!isRunning) return;
    
    // crash animation -> change blendfunc
    if (racerIsCrashing && CCRANDOM_0_1() <= kCrashBlendFuncChangePerSecPossibility) {
        if (racer.blendFunc.src == crashBlendFunc.src && racer.blendFunc.dst == crashBlendFunc.dst) {
            [racer setBlendFunc:originalBlendFunc];
            [racerTail setBlendFunc:originalBlendFunc];
        } else {
            [racer setBlendFunc:crashBlendFunc];       
            [racerTail setBlendFunc:crashBlendFunc]; 
        }
    }

    // update player position
    if (movementDirection != 0) {
        CGPoint pos = racer.position;
        pos.x += (float)movementDirection * movementVelocity;
        [racer setPosition:pos];
        
        // increace velocity
        movementVelocity = MIN(movementVelocity + kMovementVelocityStep, kMovementVelocityMax);
    }
    
    // update obstacles
    NSMutableArray *spritesToRemove = [NSMutableArray array];
    for (ScrollingRaceGameObstacleSprite *sprite in spawnedObstacles) {
        // maybe update x direction
        if (CCRANDOM_0_1() <= kObstacleXDirectionChangePerSecPossiblity) {
            sprite.speedX *= -1.0f;
        }
        
        // update position
        CGPoint pos = sprite.position;
        pos.x += sprite.speedX;
        pos.y += sprite.speedY;
        [sprite setPosition:pos];
        
        // get the bounding box
        CGRect bb = [sprite boundingBox];
        
        // calculate a little smaller bounding box for better collision results
        CGFloat smallerBBW = bb.size.width * kSmallerBBFactor;
        CGFloat smallerBBH = bb.size.height * kSmallerBBFactor;
        CGFloat smallerBBX = bb.origin.x + (bb.size.width - smallerBBW) / 2.0f;
        CGFloat smallerBBY = bb.origin.y + (bb.size.height - smallerBBH) / 2.0f;
        CGRect smallerBB = CGRectMake(smallerBBX, smallerBBY, smallerBBW, smallerBBH);
        
        // check if it is completly out of the dispRect
        if (bb.origin.y >= dispRect.origin.y + dispRect.size.width) {
            [spritesToRemove addObject:sprite]; // add it to an array to remove this sprite later
        } else {    // check if we have a collision
            if (lastCollisionObstacleTag != sprite.tag
            && !racerIsCrashing
            && !sprite.spawnedFromObject.isGood
            && CGRectIntersectsRect(smallerBB, [racer boundingBox])) {
                NSLog(@"Collision with obstacle sprite #%d", sprite.tag);
                lastCollisionObstacleTag = sprite.tag;
                
                [self startCrashAnimation];
            }
        }
    }
    
    // remove already invisble obstacles
    for (CCSprite *obj in spritesToRemove) {
        NSLog(@"removed obstacle sprite #%d", obj.tag);
        
        [obj removeFromParentAndCleanup:YES];
        [spawnedObstacles removeObject:obj];
    }
    
    // spawn obstacles
    if (CCRANDOM_0_1() <= obstaclePossibility) {
        // get random obstacle
        NSArray *spawnArray = (CCRANDOM_0_1() <= goodObstaclePossibility) ? goodObstacles : badObstacles;
        int arrayCount = [spawnArray count];
        int randIdx =  (arrayCount > 1) ? (int)RAND_MIN_MAX(0, arrayCount - 1) : 0;
        ScrollingRaceGameObstacle *obstacle = [spawnArray objectAtIndex:randIdx];
        
        // set sprite rect
        CGRect spriteRect;
        spriteRect.origin = CGPointZero;
        spriteRect.size = [obstacle.texture contentSize];
        
        // create obstacle sprite
        ScrollingRaceGameObstacleSprite *sprite = [ScrollingRaceGameObstacleSprite spriteWithTexture:obstacle.texture rect:spriteRect];
        [sprite setTag:(++obstacleSpriteTagNum)];
        [sprite setSpawnedFromObject:obstacle];
        
        NSLog(@"spawned obstacle sprite #%d", sprite.tag);
        
        // set speed
        [sprite setSpeedX:RAND_MIN_MAX(-kObstacleSpeedXMax, kObstacleSpeedXMax)];
        [sprite setSpeedY:RAND_MIN_MAX(kObstacleSpeedYMin, kObstacleSpeedYMax)];
        
        // set scale
        [sprite setScale:RAND_MIN_MAX(obstacle.minScale, obstacle.maxScale)];
        
        // set position
        CGRect bb = [sprite boundingBox];
        float minX = dispRect.origin.x + bb.size.width / 2.0f;
        float maxX = dispRect.origin.x + dispRect.size. width - bb.size.width / 2.0f;
        float spawnY = dispRect.origin.y + bb.size.height / 2.0f;
        CGPoint spawnPos = ccpAdd(spawnOffset, ccp(RAND_MIN_MAX(minX, maxX), spawnY));
        [sprite setPosition:spawnPos];
        
        // add obstacle sprite
        [spawnedObstacles addObject:sprite];
        [self addChild:sprite z:kObstacleZ];
    }
    
    if (collisionCount >= kMaxCollision && !gameIsOver) {
        gameIsOver = true;
        if (racerIsCrashing) [self performSelector:@selector(gameOver) withObject:nil afterDelay:kCrashAnimDur];
        else [self performSelector:@selector(gameOver)];
    }
}

-(void)gameOver {
    [racerTail stopActionByTag:kTailRotateActionTag];

    id flyAway = [CCMoveTo actionWithDuration: kFlyAwayDur position:CGPointMake(kFlyAwayX, kFlyAwayY)];
    id shrink = [CCScaleTo actionWithDuration: kFlyAwayDur scale:0.0f];
    id playSnd = [CCCallFuncN actionWithTarget:self selector:@selector(playGameOverSnd)];
    id flyAwayAndShrink = [CCSpawn actions:flyAway, shrink, playSnd, nil];
    id turnPage = [CCCallFuncN actionWithTarget:self selector:@selector(turnPage)];
    CCSequence *gameOver = [CCSequence actions:flyAwayAndShrink, turnPage, nil];    
     
    [racer runAction:gameOver];
}

-(void)playGameOverSnd {
    if (collisionCount == kMaxCollision) {
        [ooohhhSound play];
        CCLOG(@"Looooser!");
    }
    else {
        [applauseSound play];
        CCLOG(@"Winning!");
    }
}

-(void)turnPage {
    [[pageLayer core] showNextPage:nil];
}

-(void)rotateTailInDirection:(int)dir {
    // stop tail rotation that was scheduled before
    [racerTail stopActionByTag:kTailRotateActionTag];

    // rotate AGAINST the direction for "tail movement"
    CCRotateTo *rotateAction = [CCRotateTo actionWithDuration:kTailRotateDur angle:-movementDirection * kTailRotateAngle];
    [rotateAction setTag:kTailRotateActionTag];
    [racerTail runAction:rotateAction];
}

-(void)startCrashAnimation {
    // call a callback
    if (crashCallbackObj && crashCallbackMethod) {
        [crashCallbackObj performSelector:crashCallbackMethod];
    }

    // start crashing
    racerIsCrashing = YES;
    
    originalBlendFunc = racer.blendFunc;
    
    [racer setBlendFunc:crashBlendFunc];
    [racerTail setBlendFunc:crashBlendFunc];
        
    CCRotateBy *racerRotate = [CCRotateBy actionWithDuration:kCrashRotateDur angle:360.0f];
    ShakeAction *racerShake = [ShakeAction actionWithDuration:kCrashRotateDur position:ccp(10.0f, 10.0f) angle:10.0f rate:10];
    CCSequence *seq = [CCSequence actions:racerRotate, racerShake, nil];
    [racer runAction:seq];
    
    collisionCount++; // add up one collision to the counter
    [self performSelector:@selector(crashAnimEnded) withObject:nil afterDelay:kCrashAnimDur];
}

-(void)crashAnimEnded {
    racerIsCrashing = NO;
    
    [racer setBlendFunc:originalBlendFunc];
    [racerTail setBlendFunc:originalBlendFunc];
    
    [self rotateTailInDirection:0];
}

@end
