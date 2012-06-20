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
//  VRope.h - 0.3
//
//  Updated by patrick on 28/10/2010.
//

/*
Verlet Rope for cocos2d
 
Visual representation of a rope with Verlet integration.
The rope can't (quite obviously) collide with objects or itself.
This was created to use in conjuction with Box2d's new b2RopeJoint joint, although it's not strictly necessary.
Use a b2RopeJoint to physically constrain two bodies in a box2d world and use VRope to visually draw the rope in cocos2d. (or just draw the rope between two moving or static points)

*** IMPORTANT: VRope does not create the b2RopeJoint. You need to handle that yourself, VRope is only responsible for rendering the rope
*** By default, the rope is fixed at both ends. If you want a free hanging rope, modify VRope.h and VRope.mm to only take one body/point and change the update loops to include the last point. 
 
HOW TO USE:
Import VRope.h into your class
 
CREATE:
To create a verlet rope, you need to pass two b2Body pointers (start and end bodies of rope)
and a CCSpriteBatchNode that contains a single sprite for the rope's segment. 
The sprite should be small and tileable horizontally, as it gets repeated with GL_REPEAT for the necessary length of the rope segment.

ex:
CCSpriteBatchNode *ropeSegmentSprite = [CCSpriteBatchNode batchNodeWithFile:@"ropesegment.png" ]; //create a spritesheet 
[self addChild:ropeSegmentSprite]; //add batchnode to cocos2d layer, vrope will be responsible for creating and managing children of the batchnode, you "should" only have one batchnode instance
VRope *verletRope = [[VRope alloc] init:bodyA pointB:bodyB spriteSheet:ropeSegmentSprite];

 
UPDATING:
To update the verlet rope you need to pass the time step
ex:
[verletRope updateRope:dt];

 
DRAWING:
From your layer's draw loop, call the updateSprites method
ex:
[verletRope updateSprites];

Or you can use the debugDraw method, which uses cocos2d's ccDrawLine method
ex:
[verletRope debugDraw];
 
REMOVING:
To remove a rope you need to call the removeSprites method and then release:
[verletRope removeSprites]; //remove the sprites of this rope from the spritebatchnode
[verletRope release];
 
There are also a few helper methods to use the rope without box2d bodies but with CGPoints only.
Simply remove the Box2D.h import and use the "WithPoints" methods.
 

For help you can find me on the cocos2d forums, username: patrickC
Good luck :) 

*/
#import <Foundation/Foundation.h>
#import "VPoint.h"
#import "VStick.h"
#import "cocos2d.h"
#import "Box2D.h"

//PTM_RATIO defined here is for testing purposes, it should obviously be the same as your box2d world or, better yet, import a common header where PTM_RATIO is defined
#define PTM_RATIO 32

@interface VRope : NSObject {
	int numPoints;
	NSMutableArray *vPoints;
	NSMutableArray *vSticks;
	NSMutableArray *ropeSprites;
	CCSpriteBatchNode* spriteSheet;
	float antiSagHack;
	#ifdef BOX2D_H
	b2Body *bodyA;
	b2Body *bodyB;
	#endif
}
#ifdef BOX2D_H
-(id)init:(b2Body*)body1 body2:(b2Body*)body2 spriteSheet:(CCSpriteBatchNode*)spriteSheetArg;
-(id)initWithBody1:(b2Body*)body1 localAnchor1:(b2Vec2)localAnchor1 body2:(b2Body*)body2 localAnchor2:(b2Vec2)localAnchor2 spriteSheet:(CCSpriteBatchNode*)spriteSheetArg;
-(void)update:(float)dt;
-(void)reset;
#endif
-(id)initWithPoints:(CGPoint)pointA pointB:(CGPoint)pointB spriteSheet:(CCSpriteBatchNode*)spriteSheetArg;
-(void)createRope:(CGPoint)pointA pointB:(CGPoint)pointB;
-(void)resetWithPoints:(CGPoint)pointA pointB:(CGPoint)pointB;
-(void)updateWithPoints:(CGPoint)pointA pointB:(CGPoint)pointB dt:(float)dt;
-(void)debugDraw;
-(void)updateSprites;
-(void)removeSprites;

@end
