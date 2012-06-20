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
//  ArrowGameLayer.m
//  iDiary2
//
//  Created by Markus Konrad on 14.11.11.
//  Copyright (c) 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "ArrowGameLayer.h"

#import "Config.h"
#import "Tools.h"
#import "CommonActions.h"
#import "ShakeAction.h"
#import "Makros.h"
#import "ContentElement.h"

#pragma mark constants

static const float kUpdateArrowInterval = 1/12.0f;

static const float kArrowTouchRadius = 45.0f;

static const float kArrowReappearTime = 1.0f;

static const float kArrowDistToShootVelocityFactor = 20.0f;

static const float kMaxArrowStretchDist = 90.0f;
static const float kMinArrowStretchDist = 30.0f;

static const float kMaxArrowAimAngle = 40.0f;
static const float kArrowStuckMinLen = 2.0f;
static const float kArrowStuckMaxLen = 20.0f;
static const float kTargetInsetH = 15.0f;

#pragma mark sprite tag definitions

enum {
    kArrowTag = 1,
    kTargetWillStopArrowTag,
    kTargetWillNotStopArrowTag,
};

#pragma mark z-order definitions

// For ArrowGameLayer
enum {
    kPersonZ = 1,
    kTargetZ,
    kArrowZ,
};

// For ArrowGamePerson
enum {
    kPersonBodyZ = 1,
    kPersonArmZ
};

@implementation ArrowGameTarget

@synthesize identifier;
@synthesize displayNode;
@synthesize successSnd;
@synthesize successCall;
@synthesize successCallObj;

-(void)dealloc {
    [identifier release];
    [displayNode release];
    [successSnd release];

    [super dealloc];
}

@end

@implementation ArrowGamePerson

@synthesize displayNode;
@synthesize body;
@synthesize bodyAnim;
@synthesize arm;
@synthesize numArrows;
@synthesize armTurnPoint;

-(void)dealloc {
    [displayNode release];
    [body release];
    [bodyAnim release];
    [arm release];

    [super dealloc];
}

@end

@interface ArrowGameLayer(PrivateMethods)
-(void)resetBow;
-(void)shootArrow;
-(void)updateArrow;
@end

@implementation ArrowGameLayer

@synthesize shootCallbackObj;
@synthesize shootCallbackFunc;
@synthesize resetArrowCallbackObj;
@synthesize resetArrowCallbackFunc;

#pragma mark init/dealloc

-(id)initOnPageLayer:(PageLayer *)parentPage withBox2DWorld:(b2World *)w {
    self = [super init];
    
    if (self) {
        // init objects
        state = kArrowGameStateNormal;
        parentLayer = parentPage;
        phyWorld = w;
        sndHandler = [SoundHandler shared];
        targets = [[NSMutableArray alloc] init];
        
        // set up contact listener
        contactListener = new MyContactListener();
        phyWorld->SetContactListener(contactListener);
        
        // set defaults
        arrowFlySnd = -1;
        [self setIsAccelerometerEnabled:NO];
        [self setIsTouchEnabled:YES];
        
        // schedule collision checking
        [self schedule:@selector(updateArrow:) interval:kUpdateArrowInterval];
    }
    
    return self;
}

-(void)dealloc {
    [arrow release];
    [arrowFile release];
    [person release];
    [targets release];
    
    phyWorld->SetContactListener(NULL);
    delete contactListener;

    [super dealloc];
}

#pragma mark public methods

-(void)setArrow:(NSString *)file atPos:(CGPoint)arrowPos angle:(float)deg withSound:(NSString *)sndFile {
    [arrow removeFromParentAndCleanup:YES];
    [arrow release];
    
    // set arrow
    if (arrowFile != file) {
        [arrowFile release];
        arrowFile = [file retain];
    }
    
    // create new phys. sprite
    arrow = [[PhySprite alloc] initWithFile:arrowFile];
    [arrow setTag:kArrowTag];
    
    [arrow setupWithPos:arrowPos andBehaviour:kPhysicalBehaviorArrow inWorld:phyWorld];    
    [arrow setPhyRotation:deg];
    arrow.body->SetActive(false);   // need to set inactive or the arrow will immediately fall down
    arrow.body->ResetMassData();
    
    // highlight the arrow
    [parentLayer.interactiveElements addObject:arrow];
    
    if (file) {
        // add as child
        [self addChild:arrow z:kArrowZ];
        
        // set start values
        arrowStartPos = arrowPos;
        arrowStartAngle = deg;
    }
    
    if (sndFile) {
        // set sound
        arrowFlySnd = [sndHandler registerSoundToLoad:sndFile looped:NO gain:kFxSoundVolume];
        [sndHandler loadRegisteredSounds];
    }
}

