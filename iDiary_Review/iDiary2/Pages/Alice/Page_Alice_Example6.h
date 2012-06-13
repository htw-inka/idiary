//
//  Page_Alice_Example6.h
//  iDiary2
//
//  Created by Markus Konrad on 13.06.12.
//  Copyright (c) 2012 INKA Forschungsgruppe. All rights reserved.
//

#import "cocos2d.h"

#import "PageLayer.h"
#import "ArrowGameLayer.h"

static const int kNumArrows = 3;

@interface Page_Alice_Example6 : PageLayer {
    ArrowGameLayer *arrowGame;  // arrow game
    
    CCSprite *targetHitSprite;  // sprite that will be displayed when the target has been hit
    CCSprite *arrowsLeft[kNumArrows - 1];       // arrows that are left
    
    int numShotArrows;  // number of shot arrows
    
    ContentElement *birdAnim;   // bird hiding animation that is played when the player has shot an arrow
}

@end
