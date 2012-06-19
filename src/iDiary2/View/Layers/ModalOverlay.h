//
//  ModalOverlay.h
//  iDiary2
//
//  Created by Markus Konrad on 22.02.12.
//  Copyright (c) 2012 INKA Forschungsgruppe. All rights reserved.
//

#import "CCLayer.h"

#import "CoreHolder.h"
#import "PanningLayer.h"
#import "PanningLayerDelegate.h"

@interface ModalOverlay : CCLayerColor<PanningLayerDelegate> {
    CoreHolder *core;
    
    CCSprite *closeBtn;
    CCSprite *bgSprite;
    
    PanningLayer *contentLayer;
    
    NSTimeInterval interactionBlockTime;
}

-(void)setBackgroundImage:(NSString *)bgImg;
-(void)setContentImage:(NSString *)contentImg;

@end
