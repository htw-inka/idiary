//
//  OverviewLayer.h
//  iDiary2
//
//  Created by Markus Konrad on 27.04.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"

#import "CoreHolder.h"

@class CoreHolder;

// Overview that displays the available persons/diaries
@interface OverviewLayer : CCLayer {
    CoreHolder *core;

    NSString *persons[2];
    CCSprite *books[2];
    CCSprite *polaroids[2];
    CCSprite *anim[2];      // animation in polaroid
    
    BOOL animationEnded;
}

+(id)nodeWithPersons:(NSArray *)pPersons;
-(id)initWithPersons:(NSArray *)pPersons;

-(void)startAnimation;

@end
