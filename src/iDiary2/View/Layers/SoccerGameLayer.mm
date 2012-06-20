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
//  SoccerGameLayer.m
//  iDiary2
//
//  Created by Markus Konrad on 29.06.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "SoccerGameLayer.h"

#import "CoreHolder.h"
#import "ContentElement.h"
#import "Tools.h"
#import "CommonActions.h"

// constants

// z order of sprites
enum {
    kSpriteGoalZ = 0,
    kSpriteKeeperZ,
    kSpriteBallZ,
    kSpriteBeginPhraseZ
};

// Private method declarations
@interface SoccerGameLayer(PrivateMethods)

// update ball position and movement, consider collisions
-(void)updateBall:(ccTime)dt;

// start the next game round
-(void)nextGameRound;

// reset some values after touches ended
-(void)resetMoveAccelValues;

// set the ball to the initial position
-(void)resetBallForNewRound;

// neverending keeper movement
-(void)keeperReturn;

@end


@implementation SoccerGameLayer

static const CFTimeInterval kBallShootInterval = kSoccerGameBallShootInterval;   // maximum time interval between shoot gesture begin and end
static const CGFloat kKeeperHeight = 20.0f;

@synthesize ball;
@synthesize pageTurnAtGameEnd;

#pragma mark init/dealloc

-(id)initOnPageLayer:(PageLayer *)layer withSoccerFieldDimensions:(CGRect)fieldDim {
    self = [super init];
    if (self) {
        // set defaults
        pageTurnAtGameEnd = NO;
        
        pageLayer = layer;
        
        sndHandler = [SoundHandler shared];
        successSndId = -1;
        
        lastAddedPhraseIndex = 0;
        isInteractionEnabled = NO;
        isBallInGoal = NO;
        keeperShallMove = NO;
        
        keeperMovesToRight = YES;
        numShotBalls = 0;
        numMaxBalls = kSoccerGameNumBalls;
        
        ballInfoDispSprites = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < kSoccerGameNumBalls; i++) {
            numBallSprites[i] = nil;
        }
        
        for (int i = 0; i < kSoccerGameNumBalls; i++) {
            [phraseSprites[i] release];
        }
        
        // ball sounds
        for (int i = 0; i < kBallSoundNum; i++) {
            ballSndId[i] = -1;
            ballSnd[i] = nil;
        }
        
        // create field bounds
        fieldLeftX = fieldDim.origin.x;
        fieldRightX = fieldDim.origin.x + fieldDim.size.width;
        fieldTopY = fieldDim.origin.y + fieldDim.size.height;
        fieldBottomY = fieldDim.origin.y;
        
        // ball is still
        ballAccel = 0;
        ballDirection = 0;
        
        [self resetMoveAccelValues];
        
        [self setIsTouchEnabled:YES];
        
        [self schedule:@selector(updateBall:) interval:1/25.0f];
    }
    return self;
}

-(void)dealloc {
    // ball sounds
    for (int i = 0; i < kBallSoundNum; i++) {
        [sndHandler unloadSound:ballSndId[i]];
        [ballSnd[i] release];
    }

    // success sound
    [sndHandler unloadSound:successSndId];
    [successSnd release];

    // sprites
    [ballInfoDispSprites release];
    [beginPhrase release];
    [keeper release];
    [ball release];
    [goal release];
    
    for (int i = 0; i < kSoccerGameNumBalls; i++) {
        [numBallSprites[i] release];
    }
    
    for (int i = 0; i < kSoccerGameNumBalls; i++) {
        [phraseSprites[i] release];
    }
    
    [super dealloc];
}

#pragma mark public methods

-(void)createKeeperFromMediaDefinition:(MediaDefinition *)keeperDef {
    ContentElement *elem = [ContentElement contentElementForMediaDefintion:keeperDef];
    [keeper release];
    keeper = [elem.displayNode retain];
    [self addChild:keeper z:kSpriteKeeperZ];
    
    keeperStartPos = keeper.position;
}

-(void)createBallFromMediaDefinition:(MediaDefinition *)ballDef {
    ContentElement *elem = [ContentElement contentElementForMediaDefintion:ballDef];
    [ball release];
    ball = [elem.displayNode retain];
    [self addChild:ball z:kSpriteBallZ];
    
    ballStartPos = ball.position;
}

