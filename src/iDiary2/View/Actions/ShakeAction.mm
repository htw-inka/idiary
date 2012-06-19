//
//  ShakeAction.mm
//  iDiary2
//
//  Created by Markus Konrad on 05.09.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "ShakeAction.h"

@implementation ShakeAction

+(id) actionWithDuration: (ccTime) t position: (CGPoint) p {
	return [[[self alloc] initWithDuration:t position:p angle:0.0f rate:10.0f ] autorelease];    
}

+(id) actionWithDuration: (ccTime) t position: (CGPoint) p angle:(float)a rate:(float)r {	
	return [[[self alloc] initWithDuration:t position:p angle:a rate:r ] autorelease];
}

-(id) initWithDuration: (ccTime) t position: (CGPoint) p angle:(float)a rate:(float)r {
	if( (self=[super initWithDuration: t]) ) {
		delta = p;
        rate = r;
        angle = a;
	}
    
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] position: delta angle:angle rate:rate];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	startPosition = [(CCNode*)target_ position];
    startAngle = [(CCNode*)target_ rotation];
}

-(CCActionInterval*) reverse {
	return [[self class] actionWithDuration:duration_ position:ccp( -delta.x, -delta.y) angle:-angle rate:rate];
}

-(void) update: (ccTime) t {
    float damping = 1.0f - t;    // only linear damping
    
    CGFloat x = damping * cosf(rate * t * M_PI) * delta.x;    
    CGFloat y = damping * sinf(rate * t * M_PI) * delta.y;    
                
	[target_ setPosition: ccp(startPosition.x + x, startPosition.y + y)];
    
    if (angle != 0.0f) {
        float alpha = damping * sinf(rate * t * M_PI) * angle;    
        [target_ setRotation:startAngle + alpha];
    }
}


@end
