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
//  VRope.m
//
//  Created by patrick on 16/10/2010.
//

#import "VRope.h"


@implementation VRope

#ifdef BOX2D_H

-(id)init:(b2Body*)body1 body2:(b2Body*)body2 spriteSheet:(CCSpriteBatchNode*)spriteSheetArg {
    return [self initWithBody1:body1 localAnchor1:b2Vec2(0,0) body2:body2 localAnchor2:b2Vec2(0,0) spriteSheet:spriteSheetArg];
}

-(id)initWithBody1:(b2Body*)body1 localAnchor1:(b2Vec2)localAnchor1 body2:(b2Body*)body2 localAnchor2:(b2Vec2)localAnchor2 spriteSheet:(CCSpriteBatchNode*)spriteSheetArg {
	if((self = [super init])) {
		bodyA = body1;
		bodyB = body2;
		CGPoint pointA = ccp((bodyA->GetPosition().x + localAnchor1.x) * PTM_RATIO, (bodyA->GetPosition().y + localAnchor1.y) * PTM_RATIO);
		CGPoint pointB = ccp((bodyB->GetPosition().x + localAnchor2.x) * PTM_RATIO, (bodyB->GetPosition().y + localAnchor2.y) * PTM_RATIO);
		spriteSheet = spriteSheetArg;
		[self createRope:pointA pointB:pointB];
	}
	return self;
}

-(void)reset {
	CGPoint pointA = ccp(bodyA->GetPosition().x*PTM_RATIO,bodyA->GetPosition().y*PTM_RATIO);
	CGPoint pointB = ccp(bodyB->GetPosition().x*PTM_RATIO,bodyB->GetPosition().y*PTM_RATIO);
	[self resetWithPoints:pointA pointB:pointB];
}

-(void)update:(float)dt {
	CGPoint pointA = ccp(bodyA->GetPosition().x*PTM_RATIO,bodyA->GetPosition().y*PTM_RATIO);
	CGPoint pointB = ccp(bodyB->GetPosition().x*PTM_RATIO,bodyB->GetPosition().y*PTM_RATIO);
	[self updateWithPoints:pointA pointB:pointB dt:dt];
}
#endif

-(id)initWithPoints:(CGPoint)pointA pointB:(CGPoint)pointB spriteSheet:(CCSpriteBatchNode*)spriteSheetArg {
	if((self = [super init])) {
		spriteSheet = spriteSheetArg;
		[self createRope:pointA pointB:pointB];
	}
	return self;
}

-(void)createRope:(CGPoint)pointA pointB:(CGPoint)pointB {
	vPoints = [[NSMutableArray alloc] init];
	vSticks = [[NSMutableArray alloc] init];
	ropeSprites = [[NSMutableArray alloc] init];
	float distance = ccpDistance(pointA,pointB);
	int segmentFactor = 12; //increase value to have less segments per rope, decrease to have more segments
	numPoints = distance/segmentFactor;
	CGPoint diffVector = ccpSub(pointB,pointA);
	float multiplier = distance / (numPoints-1);
	antiSagHack = 0.5f; //HACK: scale down rope points to cheat sag. set to 0 to disable, max suggested value 0.1
	for(int i=0;i<numPoints;i++) {
		CGPoint tmpVector = ccpAdd(pointA, ccpMult(ccpNormalize(diffVector),multiplier*i*(1-antiSagHack)));
		VPoint *tmpPoint = [[VPoint alloc] init];
		[tmpPoint setPos:tmpVector.x y:tmpVector.y];
		[vPoints addObject:tmpPoint];
	}
	for(int i=0;i<numPoints-1;i++) {
		VStick *tmpStick = [[VStick alloc] initWith:[vPoints objectAtIndex:i] pointb:[vPoints objectAtIndex:i+1]];
		[vSticks addObject:tmpStick];
	}
	if(spriteSheet!=nil) {
		for(int i=0;i<numPoints-1;i++) {
			VPoint *point1 = [[vSticks objectAtIndex:i] getPointA];
			VPoint *point2 = [[vSticks objectAtIndex:i] getPointB];
			CGPoint stickVector = ccpSub(ccp(point1.x,point1.y),ccp(point2.x,point2.y));
			float stickAngle = ccpToAngle(stickVector);
			CCSprite *tmpSprite = [CCSprite spriteWithBatchNode:spriteSheet rect:CGRectMake(0,0,multiplier,[[[spriteSheet textureAtlas] texture] pixelsHigh])];
			ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
			[tmpSprite.texture setTexParameters:&params];
			[tmpSprite setPosition:ccpMidpoint(ccp(point1.x,point1.y),ccp(point2.x,point2.y))];
			[tmpSprite setRotation:-1 * CC_RADIANS_TO_DEGREES(stickAngle)];
			[spriteSheet addChild:tmpSprite];
			[ropeSprites addObject:tmpSprite];
		}
	}
}

