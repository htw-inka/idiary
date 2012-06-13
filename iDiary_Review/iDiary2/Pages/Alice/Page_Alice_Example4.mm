//
//  Page_Alice_Example4.m
//  iDiary2
//
//  Created by Markus Konrad on 13.06.12.
//  Copyright (c) 2012 INKA Forschungsgruppe. All rights reserved.
//

#import "Page_Alice_Example4.h"

@implementation Page_Alice_Example4

- (id)init {
    self = [super init];
    if (self) {
        // create the country quiz with file prefix for the graphics
        quiz = [[CountryQuiz alloc] initOnPageLayer:self withImageFilePrefix:@"alice_example4__"];
        [self addChild:quiz z:100];

    }
    return self;
}

- (void)dealloc {
    [quiz release];

    [super dealloc];
}

- (void)loadPageContents {
    // set individual properties
    pageBackgroundImg = @"alice_seiten_hintergrund.png";
      
    // add individual media objects for this page here
    MediaDefinition *mDefWelcomeText = [MediaDefinition mediaDefinitionWithText:@"This page shows how to use the CountryQuiz/ArrangeGame classes."
                                                                           font:@"Courier New"
                                                                       fontSize:18
                                                                          color:ccBLACK
                                                                         inRect:CGRectMake(60, 700, 350, 100)];
    
    [mediaObjects addObject:mDefWelcomeText];
    
    [mediaObjects addObject:[MediaDefinition mediaDefinitionOfType:MEDIA_TYPE_PICTURE withValue:@"alice_example4__deutschland_fertig.png" inRect:CGRectMake(117, 195, 178, 169)]];

    // setup the quiz. first parameter together with the image file prefix makes the complete image files
    [quiz addCountry:@"agypten"     notePos:ccp(636, 483) countryPos:ccp(420, 462)];
    [quiz addCountry:@"norwegen"    notePos:ccp(813, 627) countryPos:ccp(330, 510) useDivergentTargetPos:ccp(263, 768-244)];
    [quiz addCountry:@"israel"      notePos:ccp(816, 565) countryPos:ccp(91, 427)];
    [quiz addCountry:@"australien"  notePos:ccp(643, 688) countryPos:ccp(245, 335)];
    [quiz addCountry:@"brasilien"   notePos:ccp(815, 688) countryPos:ccp(426, 269)];    
    [quiz addCountry:@"japan"       notePos:ccp(636, 623) countryPos:ccp(221, 154)];    
    [quiz addCountry:@"usa"         notePos:ccp(636, 553) countryPos:ccp(394, 126)];    

    // common media objects will be loaded in the PageLayer
    [super loadPageContents];

}


@end
