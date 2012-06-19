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
