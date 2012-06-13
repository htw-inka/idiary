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
