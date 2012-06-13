//
//  Page_Alice_Example8.m
//  iDiary2
//
//  Created by Markus Konrad on 13.06.12.
//  Copyright (c) 2012 INKA Forschungsgruppe. All rights reserved.
//

#import "Page_Alice_Example8.h"

@implementation Page_Alice_Example8

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)loadPageContents {
    // set individual properties
    pageBackgroundImg = @"alice_seiten_hintergrund.png";
      
    // add individual media objects for this page here
    MediaDefinition *mDefWelcomeText = [MediaDefinition mediaDefinitionWithText:@"Bye bye!" font:@"Courier New" fontSize:22 color:ccBLACK inRect:CGRectMake(60, 700, 400, 100)];
    [mediaObjects addObject:mDefWelcomeText];
    MediaDefinition *mDefWelcomeText2 = [MediaDefinition mediaDefinitionWithText:@"This was a short introduction to what is possible with the iDiary framework. Check out other layer classes, too! For example MemoryGameLayer, SoccerGameLayer, BoxingLayer, etc." font:@"Courier New" fontSize:18 color:ccBLACK inRect:CGRectMake(60, 660, 400, 500)];
    [mediaObjects addObject:mDefWelcomeText2];
    
    // add a movable text
    MediaDefinition *movableText = [MediaDefinition mediaDefinitionWithText:@"I'm moveable text!" font:@"Courier New" fontSize:26 color:ccBLACK inRect:CGRectMake(700, 350, 250, 100)];
    [[movableText attributes] setValue:[NSNumber numberWithBool:YES] forKey:@"isInteractive"];
    [[movableText attributes] setValue:[NSNumber numberWithBool:YES] forKey:@"isMovable"];
    
    [mediaObjects addObject:movableText];
    
    // add a movable graphic
    MediaDefinition *movableImg = [MediaDefinition mediaDefinitionOfType:MEDIA_TYPE_PICTURE withValue:@"alice_example8__blatt1.png" inRect:CGRectMake(700, 100, 222, 128) interactive:YES movable:YES];
    
    [mediaObjects addObject:movableImg];
        
    // common media objects will be loaded in the PageLayer
    [super loadPageContents];
}

@end
