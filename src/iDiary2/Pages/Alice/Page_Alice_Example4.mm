// Copyright (c) 2012, HTW Berlin / Project HardMut
// (http://www.hardmut-projekt.de)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//
// * Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright
//   notice, this list of conditions and the following disclaimer in the
//   documentation and/or other materials provided with the distribution.
// * Neither the name of the HTW Berlin / INKA Research Group nor the names
//   of its contributors may be used to endorse or promote products derived
//   from this software without specific prior written permission.

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
// IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
// THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
