//
//  StartscreenLayer.h
//  iDiary2
//
//  Created by Markus Konrad on 23.06.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"

#import "CoreHolder.h"

@class CoreHolder;

// The layer the shows the desk with the diary and a glow effect
@interface StartscreenLayer : CCLayer {
    CoreHolder *core;

    CCSprite *bgSprite;
    CCSprite *diarySprite;
    CCSprite *diaryGlowSprite;
    CCSprite *disclaimerBtn;
    CCSprite *backBtn;
}

- (void)setupForPerson:(NSString *)person withDiaryPos:(CGPoint)diaryPos disclaimerPos:(CGPoint)disclaimerPos;

- (void)highlightInteractiveElements;

@end
