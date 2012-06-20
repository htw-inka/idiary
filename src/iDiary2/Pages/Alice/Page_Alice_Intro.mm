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