-(void)setPersonAtPos:(CGPoint)personPos body:(NSString *)bodyFile isAnimated:(BOOL)bodyAnimated offset:(CGPoint)bodyOffset arm:(NSString *)armFile offset:(CGPoint)armOffset turnPoint:(CGPoint)armTurnPoint numArrows:(int)numArrows {
    [person release];
    
    // create person
    person = [[ArrowGamePerson alloc] init];
    
    // create person node
    CCNode *personNode = [CCNode node];
    [personNode setPosition:personPos];
    
    // create and set body sprite
    if (!bodyAnimated) {        
        CCSprite *body = [CCSprite spriteWithFile:bodyFile];
        [body setPosition:bodyOffset];
        [person setBody:body];
    } else {
        MediaDefinition *bodyAnimDef = [MediaDefinition mediaDefinitionWithAnimation:bodyFile numberOfPlistFiles:1 inRect:CGRectMake(1, 1, 10, 10) loop:NO delay:-1];
        ContentElement *bodyElem = [ContentElement contentElementOnPageLayer:parentLayer forMediaDefintion:bodyAnimDef];
        [person setBody:(CCSprite *)bodyElem.displayNode];
        [person setBodyAnim:bodyElem.anim];
        [person.body setPosition:bodyOffset];
        [person.body setScale:1.0f];
    }
    
    // create and set arm sprite
    CCSprite *arm = [CCSprite spriteWithFile:armFile];
    [arm setPosition:armOffset];
    [person setArmTurnPoint:[Tools calcRelativePositionForAnchorPoint:armTurnPoint ofNode:arm]];
    [arm setAnchorPoint:armTurnPoint];
    [arm setPosition:person.armTurnPoint];
    [person setArm:arm];
    
    // connect arm and body to the person node
    [personNode addChild:person.body z:kPersonBodyZ];
    [personNode addChild:person.arm z:kPersonArmZ];
    
    // set node
    [person setDisplayNode:personNode];
    
    // set number of arrows
    [person setNumArrows:numArrows];
    
    // add as child
    [self addChild:personNode z:kPersonZ];
}

-(void)addTarget:(NSString *)targetFile atPos:(CGPoint)pos willStopArrowOnContact:(BOOL)stopArrow successSound:(NSString *)successSndFile successCallback:(SEL)successCall onObject:(id)successObj {
    // create target
    ArrowGameTarget *target = [[[ArrowGameTarget alloc] init] autorelease];
    [target setIdentifier:targetFile];
    
    // create and set sprite
    PhySprite *targetSprite = [PhySprite spriteWithFile:targetFile];
    if (stopArrow) {
        [targetSprite setTag:kTargetWillStopArrowTag];
    } else {
        [targetSprite setTag:kTargetWillNotStopArrowTag];    
    }
    [targetSprite setupWithPos:pos andBehaviour:kPhysicalBehaviorSensor inWorld:phyWorld];
    targetSprite.body->SetAwake(false);
    [target setDisplayNode:targetSprite];
    [targetSprite setUserData:target];
    
    // add as child
    [self addChild:targetSprite z:kTargetZ];
    
    // create and set sound
    if (successSndFile) {
        int sndId = [sndHandler registerSoundToLoad:successSndFile looped:NO gain:kFxSoundVolume];
        [sndHandler loadRegisteredSounds];
        [target setSuccessSnd:[sndHandler getSound:sndId]];
    }
    
    // set success callback
    if (successCall && successObj) {
        [target setSuccessCall:successCall];
        [target setSuccessCallObj:successObj];
    }
    
    // add target to array
    [targets addObject:target];
}

