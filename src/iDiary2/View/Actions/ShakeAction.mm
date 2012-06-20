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
