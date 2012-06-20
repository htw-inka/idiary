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
//  Node3DRotateActions.mm
//  iDiary2
//
//  Created by Markus Konrad on 01.09.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "Node3DRotateActions.h"

@implementation Node3DRotateTo

+(id)actionWithDuration: (ccTime) t angle:(float) a axis:(Node3DAxis)pAxis {	
	return [[[self alloc] initWithDuration:t angle:a axis:(Node3DAxis)pAxis ] autorelease];
}

-(id)initWithDuration: (ccTime) t angle:(float) a axis:(Node3DAxis)pAxis {
	if( (self=[super initWithDuration: t]) ) {
		dstAngle_ = a;
        axis = pAxis;
    }
	
	return self;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	
    BOOL is3D = [target_ isKindOfClass:[Node3D class]];

    if (axis == kNode3DAxisX && is3D)
        startAngle_ = [(Node3D *)target_ rotationX];
    else if (axis == kNode3DAxisY && is3D)
        startAngle_ = [(Node3D *)target_ rotationY];
    else
        startAngle_ = [target_ rotation];
        
	if (startAngle_ > 0)
		startAngle_ = fmodf(startAngle_, 360.0f);
	else
		startAngle_ = fmodf(startAngle_, -360.0f);
	
	diffAngle_ = dstAngle_ - startAngle_;
	if (diffAngle_ > 180)
		diffAngle_ -= 360;
	if (diffAngle_ < -180)
		diffAngle_ += 360;
}

-(id) copyWithZone: (NSZone*) zone {
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] angle:dstAngle_ axis:axis];
	return copy;
}

-(void) update: (ccTime) t {
    BOOL is3D = [target_ isKindOfClass:[Node3D class]];
    float newRot = startAngle_+ diffAngle_ * t;

    if (axis == kNode3DAxisX && is3D)
        [(Node3D *)target_ setRotationX:newRot];
    else if (axis == kNode3DAxisY && is3D)
        [(Node3D *)target_ setRotationY:newRot];
    else
        [target_ setRotation:newRot];

}

@end

@implementation Node3DRotateBy

+(id)actionWithDuration: (ccTime) t angle:(float) a axis:(Node3DAxis)pAxis {	
	return [[[self alloc] initWithDuration:t angle:a axis:(Node3DAxis)pAxis ] autorelease];
}

-(id)initWithDuration: (ccTime) t angle:(float) a axis:(Node3DAxis)pAxis {
	if( (self=[super initWithDuration: t]) ) {
		angle_ = a;
        axis = pAxis;
    }
	
	return self;
}

-(void) startWithTarget:(id)aTarget {
	[super startWithTarget:aTarget];
    
    BOOL is3D = [target_ isKindOfClass:[Node3D class]];

    if (axis == kNode3DAxisX && is3D)
        startAngle_ = [(Node3D *)target_ rotationX];
    else if (axis == kNode3DAxisY && is3D)
        startAngle_ = [(Node3D *)target_ rotationY];
    else
        startAngle_ = [target_ rotation];
}

-(id) copyWithZone: (NSZone*) zone {
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] angle:angle_ axis:axis];
	return copy;
}

-(void) update: (ccTime) t {	
    BOOL is3D = [target_ isKindOfClass:[Node3D class]];
    float newRot = startAngle_ + angle_ * t;

    if (axis == kNode3DAxisX && is3D)
        [(Node3D *)target_ setRotationX:newRot];
    else if (axis == kNode3DAxisY && is3D)
        [(Node3D *)target_ setRotationY:newRot];
    else
        [target_ setRotation:newRot];
}

-(CCActionInterval*) reverse {
	return [[self class] actionWithDuration:duration_ angle:-angle_ axis:axis];
}

@end
