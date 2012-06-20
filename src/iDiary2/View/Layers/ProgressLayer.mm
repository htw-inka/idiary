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
//  ProgressLayer.m
//  iDiary2
//
//  Created by Christian Bunk on 08.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProgressLayer.h"


@implementation ProgressLayer

+ (id)progressWithFile:(NSString*)pFile andDuration:(NSNumber*)pDuration andPosition:(CGPoint)position {
    return [[ProgressLayer alloc] initWithFile:pFile andDuration:pDuration andPosition:position andDirection:progressDirectionHorizontalRL];
}

+ (id)progressWithFile:(NSString*)pFile andDuration:(NSNumber*)pDuration andPosition:(CGPoint)position andDirection:(ProgressDirection)pDirection{
    return [[ProgressLayer alloc] initWithFile:pFile andDuration:pDuration andPosition:position andDirection:pDirection];
}

- (id)initWithFile:(NSString*)pFile andDuration:(NSNumber*)pDuration andPosition:(CGPoint)position andDirection:(ProgressDirection)pDirection {
    self = [super init];
    if (self) {
        mDuration = [pDuration retain];

        // define the callback action after the timer ran through
        //id callbackTimer = [CCCallFunc actionWithTarget:self selector:@selector(timerFinished)];
        
        mTimer = [[CCProgressTimer progressWithFile:pFile] retain];
        
        // default direction
        mTimer.type = kCCProgressTimerTypeHorizontalBarLR;
        
        
        if (pDirection == progressDirectionHorizontalRL) {
            mTimer.type = kCCProgressTimerTypeHorizontalBarRL;
            
        }
        
        if (pDirection == progressDirectionVerticalTB) {
            mTimer.type = kCCProgressTimerTypeVerticalBarTB;
        }
        
        if (pDirection == progressDirectionVerticalBT) {
            mTimer.type = kCCProgressTimerTypeVerticalBarBT;
        }
        
        if (pDirection == progressDirectionRadialCW) {
            mTimer.type = kCCProgressTimerTypeRadialCW;
        }
        
        if (pDirection == progressDirectionRadialCCW) {
            mTimer.type = kCCProgressTimerTypeRadialCCW;
        }
        
        
        [mTimer setPosition:position];
        
        [self addChild:mTimer];
        
        mFrom = 0;
        mTo = 100;
    }
    return self;
}

- (void)dealloc {
    [mTimer release];
    [mDuration release];
    
    [super dealloc];
}

- (void) setPosition:(CGPoint)position {
    [mTimer setPosition:position]; 
}

- (void) start {
    [mTimer runAction:[CCSequence actions:[CCProgressFromTo actionWithDuration:[mDuration doubleValue] from:mFrom to:mTo], nil, nil]];
}

- (void) setDirection:(ProgressDirection)pDirection {
    if (pDirection == progressDirectionHorizontalLR) {
        mTimer.type = kCCProgressTimerTypeHorizontalBarLR;
        return;
    }
    
    if (pDirection == progressDirectionHorizontalRL) {
        mTimer.type = kCCProgressTimerTypeHorizontalBarRL;
        return;
    }
    
    if (pDirection == progressDirectionVerticalTB) {
        mTimer.type = kCCProgressTimerTypeVerticalBarTB;
        return;
    }
    
    if (pDirection == progressDirectionVerticalBT) {
        mTimer.type = kCCProgressTimerTypeVerticalBarBT;
        return;
    }
    
    if (pDirection == progressDirectionRadialCW) {
        mTimer.type = kCCProgressTimerTypeRadialCW;
        return;
    }
    
    if (pDirection == progressDirectionRadialCCW) {
        mTimer.type = kCCProgressTimerTypeRadialCCW;
    }
}

- (void) setFrom:(NSNumber *)pFrom andTo:(NSNumber *)pTo {
    mFrom = [pFrom intValue];
    mTo = [pTo intValue];
}

@end