-(void)createGoalFromMediaDefinition:(MediaDefinition *)goalDef {
    ContentElement *elem = [ContentElement contentElementForMediaDefintion:goalDef];
    [goal release];
    goal = [elem.displayNode retain];
    [self addChild:goal z:kSpriteGoalZ];
    
    
    goalLeftX = goal.position.x - goal.contentSize.width / 2;
    goalRightX = goal.position.x + goal.contentSize.width / 2; 
    goalLineY = goal.position.y - goal.contentSize.height / 2;
}

-(void)createNumBallsDisplayWithFileNameFormat:(NSString *)fileFormat atPos:(CGPoint)pos ballInfoDisplayMediaDefs:(NSArray *)ballInfoDisp {
    for (int i = 0; i < kSoccerGameNumBalls; i++) { // create the numbers to display
        [numBallSprites[i] release];
        numBallSprites[i] = [[CCSprite spriteWithFile:[NSString stringWithFormat:fileFormat, (i + 1)]] retain];
        [numBallSprites[i] setPosition:pos];
        [numBallSprites[i] setOpacity:0];
        
        [self addChild:numBallSprites[i]];
    }
    
    [ballInfoDispSprites removeAllObjects];
    for (MediaDefinition *infoDispMediaDef in ballInfoDisp) {
        ContentElement *elem = [ContentElement contentElementForMediaDefintion:infoDispMediaDef];
        [(CCSprite *)elem.displayNode setOpacity:0];
        [self addChild:elem.displayNode];
        
        [ballInfoDispSprites addObject:elem.displayNode];
    }
}

-(void)createBeginPhraseFromMediaDefinition:(MediaDefinition *)phraseDef {
    ContentElement *elem = [ContentElement contentElementForMediaDefintion:phraseDef];
    [beginPhrase release];
    beginPhrase = [elem.displayNode retain];
    [self addChild:beginPhrase z:kSpriteBeginPhraseZ];
}

-(void)addPhraseWithFile:(NSString *)file atPos:(CGPoint)pos {
    if (lastAddedPhraseIndex >= kSoccerGameNumBalls) return;
    
    phraseSprites[lastAddedPhraseIndex] = [[CCSprite spriteWithFile:file] retain];
    [phraseSprites[lastAddedPhraseIndex] setPosition:pos];
    [phraseSprites[lastAddedPhraseIndex] setVisible:NO];
    
    [self addChild:phraseSprites[lastAddedPhraseIndex]];
    
    lastAddedPhraseIndex++;
}

-(void)initGame {
    keeperStartPos = ccp(goalLeftX + keeper.contentSize.width / 2, keeperStartPos.y);
    keeperEndPos = ccp(goalRightX - keeper.contentSize.width / 2, keeperStartPos.y);
    
    [keeper setPosition:keeperStartPos];
}

-(void)startGame {
    isInteractionEnabled = YES;
    keeperShallMove = YES;
    
    [self keeperReturn];
}

-(void)stopGame {

}

-(void)setSuccessSound:(NSString *)sndFile {
    if (successSndId >= 0) {
        [sndHandler unloadSound:successSndId];
        [successSnd release];
    }
    
    // load and get sound
    successSndId = [sndHandler registerSoundToLoad:sndFile looped:NO gain:kFxSoundVolume]; 
    [sndHandler loadRegisteredSounds];   
    successSnd = [[sndHandler getSound:successSndId] retain];
}

-(void)setBallSounds:(NSString *[kBallSoundNum])ballSndFiles {
    for (int i = 0; i < kBallSoundNum; i++) {
        [sndHandler unloadSound:ballSndId[i]];
        [ballSnd[i] release];
    }
    
    // load and get the sounds
    for (int i = 0; i < kBallSoundNum; i++) {
        ballSndId[i] = [sndHandler registerSoundToLoad:ballSndFiles[i] looped:NO gain:kFxSoundVolume];
    }
    
    [sndHandler loadRegisteredSounds];
    
    for (int i = 0; i < kBallSoundNum; i++) {
        ballSnd[i] = [[sndHandler getSound:ballSndId[i]] retain];
    }
}

#pragma mark touch handling

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    float ballHitZoneRadius = [ball boundingBox].size.width * kSoccerGameHitZoneRadiusFactor;
    
    if (!ballIsBeingShot && [Tools touch:touch isInNode:ball usingRadius:ballHitZoneRadius]) {    // if we touched the ball ...
        ballSelectedPoint = [Tools convertTouchToGLPoint:touch];    // ... remember the point where
        ballSelectedTS = CACurrentMediaTime();                      // ... and the time when
        [[CoreHolder sharedCoreHolder] setInteractiveObjectWasTouched:YES];      // ... and disable gestures, because we dont want no page turn!
        [pageLayer cancelHighlightAnimations];
    }
}

