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
//  ArrowGameLayer.h
//  iDiary2
//
//  Created by Markus Konrad on 14.11.11.
//  Copyright (c) 2011 INKA Forschungsgruppe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"

#import "PhySprite.h"
#import "MyContactListener.h"
#import "SoundHandler.h"
#import "PageLayer.h"

@interface ArrowGameTarget : NSObject { }

@property (nonatomic,retain) NSString *identifier;
@property (nonatomic,retain) CCNode *displayNode;
@property (nonatomic,retain) SoundObject *successSnd;
@property (nonatomic,assign) SEL successCall;
@property (nonatomic,assign) id successCallObj;

@end

@interface ArrowGamePerson : NSObject { }

@property (nonatomic,retain) CCNode *displayNode;
@property (nonatomic,retain) CCSprite *body;    // child of displayNode
@property (nonatomic,retain) CCAnimation *bodyAnim;    // animation object for animating the streching and shooting of the bow
@property (nonatomic,retain) CCSprite *arm;     // child of displayNode
@property (nonatomic,assign) unsigned int numArrows;
@property (nonatomic,assign) CGPoint armTurnPoint;

@end

typedef enum {
    kArrowGameStateNormal = 0,
    kArrowGameStateStretchingBow,
    kArrowGameStateShooting,
    kArrowGameStateEnded
} ArrowGameState;

@interface ArrowGameLayer : CCLayer {
    ArrowGameState state;
    
    MyContactListener *contactListener;

    PageLayer *parentLayer;     // weak ref!
    b2World *phyWorld;
    SoundHandler *sndHandler;
    
    int arrowFlySnd;

    PhySprite *arrow;
    NSString *arrowFile;
    CGPoint arrowStartPos;
    float arrowStartAngle;  // in degrees
    
    ArrowGamePerson *person;
    NSMutableArray *targets;    // array with objects of type ArrowGameTarget
    
    float curShootDist;
    float curShootAngle;    // in degrees
    
    b2Vec2 prevArrowPos;
}

@property (nonatomic,assign) id shootCallbackObj;
@property (nonatomic,assign) SEL shootCallbackFunc;
@property (nonatomic,assign) id resetArrowCallbackObj;
@property (nonatomic,assign) SEL resetArrowCallbackFunc;

-(id)initOnPageLayer:(PageLayer *)parentPage withBox2DWorld:(b2World *)w;

-(void)setArrow:(NSString *)file atPos:(CGPoint)arrowPos angle:(float)deg withSound:(NSString *)sndFile;

-(void)setPersonAtPos:(CGPoint)personPos body:(NSString *)bodyFile isAnimated:(BOOL)bodyAnimated offset:(CGPoint)bodyOffset arm:(NSString *)armFile offset:(CGPoint)armOffset turnPoint:(CGPoint)armTurnPoint numArrows:(int)numArrows;

-(void)addTarget:(NSString *)targetFile atPos:(CGPoint)pos willStopArrowOnContact:(BOOL)stopArrow successSound:(NSString *)successSndFile successCallback:(SEL)successCall onObject:(id)successObj;

@end
