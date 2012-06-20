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
//  CommonActions.h
//  iDiary2
//
//  Created by Markus Konrad on 23.06.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"

// Class with static functions for common cocos2d actions & animations
@interface CommonActions : NSObject

// create "highlight" effect for interactive element
+ (CCAction *)highlightForInteractiveElement:(CCNode *)elem;

// create a "popup" effect for either showing or hiding an element
+ (CCEaseElasticOut *)popupElement:(CCNode *)elem toScale:(float)toScale;

// makes a "shake" effect for an element
+ (CCFiniteTimeAction *)shakeElement:(CCNode *)elem byX:(float)x byY:(float)y duration:(float)dur;

// create a fade in / out action for an element
+ (CCFiniteTimeAction *)fadeActionForElement:(CCNode *)elem in:(BOOL)fadeIn;
+ (CCFiniteTimeAction *)fadeActionForElement:(CCNode *)elem to:(GLubyte)toVal;

// directly fade in/out an element
+ (void)fadeElement:(CCNode *)elem in:(BOOL)fadeIn;
+ (void)fadeElement:(CCNode *)elem to:(GLubyte)toVal;

@end
