//
//  BookControl.m
//  iDiary2
//
//  Created by Markus Konrad on 02.04.12.
//  Copyright (c) 2012 INKA Forschungsgruppe. All rights reserved.
//

#import "BookControl.h"

#import "Tools.h"
#import "Config.h"

@implementation BookControl

@synthesize target;
@synthesize action;
@synthesize enabled;

#pragma mark init/dealloc

-(id)initWithTarget:(id)t action:(SEL)a {
    self = [super init];
    
    if (self) {
        gestureStartTime = 0.0f;
        gestureStartPoint = CGPointZero;
        enabled = YES;
        
        target = t;
        action = a;
        
        core = [CoreHolder sharedCoreHolder];
        
        tapRectLeft = CGRectMake(0, 0, kPageTurnCornerW, kPageTurnCornerH);
        tapRectRight = CGRectMake(core.screenW - kPageTurnCornerW, 0, kPageTurnCornerW, kPageTurnCornerH);
    }

    return self;
}

#pragma mark public methods

-(void)touchesBegan:(NSSet *)touches {
    if (!enabled) return;

    CGPoint p = [Tools convertTouchToGLPoint:[touches anyObject]];

    if ([touches count] > 1) { // check if valid movement, this means if the touch was in the right area
        NSLog(@"Swipe: Cancelled (wrong touch count)");
        gestureStartTime = -1.0f;
    } else {    // it was in the right area: save timestamp and startpoint of the touch
        gestureStartTime = CACurrentMediaTime();
        gestureStartPoint = p;
        NSLog(@"Swipe: Began at %f, %f", p.x, p.y);
    }

}


-(void)touchesEnded:(NSSet *)touches {
    if (!enabled || gestureStartTime < 0) return;

    CGPoint p = [Tools convertTouchToGLPoint:[touches anyObject]];
    
//    // somehow, "touchesEnded" has the coordinates flipped to portrait mode
//    // we must fix that:
//    CGFloat x = p.y;
//    p.y = p.x;
//    p.x = core.screenH - x;
    
    // calc distance and angle
    CGFloat dist = ccpDistance(p, gestureStartPoint);
    CGFloat angle = fabsf(ccpToAngle(ccpSub(p, gestureStartPoint)));
    
    NSLog(@"Swipe: Stop at: %f, %f", p.x, p.y);
    NSLog(@"Swipe: dist = %f, angle = %f", dist, CC_RADIANS_TO_DEGREES(angle));
    
    float angleTolerance = CC_DEGREES_TO_RADIANS(kPageTurnGestureAngleTolerance);
    float targetAngleLeft = 0.0f;   // to left
    float targetAngleRight = M_PI;   // to right
    BookControlTurnDirection direction = kBookControlTurnDirectionLeft;
    
    // check if valid movement
    if (([touches count] > 1)
    ||  (CACurrentMediaTime() - gestureStartTime > kPageTurnGestureMaxTime)) { // don't exceed maximum time
        NSLog(@"Swipe: Cancelled (wrong touch count or took too long)!");
        return;
    } else {        
        if (dist <= kPageTurnTapMaxDist) { // we have a tap
            if (CGRectContainsPoint(tapRectLeft, gestureStartPoint)) {
                direction = kBookControlTurnDirectionLeft;
            } else if (CGRectContainsPoint(tapRectRight, gestureStartPoint)) {
                direction = kBookControlTurnDirectionRight;
            } else {
                NSLog(@"Swipe: Cancelled (tap was out of tap area)!");
                
                return;            
            }
        } else {    // it might be a swipe gesture
            if (dist < kPageTurnGestureMinDist) {
                NSLog(@"Swipe: Cancelled (swipe was too short)!");
                
                return;
            }
            
            if (fabsf(targetAngleLeft - angle) <= angleTolerance) {
                direction = kBookControlTurnDirectionLeft;
            } else if (fabsf(targetAngleRight - angle) <= angleTolerance) {
                direction = kBookControlTurnDirectionRight;
            } else {
                NSLog(@"Swipe: Cancelled (swipe was in strange direction)!");
                
                return;                
            }
            
            if (direction == kBookControlTurnDirectionLeft && gestureStartPoint.x > core.screenCenter.x) {
                NSLog(@"Swipe: Cancelled (swipe to left started at the wrong side)!");
                
                return;
            } else if (direction == kBookControlTurnDirectionRight && gestureStartPoint.x < core.screenCenter.x) {
                NSLog(@"Swipe: Cancelled (swipe to right started at the wrong side)!");
                
                return;            
            }
        }
        
        NSLog(@"Swipe: Ended successfully!");
        
        [target performSelector:action withObject:[NSNumber numberWithInt:direction]];
    }
}


@end
