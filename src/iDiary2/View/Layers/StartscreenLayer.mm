//
//  StartscreenLayer.mm
//  iDiary2
//
//  Created by Markus Konrad on 23.06.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "StartscreenLayer.h"

#import "CommonActions.h"
#import "Tools.h"
#import "Config.h"

static const CGFloat kBackBtnX = 78;

@interface StartscreenLayer(PrivateMethods)
- (void)glowAnimWithSprite:(CCSprite *)sprite;
@end

@implementation StartscreenLayer

#pragma mark init/dealloc

- (void)dealloc {
    [bgSprite release];
    [diarySprite release];
    [diaryGlowSprite release];
    [disclaimerBtn release];
    [backBtn release];
    
    [super dealloc];
}

#pragma mark public methods

- (void)setupForPerson:(NSString *)person withDiaryPos:(CGPoint)diaryPos disclaimerPos:(CGPoint)disclaimerPos {
    // set defaults
    [self setIsTouchEnabled:YES];
    
    core = [CoreHolder sharedCoreHolder];

    NSString *bgFile = [NSString stringWithFormat:@"startscreen_bg_%@.png", person];
    NSString *diaryFile = [NSString stringWithFormat:@"startscreen_diary_%@.png", person];
    NSString *diaryGlowFile = [NSString stringWithFormat:@"startscreen_diary_glow_%@.png", person];
    
    // setup background
    [bgSprite release];
    bgSprite = [[CCSprite spriteWithFile:bgFile] retain];
    [bgSprite setPosition:ccp(core.screenW/2, core.screenH/2)];
    [self addChild:bgSprite];
    
    // setup diary
    [diarySprite release];
    diarySprite = [[CCSprite spriteWithFile:diaryFile] retain];
    [diarySprite setPosition:diaryPos];
    [self addChild:diarySprite];
    
    // setup diary glow as child of diary
    [diaryGlowSprite release];
    diaryGlowSprite = [[CCSprite spriteWithFile:diaryGlowFile] retain];
    [diaryGlowSprite setPosition:ccp([diarySprite boundingBox].size.width / 2.0f, [diarySprite boundingBox].size.height / 2.0f)]; // center
    float glowScale = ([diarySprite boundingBox].size.width + kGlowBorderSize) / [diaryGlowSprite boundingBox].size.width;
    [diaryGlowSprite setScale:glowScale];
    [diarySprite addChild:diaryGlowSprite z:-1];
    
    // setup disclaimer button
    [disclaimerBtn release];
    disclaimerBtn = nil;
    [backBtn release];
    backBtn = nil;
    
    if (!CGPointEqualToPoint(disclaimerPos, CGPointZero)) {
        disclaimerBtn = [[CCSprite alloc] initWithFile:@"disclaimer_btn.png"];
        [disclaimerBtn setPosition:disclaimerPos];
        [self addChild:disclaimerBtn];
    
        // setup back button
        backBtn = [[CCSprite alloc] initWithFile:@"backButton.png"];
        CGPoint backBtnPos = ccp(kBackBtnX, disclaimerPos.y);
        [backBtn setPosition:backBtnPos];
        [self addChild:backBtn];
    }
    
    // highlight after fading
    [self performSelector:@selector(highlightInteractiveElements) withObject:nil afterDelay:kVideoFadeDuration];
    [self performSelector:@selector(glowAnimWithSprite:) withObject:diaryGlowSprite afterDelay:kVideoFadeDuration];
}

- (void)highlightInteractiveElements {
    [diarySprite runAction:[CommonActions highlightForInteractiveElement:diarySprite]];
    
    [self performSelector:@selector(highlightInteractiveElements) withObject:nil afterDelay:kInteractiveElementsAnimReplayInterval];
}

#pragma mark touch handling

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    if ([Tools touch:touch isInNode:diarySprite]) {
        [core enterCurrentPersonsDiary];
        
        return;
    } else if ([Tools touch:touch isInNode:disclaimerBtn]) {
        [core showModalOverlay:@"disclaimer_content.png" background:@"disclaimer_bg.png"];
        
        return;
    } else if ([Tools touch:touch isInNode:backBtn]) {
        [core switchToDiaryLauncher];
        
        return;
    }
}

#pragma mark private methods

- (void)glowAnimWithSprite:(CCSprite *)sprite {
    float newOpacity = kGlowOpacityMin;

    if (sprite.opacity < kGlowOpacityMax) {
        newOpacity = kGlowOpacityMax;
    }
    
    CCFadeTo *fade = [CCFadeTo actionWithDuration:(kGlowAnimDur / 2.0f) opacity:newOpacity];
    
    CCSequence *seq = [CCSequence actions:
        fade,
        [CCCallFuncN actionWithTarget:self selector:@selector(glowAnimWithSprite:)],   // will pass the sprite as argument
        nil];
        
    [sprite runAction:seq];
}

@end
