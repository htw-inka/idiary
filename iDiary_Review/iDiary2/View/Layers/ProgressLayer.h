//
//  ProgressLayer.h
//  iDiary2
//
//  Created by Christian Bunk on 08.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"

typedef enum {
    progressDirectionHorizontalLR = 1,
    progressDirectionHorizontalRL,
    progressDirectionVerticalTB,
    progressDirectionVerticalBT,
    progressDirectionRadialCW,
    progressDirectionRadialCCW
} ProgressDirection;

@interface ProgressLayer : CCLayer {
    CCProgressTimer *mTimer;
    CCProgressTo *to1;
    CGPoint mPosition;
    
    NSNumber* mDuration;
    int mFrom;
    int mTo;
}
+ (id)progressWithFile:(NSString*)pFile andDuration:(NSNumber*)pDuration andPosition:(CGPoint)position;

+ (id)progressWithFile:(NSString*)pFile andDuration:(NSNumber*)pDuration andPosition:(CGPoint)position andDirection:(ProgressDirection)pDirection;

- (id)initWithFile:(NSString*)pFile andDuration:(NSNumber*)pDuration andPosition:(CGPoint)position andDirection:(ProgressDirection)pDirection;

- (void) start;

- (void) setPosition:(CGPoint)position;

- (void) setDirection:(ProgressDirection)pDirection;

- (void) setFrom:(NSNumber*)pFrom andTo:(NSNumber*)pTo;
@end