-(void)resetWithPoints:(CGPoint)pointA pointB:(CGPoint)pointB {
	float distance = ccpDistance(pointA,pointB);
	CGPoint diffVector = ccpSub(pointB,pointA);
	float multiplier = distance / (numPoints - 1);
	for(int i=0;i<numPoints;i++) {
		CGPoint tmpVector = ccpAdd(pointA, ccpMult(ccpNormalize(diffVector),multiplier*i*(1-antiSagHack)));
		VPoint *tmpPoint = [vPoints objectAtIndex:i];
		[tmpPoint setPos:tmpVector.x y:tmpVector.y];
		
	}
}

-(void)removeSprites {
	for(int i=0;i<numPoints-1;i++) {
		CCSprite *tmpSprite = [ropeSprites objectAtIndex:i];
		[spriteSheet removeChild:tmpSprite cleanup:YES];
	}
	[ropeSprites removeAllObjects];
	[ropeSprites release];
}

-(void)updateWithPoints:(CGPoint)pointA pointB:(CGPoint)pointB dt:(float)dt {
	//manually set position for first and last point of rope
	[[vPoints objectAtIndex:0] setPos:pointA.x y:pointA.y];
	[[vPoints objectAtIndex:numPoints-1] setPos:pointB.x y:pointB.y];
	
	//update points, apply gravity
	for(int i=1;i<numPoints-1;i++) {
		[[vPoints objectAtIndex:i] applyGravity:dt];
		[[vPoints objectAtIndex:i] update];
	}
	
	//contract sticks
	int iterations = 4;
	for(int j=0;j<iterations;j++) {
		for(int i=0;i<numPoints-1;i++) {
			[[vSticks objectAtIndex:i] contract];
		}
	}
}

-(void)updateSprites {
	if(spriteSheet!=nil) {
		for(int i=0;i<numPoints-1;i++) {
			VPoint *point1 = [[vSticks objectAtIndex:i] getPointA];
			VPoint *point2 = [[vSticks objectAtIndex:i] getPointB];
			CGPoint point1_ = ccp(point1.x,point1.y);
			CGPoint point2_ = ccp(point2.x,point2.y);
			float stickAngle = ccpToAngle(ccpSub(point1_,point2_));
			CCSprite *tmpSprite = [ropeSprites objectAtIndex:i];
            CGPoint midpoint = ccpMidpoint(point1_,point2_);
            midpoint.x += tmpSprite.contentSize.width / 2.0f;
			[tmpSprite setPosition:midpoint];
			[tmpSprite setRotation: -CC_RADIANS_TO_DEGREES(stickAngle)];
		}
	}	
}

-(void)debugDraw {
	//Depending on scenario, you might need to have different Disable/Enable of Client States
	//glDisableClientState(GL_TEXTURE_2D);
	//glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	//glDisableClientState(GL_COLOR_ARRAY);
	//set color and line width for ccDrawLine
	glColor4f(0.0f,0.0f,1.0f,1.0f);
	glLineWidth(5.0f);
	for(int i=0;i<numPoints-1;i++) {
		//"debug" draw
		VPoint *pointA = [[vSticks objectAtIndex:i] getPointA];
		VPoint *pointB = [[vSticks objectAtIndex:i] getPointB];
		ccDrawPoint(ccp(pointA.x,pointA.y));
		ccDrawPoint(ccp(pointB.x,pointB.y));
		//ccDrawLine(ccp(pointA.x,pointA.y),ccp(pointB.x,pointB.y));
	}
	//restore to white and default thickness
	glColor4f(1.0f,1.0f,1.0f,1.0f);
	glLineWidth(1);
	//glEnableClientState(GL_TEXTURE_2D);
	//glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	//glEnableClientState(GL_COLOR_ARRAY);
}

-(void)dealloc {
	for(int i=0;i<numPoints;i++) {
		[[vPoints objectAtIndex:i] release];
		if(i!=numPoints-1)
			[[vSticks objectAtIndex:i] release];
	}
	[vPoints removeAllObjects];
	[vSticks removeAllObjects];
	[vPoints release];
	[vSticks release];
	[super dealloc];
}

@end
