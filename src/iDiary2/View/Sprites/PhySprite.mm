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
//  PhySprite.m
//  Cocos2DBox2D
//
//  Created by Markus Konrad on 28.12.10.
//  Copyright 2010 INKA Forschungsgruppe. All rights reserved.
//

#import "PhySprite.h"

@interface PhySprite(Private) 
- (void)definePhysicalBehavior;
@end

@implementation PhySprite

@synthesize body;
@synthesize bodyFixture;
@synthesize world;
@synthesize physicalBehavior;

#pragma mark init/dealloc

- (id) init {
    
    if ((self = [super init])) {
        body = nil;
    }
    
    return self;
}

- (void)dealloc {
    body->DestroyFixture(bodyFixture);
    bodyFixture = NULL;
    world->DestroyBody(body);
	body = NULL;
    
	// don't forget to call "super dealloc"
	[super dealloc];
}

#pragma mark public methods

- (void)setupWithPos:(CGPoint)pos andBehaviour:(physicalBehaviorType)behavior inWorld:(b2World *)w {
    self.position = pos;
    world = w;
    physicalBehavior = behavior;
    
	// Define the dynamic body.
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
    bodyDef.linearDamping = 0.0f;
    bodyDef.angularDamping = 0.01f;
	bodyDef.position.Set(pos.x/PTM_RATIO, pos.y/PTM_RATIO);
	bodyDef.userData = self;
	body = world->CreateBody(&bodyDef);
    
    // Define the physical behavior
    [self definePhysicalBehavior];
}

- (void)setPhyPosition:(CGPoint)pos {
    b2Vec2 vec(pos.x/PTM_RATIO, pos.y/PTM_RATIO);
    body->SetTransform(vec, body->GetAngle());
}

- (void)setPhyRotation:(float)rot {
    body->SetTransform(body->GetPosition(), -1.0f * rot);
}

- (void)setPhyScale:(float)s {
    self.scale = s;

    // Redefine the physical behavior
    [self definePhysicalBehavior];
}

#pragma mark private methods

- (void)definePhysicalBehavior {
    // Dimensions of the sprite
    CGSize dim = [self boundingBox].size;

    // Define the physical behavior
    b2FixtureDef fixtureDef;
    fixtureDef.userData = self;
    switch (physicalBehavior) {
        default:
        case kPhysicalBehaviorSensor: {
            b2PolygonShape dynamicBox;
            
            dynamicBox.SetAsBox(dim.width / 2.0f / PTM_RATIO, (dim.height / 2.5f) / PTM_RATIO); 
            
            fixtureDef.shape = &dynamicBox;
            fixtureDef.restitution = 0.0001f;
            fixtureDef.density = 1.0f;
            fixtureDef.friction = 0.9f;
            fixtureDef.isSensor = true;
            
            break;
        }
        
        case kPhysicalBehaviorBall: {
            b2CircleShape circle;
            circle.m_radius = dim.width / 2.0f / PTM_RATIO;
            
            fixtureDef.shape = &circle;
            fixtureDef.restitution = 0.8f;
            fixtureDef.density = 1.0f;
            fixtureDef.friction = 0.2f;
            
            break;
        }
            
        case kPhysicalBehaviorPhoto: {
            b2PolygonShape dynamicBox;
            dynamicBox.SetAsBox(.5f, .5f);//These are mid points for our 1m box
            
            fixtureDef.shape = &dynamicBox;
            fixtureDef.restitution = 0.0f;
            fixtureDef.density = 1.0f;
            fixtureDef.friction = 0.8f;
            
            break;
        }
        
        case kPhysicalBehaviorPunchingBag: {
            b2PolygonShape dynamicBox;
            
            // values hardcoded for Leons punching bag:
            dynamicBox.SetAsBox(dim.width / 2.0f / PTM_RATIO, (dim.height / 2.5f - 50.0f) / PTM_RATIO); 
            
            fixtureDef.shape = &dynamicBox;
            fixtureDef.restitution = 0.2f;
            fixtureDef.density = 1.0f;
            fixtureDef.friction = 0.9f;
            
            b2MassData mass;
            mass.mass = 50.0005;
            mass.I = 0.0f;
            body->SetMassData(&mass);
            
            break;
        }
        
        case kPhysicalBehaviorArrow: {
            b2PolygonShape dynamicBox;
            
            dynamicBox.SetAsBox(dim.width / PTM_RATIO, (dim.height / 2.0f) / PTM_RATIO); 
            
            fixtureDef.shape = &dynamicBox;
            fixtureDef.restitution = 0.0001f;
            fixtureDef.density = 1.0f;
            fixtureDef.friction = 0.9f;
            
            break;
        }
    }
    
	bodyFixture = body->CreateFixture(&fixtureDef);  
}

@end
