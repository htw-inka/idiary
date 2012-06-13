//
//  PhySprite.h
//  Cocos2DBox2D
//
//  Created by Markus Konrad on 28.12.10.
//  Copyright 2010 INKA Forschungsgruppe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

// Box2D
#define PTM_RATIO 32

typedef enum {
    kPhysicalBehaviorNone = -1,
    kPhysicalBehaviorSensor,
    kPhysicalBehaviorBall,
    kPhysicalBehaviorPhoto,
    kPhysicalBehaviorPunchingBag,
    kPhysicalBehaviorArrow
} physicalBehaviorType;

@interface PhySprite : CCSprite {
    b2Body *body;
    b2Fixture *bodyFixture;
    b2World *world;
    physicalBehaviorType physicalBehavior;
}

@property (nonatomic,readonly) b2Body *body;
@property (nonatomic,readonly) b2Fixture *bodyFixture;
@property (nonatomic,readonly) b2World *world;
@property (nonatomic,readonly) physicalBehaviorType physicalBehavior;

- (void)setupWithPos:(CGPoint)pos andBehaviour:(physicalBehaviorType)behavior inWorld:(b2World *)w;
- (void)setPhyPosition:(CGPoint)pos;
- (void)setPhyRotation:(float)rot;  // in radians
- (void)setPhyScale:(float)s;

@end