//-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//
//}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!ballIsBeingShot && (CACurrentMediaTime() - ballSelectedTS <= kBallShootInterval)) {    // the "ball selection touch" was not so long before ...
        CGPoint touchPoint = [Tools convertTouchToGLPoint:[touches anyObject]];
        
        float dist = ccpDistance(ballSelectedPoint, touchPoint);    // ... then calculate the distance between the start and end points of the move
        
        if (dist >= kSoccerGameBallShootMinDist) {        
            CFTimeInterval deltaT = CACurrentMediaTime() - ballSelectedTS;
            ballAccel = dist / deltaT;  // calculate the acceleration
            
            // consider min and max values
            if (ballAccel < kSoccerGameBallShootMinAccel) ballAccel = kSoccerGameBallShootMinAccel;
            else if (ballAccel > kSoccerGameBallShootMaxAccel) ballAccel = kSoccerGameBallShootMaxAccel;
            
            // calculate the ball shoot direction
            ballDirection = ccpToAngle(ccpSub(ballSelectedPoint, touchPoint));
            
            // play a random ball sound 
            [ballSnd[(rand() % kBallSoundNum)] play];
            
            NSLog(@"Ball accel %f and direction %f", ballAccel, CC_RADIANS_TO_DEGREES(ballDirection));
        } else {
            NSLog(@"Move was not long enough");
        }
    }
    
    // reset things
    [self resetMoveAccelValues];
    [[CoreHolder sharedCoreHolder] setInteractiveObjectWasTouched:NO];
}

#pragma mark private methods

-(void)updateBall:(ccTime)dt {
    // get current position
    CGPoint pos = ball.position;
    
    // consider acceleration
    pos.x -= ballAccel / 50.0f * cosf(ballDirection);
    pos.y += ballAccel / 50.0f * sinf(-ballDirection);
    
    // consider friction
    ballAccel -= kSoccerGameBallFriction;
    if (isBallInGoal) ballAccel -= 10 * kSoccerGameBallFriction; // use stronger friction if the ball is in the goal
    if (ballAccel < 0.0f) ballAccel = 0.0f;
    
    // consider wall collisions

    CGRect bounds = [ball boundingBox];
    float ballCenterX = bounds.origin.x + bounds.size.width / 2; 
    float ballLeftX = bounds.origin.x;
    float ballRightX = bounds.origin.x + bounds.size.width;
    float ballTopY = bounds.origin.y + bounds.size.height;
    float ballBottomY = bounds.origin.y;
    
    if (ballLeftX < fieldLeftX || ballRightX > fieldRightX) {   // horizontal border collision
        ballDirection = M_PI - ballDirection;
                
        if (ballLeftX < fieldLeftX) {
            pos.x = fieldLeftX + bounds.size.width / 2 + 1;
        }
        
        if (ballRightX > fieldRightX) {
            pos.x = fieldRightX - (bounds.size.width / 2 + 1);
        }
        
        // play a random ball sound
        [ballSnd[(rand() % kBallSoundNum)] play];
    }
    
    if (ballBottomY < fieldBottomY || ballTopY > fieldTopY) {   // vertical border collision
        ballDirection = -ballDirection;
                
        if (ballBottomY < fieldBottomY) {
            pos.y = fieldBottomY + bounds.size.height / 2 + 1;
        }
        
        if (ballTopY > fieldTopY) {
            pos.y = fieldTopY - (bounds.size.height / 2 + 1);
        }
        
        // play a random ball sound
        [ballSnd[(rand() % kBallSoundNum)] play];
    }
        
    if (!isBallInGoal) {
        // consider keeper collisions
        CGRect keeperBounds = [keeper boundingBox];
        int keeperWidthAddition = 15;
        float keeperLeftX = keeperBounds.origin.x - keeperWidthAddition;
        float keeperRightX = keeperBounds.origin.x + keeperBounds.size.width + keeperWidthAddition;
        float keeperBottomY = keeperBounds.origin.y;
        float keeperTopY = keeperBounds.origin.y + kKeeperHeight;
        
        if (ballTopY >= keeperBottomY && ballTopY <= keeperTopY
        && ballCenterX >= keeperLeftX && ballCenterX <= keeperRightX) {
            ballDirection = -ballDirection;
            pos.y = keeperBottomY - (bounds.size.height / 2 + 1);
            
            // play a random ball sound
            [ballSnd[(rand() % kBallSoundNum)] play];
        }
        
        // consider goal!
        if (ballBottomY >= keeperTopY) {
            NSLog(@"GOAL!!!");
            
            // play sound
            [successSnd play];
            
            // set status
            isInteractionEnabled = NO;
            isBallInGoal = YES;
            
            // ball is now behind the keeper
            [self reorderChild:ball z:kSpriteKeeperZ];
            [self reorderChild:keeper z:kSpriteBallZ];
            
            // start a new round
            [self performSelector:@selector(nextGameRound) withObject:nil afterDelay:0.75f];
        }
    }
    
    // set new position
    [ball setPosition:pos];
}

