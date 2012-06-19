//
//  CommonActions.mm
//  iDiary2
//
//  Created by Markus Konrad on 23.06.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "CommonActions.h"

#import "Config.h"

@implementation CommonActions

+ (CCAction *)highlightForInteractiveElement:(CCNode *)elem {
    float origScale = elem.scale;
    float duration = (kInteractiveElementsScaleAnimDuration / 2.0f);

    CCScaleTo *scaleUpAction = [CCScaleTo actionWithDuration:duration scale:(origScale * kInteractiveElementsScaleBy)];
    CCEaseInOut *actionUp = [CCEaseInOut actionWithAction:scaleUpAction rate:2];
    
    CCScaleTo *scaleDownAction = [CCScaleTo actionWithDuration:duration scale:origScale];
    CCEaseInOut *actionDown = [CCEaseInOut actionWithAction:scaleDownAction rate:2];
    
    return [CCSequence actions:actionUp, actionDown, nil];
}

+ (CCEaseElasticOut *)popupElement:(CCNode *)elem toScale:(float)toScale {    
    CCScaleTo *scaleAction = [CCScaleTo actionWithDuration:kPopUpAnimationDuration scale:toScale];
    return [CCEaseElasticOut actionWithAction:scaleAction period:0.3f];
}

//+ (CCEaseBounceInOut *)popupElementBounced:(CCNode *)elem toScale:(float)toScale {    
//    CCScaleTo *scaleAction = [CCScaleTo actionWithDuration:kPopUpAnimationDuration scale:toScale];
//    return [CCEase actionWithAction:scaleAction];
//}

+ (CCFiniteTimeAction *)shakeElement:(CCNode *)elem byX:(float)x byY:(float)y duration:(float)dur {
    CCMoveBy *action1 = [CCMoveBy actionWithDuration:dur/3.0f position:ccp(-x, -y)];
    CCMoveBy *action2 = [CCMoveBy actionWithDuration:dur/3.0f position:ccp(2.0f * x, 2.0f * y)];
    CCMoveBy *action3 = [CCMoveBy actionWithDuration:dur/3.0f position:ccp(-x, -y)];
    
    CCSequence *seq = [CCSequence actions:
        [CCEaseBounceInOut actionWithAction:action1],
        [CCEaseBounceInOut actionWithAction:action2],
        [CCEaseBounceInOut actionWithAction:action3],
        nil];
        
    return seq;
}

+ (CCFiniteTimeAction *)fadeActionForElement:(CCNode *)elem to:(GLubyte)toVal {
    return [CCFadeTo actionWithDuration:kGeneralFadeDuration opacity:toVal];
}

+ (CCFiniteTimeAction *)fadeActionForElement:(CCNode *)elem in:(BOOL)fadeIn {
    return [CommonActions fadeActionForElement:elem to:fadeIn ? 255 : 0];
}

+ (void)fadeElement:(CCNode *)elem to:(GLubyte)toVal {
    [elem runAction:[CommonActions fadeActionForElement:elem to:toVal]];
}

+ (void)fadeElement:(CCNode *)elem in:(BOOL)fadeIn {
    [elem runAction:[CommonActions fadeActionForElement:elem in:fadeIn]];
}

@end
