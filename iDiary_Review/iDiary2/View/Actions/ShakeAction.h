//
//  ShakeAction.h
//  iDiary2
//
//  Created by Markus Konrad on 05.09.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "cocos2d.h"

#import "CCActionInterval.h"

@interface ShakeAction : CCActionInterval {
    CGPoint delta;
    CGPoint startPosition;
    float rate;
    float angle;
    float startAngle;
}

+(id) actionWithDuration: (ccTime) t position: (CGPoint) p; // default rate value: 10.0f, angle = 0.0

+(id) actionWithDuration: (ccTime) t position: (CGPoint) p angle:(float)a rate:(float)r;

-(id) initWithDuration: (ccTime) t position: (CGPoint) p angle:(float)a rate:(float)r;

@end
