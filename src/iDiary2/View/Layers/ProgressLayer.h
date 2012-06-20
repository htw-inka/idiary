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
