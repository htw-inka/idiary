//
//  BookControl.h
//  iDiary2
//
//  Created by Markus Konrad on 02.04.12.
//  Copyright (c) 2012 INKA Forschungsgruppe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CoreHolder.h"

typedef enum {
    kBookControlTurnDirectionLeft = 0,
    kBookControlTurnDirectionRight
} BookControlTurnDirection;

@interface BookControl : NSObject {
    CFTimeInterval gestureStartTime;    // start time of gesture touch
    CGPoint gestureStartPoint;          // start coordinates of gesture touch
    CGRect tapRectLeft;
    CGRect tapRectRight;
    
    CoreHolder *core;
}

@property (nonatomic,assign) id target;
@property (nonatomic,assign) SEL action;
@property (nonatomic,assign) BOOL enabled;

-(id)initWithTarget:(id)t action:(SEL)a;

-(void)touchesBegan:(NSSet *)touches;
-(void)touchesEnded:(NSSet *)touches;

@end
