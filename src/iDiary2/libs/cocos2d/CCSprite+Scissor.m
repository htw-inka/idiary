//
//  CCSprite+Scissor.m
//  iDiary2
//
//  Created by Christian Bunk on 05.12.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "CCSprite+Scissor.h"

@implementation CCSprite (Scissor)

- (void) visit {
    
    float offsetX = sRect_.origin.x;
    float offsetY = sRect_.origin.y;
    float swidth = sRect_.size.width;
    float sheight = sRect_.size.height;
    
    if ( swidth == 0 && sheight == 0 ) {
        [super visit];
    } else {
        glEnable(GL_SCISSOR_TEST);
        glScissor(offsetX, offsetY, swidth, sheight);
        [super visit];
        glDisable(GL_SCISSOR_TEST);
    } 
    
}

@end
