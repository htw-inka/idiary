//
//  Page_Alice_Intro.mm
//  iDiary2
//
//  Created by Markus Konrad on 06.06.12
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "Page_Alice_Intro.h"


@implementation Page_Alice_Intro

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
    MediaDefinition *mDefWelcomeText = [MediaDefinition mediaDefinitionWithText:@"Welcome to iDiary!" font:@"Courier New" fontSize:22 color:ccBLACK inRect:CGRectMake(60, 700, 350, 100)];
    [mediaObjects addObject:mDefWelcomeText];
    MediaDefinition *mDefWelcomeText2 = [MediaDefinition mediaDefinitionWithText:@"These are some example pages." font:@"Courier New" fontSize:18 color:ccBLACK inRect:CGRectMake(60, 660, 350, 100)];
    [mediaObjects addObject:mDefWelcomeText2];
    
    [mediaObjects addObject:[MediaDefinition mediaDefinitionOfType:MEDIA_TYPE_PICTURE withValue:@"alice_example1.png" inRect:CGRectMake(231, 422, 200, 201)]];
    [mediaObjects addObject:[MediaDefinition mediaDefinitionOfType:MEDIA_TYPE_PICTURE withValue:@"alice_example2.png" inRect:CGRectMake(750, 400.5, 312, 252)]];
    [mediaObjects addObject:[MediaDefinition mediaDefinitionWithVideo:@"alice_example_video.mov" andButton:@"common_play_button.png" inRect:CGRectMake(750, 400.5, 76, 77)]];

    // common media objects will be loaded in the PageLayer
    [super loadPageContents];
}

@end
