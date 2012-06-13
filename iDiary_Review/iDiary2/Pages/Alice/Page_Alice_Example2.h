//
//  Page_Alice_Example2.h
//  iDiary2
//
//  Created by Markus Konrad on 13.06.12.
//  Copyright (c) 2012 INKA Forschungsgruppe. All rights reserved.
//

#import "PageLayer.h"

#import "MagicLayer.h"
#import "Node3D.h"

@interface Page_Alice_Example2 : PageLayer {
    MagicLayer *spriteMask;
    CGRect priceRect;
    
    Node3D *labelNode;
    BOOL labelFlipAnimRunning;   // saves status for each label if the flip animation is running
    BOOL labelBackSideShowing;   // is YES when the back side of a label is showing
    
    int swoshSndId;             // swosh sound id
    
    float dangleAngle;       // angle for dangling
    int dangleRepeatNum;     // how often the animation has been started

}

@end