#pragma mark touch handling

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (state != kArrowGameStateNormal) return;

    UITouch *touch = [touches anyObject];
    
    if ([Tools touch:touch isInNode:arrow usingRadius:kArrowTouchRadius]) {
        NSLog(@"Touched arrow");
        
        // prevent from page swipe
        [[CoreHolder sharedCoreHolder] setInteractiveObjectWasTouched:YES];
        
        // cancel highlight animation
        [parentLayer cancelHighlightAnimations];
        [parentLayer.interactiveElements removeObject:arrow];
        
        // set new state
        state = kArrowGameStateStretchingBow;
    }
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (state != kArrowGameStateStretchingBow) return;
    
    // get start and end points
    CGPoint pStart = arrowStartPos;
    CGPoint pMove = [Tools convertTouchToGLPoint:[touches anyObject]];
    
    // get distance and angle
    curShootDist = ccpDistance(pStart, pMove);
    curShootAngle = CC_RADIANS_TO_DEGREES(-1.0f * [Tools angleBetweenPoint1:pStart andPoint2:pMove]) + 180.0f;
    
    // limit values
    if (curShootDist < kMinArrowStretchDist) curShootDist = kMinArrowStretchDist;
    if (curShootDist > kMaxArrowStretchDist) curShootDist = kMaxArrowStretchDist;
    
    const float kMinAimAngle = 360.0f - kMaxArrowAimAngle;
    if (curShootAngle >= 180.0f) {
        if (curShootAngle <= kMinAimAngle) {
            curShootAngle = kMinAimAngle;
        }
    } else {
        if (curShootAngle >= kMaxArrowAimAngle) {
            curShootAngle = kMaxArrowAimAngle;    
        }
    }
        
//    NSLog(@"Move with distance = %f, angle = %f...", curShootDist, curShootAngle);
    
    // animate the body
    if (person.bodyAnim) {
        float stretchProgress = curShootDist / kMaxArrowStretchDist;
        [Tools setAnimationProgress:stretchProgress ofAnimation:person.bodyAnim inSprite:person.body];
    }
    
    // calculate new arrow position
    float shootAngleRad = CC_DEGREES_TO_RADIANS(curShootAngle);
    CGPoint anglePoint = ccpForAngle(-shootAngleRad);
    anglePoint.y *= 0.2;
    CGPoint arrPos = ccpAdd(arrowStartPos, ccpMult(anglePoint, -curShootDist));
    
    // translate and rotate arrow
    [arrow setPhyPosition:arrPos];
    [arrow setPhyRotation:shootAngleRad];
    
    // rotate arm
    [person.arm setRotation:curShootAngle];
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (state != kArrowGameStateStretchingBow) return;
    
    NSLog(@"Move ended with distance = %f, angle = %f...", curShootDist, curShootAngle);

    if (curShootDist < kMinArrowStretchDist) {  // not stretched enough
        [self resetBow];
    } else {    // shoot!
        [self shootArrow];
    }

    // reset status
    curShootDist = 0;
    curShootAngle = 0;
}

#pragma mark private methods

-(void)resetBow {
    // check if game has ended
    if (person.numArrows <= 0) {
        NSLog(@"Game ended!");
        state = kArrowGameStateEnded;
        [self setIsTouchEnabled:NO];
        
        // make a small animation where david puts his arms down
        CCRotateTo *armsDownRotation = [CCRotateTo actionWithDuration:0.5f angle:kMaxArrowAimAngle];
        [person.arm runAction:armsDownRotation];
        
        return;
    }

    // reset bow
    NSLog(@"Resetting bow...");
    
    [self setArrow:arrowFile atPos:arrowStartPos angle:arrowStartAngle withSound:nil];

    [arrow setOpacity:0];
    [arrow setVisible:YES];
    [person.arm setRotation:arrowStartAngle];
    
    [CommonActions fadeElement:arrow in:YES];
    
    // set new state
    state = kArrowGameStateNormal;
}

-(void)shootArrow {
    // calc shoot velocity and angle
    float v = curShootDist * kArrowDistToShootVelocityFactor;
    float a = CC_DEGREES_TO_RADIANS(-curShootAngle);

    NSLog(@"Shooting arrow with velocity = %f, angle = %f...", v, CC_RADIANS_TO_DEGREES(a));
    
    // animate the arm
    if (person.bodyAnim) {
        CCReverseTime *armAnim = [CCReverseTime actionWithAction:[CCAnimate actionWithDuration:0.25f animation:person.bodyAnim restoreOriginalFrame:NO]];
        [person.body runAction:armAnim];
    }
    
    // set the box2d vectors
    b2Vec2 force;
    b2Vec2 point;
    
    point.Set(arrow.position.x / PTM_RATIO, arrow.position.y / PTM_RATIO);
    prevArrowPos = point;
    force.Set(v * cosf(a), v * sinf(a));
    
    // apply the force and let it fly!
    arrow.body->SetActive(true);
    arrow.body->ApplyForce(force, point);
    
    // play the sound
    if (arrowFlySnd > -1) {
        [[sndHandler getSound:arrowFlySnd] play];
    }
    
    // call the callback
    if (shootCallbackObj &&  shootCallbackFunc) {
        [shootCallbackObj performSelector:shootCallbackFunc];
    }
    
    // decrease arrow number
    person.numArrows--;
    
    // set new state
    state = kArrowGameStateShooting;
}