-(void)resetMoveAccelValues {
    ballSelectedTS = 0;
    ballIsBeingShot = NO;
}

-(void)keeperReturn {
    if (!keeperShallMove) return;
    
    // set the keepers new target position
    CGPoint toPos;
    
    if (!keeperMovesToRight) {
        toPos = keeperEndPos;
    } else {
        toPos = keeperStartPos;
    }
    
    keeperMovesToRight = !keeperMovesToRight;
    
    // do the animation
    float dur = kSoccerGameKeeperMoveDurMax - (numShotBalls / (float)numMaxBalls) * (kSoccerGameKeeperMoveDurMax - kSoccerGameKeeperMoveDurMin);
    CCMoveTo *keeperMoveAction = [CCMoveTo actionWithDuration:dur position:toPos];
    CCAction *keeperMoveSeq = [CCSequence actions:keeperMoveAction, [CCCallFunc actionWithTarget:self selector:@selector(keeperReturn)], nil];
    
    [keeper runAction:keeperMoveSeq];
}

-(void)nextGameRound {
    // lets pop up a phrase
    [phraseSprites[numShotBalls] setVisible:YES];
    [phraseSprites[numShotBalls] setScale:0.0f];
    CCAction *popUpPhrase = [CommonActions popupElement:phraseSprites[numShotBalls] toScale:1.0f];
    [phraseSprites[numShotBalls] runAction:popUpPhrase];
    
    CCFiniteTimeAction *hideAnim = [CommonActions popupElement:ball toScale:0.0f];  // ball hide animation
    

    if (numShotBalls == 0) {    // first shot ball
        [beginPhrase runAction:[CCFadeOut actionWithDuration:kGeneralFadeDuration]];    // fade out "shoot!"
        
        for (CCSprite *ballInfoDispSprite in ballInfoDispSprites) {
            [ballInfoDispSprite runAction:[CCFadeIn actionWithDuration:kGeneralFadeDuration]];  // fade in ball information display sprites
        }
    } else {
        [numBallSprites[numShotBalls - 1] runAction:[CCFadeOut actionWithDuration:kGeneralFadeDuration]];   // fade out the old number
    }

    numShotBalls++;

    // fade in the new one
    [numBallSprites[numShotBalls - 1] runAction:[CCFadeIn actionWithDuration:kGeneralFadeDuration]];    // fade in the new one
        
    if (numShotBalls < numMaxBalls) {   // game has not ended        
        // hide the ball that is in the goal and then start the resetBallForNewRound method
        CCCallFunc *resetCall = [CCCallFunc actionWithTarget:self selector:@selector(resetBallForNewRound)];
        CCSequence *hideAndShowBallSeq = [CCSequence actions:hideAnim, resetCall, nil];
        
        [ball runAction:hideAndShowBallSeq];
    } else {
        // game has ended!
        NSLog(@"Game has ended!");
        
        keeperShallMove = NO;
        
        [ball runAction:hideAnim];
        
        if (pageTurnAtGameEnd) {    // autom. page turn
            [[CoreHolder sharedCoreHolder] performSelector:@selector(showNextPage:) withObject:nil afterDelay:3.0f];
        }
    }
}

-(void)resetBallForNewRound {
    // reset the order, so that the ball is in front of the keeper
    [self reorderChild:keeper z:kSpriteKeeperZ];
    [self reorderChild:ball z:kSpriteBallZ];
    
    // set the start position
    [ball setPosition:ballStartPos];
    
    // let it pop up
    [ball setVisible:YES];
    [ball runAction:[CommonActions popupElement:ball toScale:1.0f]];
    
    // reset values
    ballAccel = 0.0f;
    ballDirection = 0.0f;
    isBallInGoal = NO;
    isInteractionEnabled = YES;
}

@end
