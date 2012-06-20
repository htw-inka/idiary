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
//  PunchingBag.mm
//  iDiary2
//
//  Created by Markus Konrad on 18.07.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "PunchingBag.h"

#import "VRope.h"
#import "Config.h"

@implementation PunchingBag

#pragma mark init/dealloc

- (id)initWithFile:(NSString *)file ropeSprite:(CCSpriteBatchNode *)ropeSprites atPos:(CGPoint)pos hangingFrom:(CGPoint)hangingPos inWorld:(b2World *)w {
    if ((self = [super initWithFile:file])) {        
        // set defaults
        ropeSpriteSheet = [ropeSprites retain];
        vRopes = [[NSMutableArray alloc] init];
        
        // reset the anchorpoint, so that the rope is connected on top
//        [self setAnchorPoint:ccp(0.5, 0.7)];
        
        if (kDbgDrawPhysics) {
            [self setOpacity:128];
        }
        
        // Add anchor body
		b2BodyDef anchorBodyDef;
		anchorBodyDef.position.Set(hangingPos.x / PTM_RATIO, hangingPos.y / PTM_RATIO);
		anchorBody = w->CreateBody(&anchorBodyDef);
        
        // let PhySprite init the bag body
        [super setupWithPos:pos andBehaviour:kPhysicalBehaviorPunchingBag inWorld:w];
        
        // Create box2d joint
        CGSize dim = [self boundingBox].size;
//        NSLog(@"dim height: %f", dim.height);
        b2RopeJointDef jd;
        jd.bodyA = anchorBody; //define bodies
        jd.bodyB = body;
        jd.localAnchorA = b2Vec2(0, 0); //define anchors
        jd.localAnchorB = b2Vec2(0, 0.5f * dim.height / PTM_RATIO);
        jd.maxLength = (body->GetPosition() - anchorBody->GetPosition()).Length() - 0.5f * dim.height / PTM_RATIO; //define max length of joint = current distance between bodies
        NSLog(@" joint max length: %f", jd.maxLength);
        world->CreateJoint(&jd); //create joint
        // Create VRope with two b2bodies and pointer to spritesheet
//        VRope *newRope = [[VRope alloc] initWithBody1:anchorBody localAnchor1:jd.localAnchorA body2:body localAnchor2:jd.localAnchorB spriteSheet:ropeSpriteSheet];
//        [vRopes addObject:newRope];
//        [newRope release];

    }
    
    return self;
}

- (void) dealloc {
    world->DestroyBody(anchorBody);
    anchorBody = NULL;

    [ropeSpriteSheet release];
    [vRopes release];
    
    [super dealloc];
}

#pragma mark public methods

- (void)gotHitAt:(CGPoint)p velocity:(float)v angle:(float)a {
    NSLog(@"Hit at %f, %f with v = %f, a = %f", p.x, p.y, v, a);
    b2Vec2 force;
    b2Vec2 point;
    
    point.Set(p.x / PTM_RATIO, p.y / PTM_RATIO);
    force.Set(v * cosf(a), v * sinf(a));
    
    body->ApplyForce(force, point);
}

- (void)tick:(ccTime)dt {
	// Update rope physics
	for(uint i=0;i<[vRopes count];i++) {
		[[vRopes objectAtIndex:i] update:dt];
	}
}

#pragma mark CCSprite methods

- (void)draw {
    // update VRope sprites
	for(uint i=0;i<[vRopes count];i++) {
		[[vRopes objectAtIndex:i] updateSprites];
	}
    
    [super draw];
}

@end
