//
//  Page_Alice_Example5.h
//  iDiary2
//
//  Created by Markus Konrad on 13.06.12.
//  Copyright (c) 2012 INKA Forschungsgruppe. All rights reserved.
//

#import "PageLayer.h"

#import "ScrollingRaceGame.h"

@interface Page_Alice_Example5 : PageLayer {
    ScrollingRaceGame *game;    // race game
    int crashSndId;             // sound id for sound that is played when the player crashs
}

@end
