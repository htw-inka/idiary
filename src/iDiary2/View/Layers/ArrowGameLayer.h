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