-(void)updateArrow:(ccTime)dt {
    if (state != kArrowGameStateShooting) return;

    // update rotation so that it looks like an arrow
    b2Vec2 vel = arrow.body->GetLinearVelocity();
    float dir = atan2f(vel.y, vel.x);
    arrow.body->SetTransform(arrow.body->GetPosition(), dir);
    
    // check page borders
    if (arrow.position.y < 0 || arrow.position.y > [CoreHolder sharedCoreHolder].screenH * 2.0f
     || arrow.position.x < 0 || arrow.position.x > [CoreHolder sharedCoreHolder].screenW) {
        state = kArrowGameStateNormal;
        
        // call callback
        if (resetArrowCallbackObj) {
            [resetArrowCallbackObj performSelector:resetArrowCallbackFunc];
        }
        
        [self performSelector:@selector(resetBow) withObject:nil afterDelay:kArrowReappearTime];
     
        return;
    }
    
    // check collision
    for (std::vector<MyContact>::iterator curContact = contactListener->_contacts.begin(); curContact != contactListener->_contacts.end(); ++curContact) {
        // get the target object
        PhySprite *contactSpriteA = (PhySprite *)curContact->fixtureA->GetUserData();
        PhySprite *contactSpriteB = (PhySprite *)curContact->fixtureB->GetUserData();
        
        PhySprite *contactSprite = nil;
        
        if (contactSpriteA.tag == kTargetWillStopArrowTag) {
            contactSprite = contactSpriteA;
        }
        
        if (contactSpriteB.tag == kTargetWillStopArrowTag) {
            contactSprite = contactSpriteB;
        }
        
        // we really hit a target sprite
        if (contactSprite) {
            NSLog(@"Arrow hit target, stopping arrow now!");
            
            // calculate a corrected point of impact because sometimes the arrow flies through the target ...
            CGFloat stuckLen = RAND_MIN_MAX(kArrowStuckMinLen, kArrowStuckMaxLen);
            CGFloat correctedX = contactSprite.position.x - arrow.contentSize.width / 2.0f + stuckLen;
            CGFloat correctedY = arrow.position.y;
            CGPoint correctedPoint = ccp(correctedX, correctedY);
            CGRect targetRect = [contactSprite boundingBox];
            if (correctedPoint.y < targetRect.origin.y + kTargetInsetH) {
                correctedPoint.y = targetRect.origin.y + kTargetInsetH;
            }
            if (correctedPoint.y > targetRect.origin.y + targetRect.size.height - kTargetInsetH) {
                correctedPoint.y = targetRect.origin.y + targetRect.size.height - kTargetInsetH;
            }
    
            [arrow setPosition:correctedPoint];
            
            // create a "stuck arrow" sprite at the very position of the real physical arrow
            CGRect arrowPartRect = CGRectMake(0, 0, arrow.contentSize.width - stuckLen, arrow.contentSize.height);
            CCSprite *stuckArrow = [CCSprite spriteWithFile:arrowFile rect:arrowPartRect];
            [stuckArrow setPosition:arrow.position];
            [stuckArrow setRotation:arrow.rotation];
            [stuckArrow setOpacity:255];
            
            [self addChild:stuckArrow z:kArrowZ];
            
            // reset the real physical arrow
            arrow.body->SetAwake(false);
            [arrow setVisible:NO];
            
            // make the stuck arrow shake
            ShakeAction *shake = [ShakeAction actionWithDuration:RAND_MIN_MAX(0.25f, 0.5f) position:ccp(RAND_MIN_MAX(-5.0f, 5.0f), RAND_MIN_MAX(-5.0f, 5.0f)) angle:RAND_MIN_MAX(5.0f, 10.0f) rate:50.0f];
            [stuckArrow runAction:shake];
            
            // get ArrowGameTarget from userData
            ArrowGameTarget *targetObj = (ArrowGameTarget *)contactSprite.userData;
            
            // play a sound
            if (targetObj.successSnd) {
                [targetObj.successSnd play];
            }

            // call the success callback
            if (targetObj.successCallObj) {
                [targetObj.successCallObj performSelector:targetObj.successCall];
            }
            
            // reset the bow if a target has been hit
            state = kArrowGameStateNormal;
            
            // call callback
            if (resetArrowCallbackObj) {
                [resetArrowCallbackObj performSelector:resetArrowCallbackFunc];
            }
            
            [self performSelector:@selector(resetBow) withObject:nil afterDelay:kArrowReappearTime];                        
            
            break;            
        }
    }
}

@end
