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
//  Page_Alice_Example7.m
//  iDiary2
//
//  Created by Markus Konrad on 13.06.12.
//  Copyright (c) 2012 INKA Forschungsgruppe. All rights reserved.
//

#import "Page_Alice_Example7.h"

@implementation Page_Alice_Example7

- (id)init {
    self = [super init];
    if (self) {
        // set up the PianoLayer
        piano = [[PianoLayer alloc] initOnPageLayer:self withSoundFile:@"piano_c.mp3" andBaseToneStep:0 andApplauseSound:@"applause1.mp3" andFailSound:@"oops1.mp3"];
        [interactiveElements addObject:piano];
        [piano setIsInteractionEnabled:NO]; // will be enabled after autoplay sequence
        
        // create an autoplay sequence
        float speed = 1.25f;
        [piano addAutoplayNoteAtStep:16 withDuration:0.25f * speed];
        [piano addAutoplayNoteAtStep:15 withDuration:0.25f * speed];
        [piano addAutoplayNoteAtStep:16 withDuration:0.25f * speed];
        [piano addAutoplayNoteAtStep:15 withDuration:0.25f * speed];
        [piano addAutoplayNoteAtStep:16 withDuration:0.25f * speed];
        [piano addAutoplayNoteAtStep:11 withDuration:0.25f * speed];
        [piano addAutoplayNoteAtStep:14 withDuration:0.25f * speed];
        [piano addAutoplayNoteAtStep:12 withDuration:0.25f * speed];
        [piano addAutoplayNoteAtStep:9  withDuration:0.25f * speed];
        
        [piano setAutoplayInfoImagesBefore:@"alice_example7__text_aufpas_3.png"
                                     atPos:ccp(444, 584)
                                  andAfter:@"alice_example7__text_du_bis_e.png"
                                     atPos:ccp(510, 163)];
                                     
        [piano setSuccessImage:@"alice_example7__Text_Perfekt.png"
                         atPos:ccp(339, 628)
                  andFailImage:@"alice_example7__Text_Probiers.png"
                         atPos:ccp(526, 153)];
                
        // set it as child
        [self addChild:piano z:100];
    }
    return self;
}

- (void)dealloc {
    [piano stopAutoplay];
    [piano release];

    [super dealloc];
}

- (void)loadPageContents {
    // set individual properties
    pageBackgroundImg = @"alice_seiten_hintergrund.png";
    
    // text
    MediaDefinition *mDefWelcomeText = [MediaDefinition mediaDefinitionWithText:@"This page shows how to use the PianoLayer class."
                                                                           font:@"Courier New"
                                                                       fontSize:18
                                                                          color:ccBLACK
                                                                         inRect:CGRectMake(60, 700, 350, 100)];
    [mDefWelcomeText setZIndex:1000];
    [mediaObjects addObject:mDefWelcomeText];
    
    // setup the piano
    [piano addKeyWithImage:@"tasten_white__taste_white1.png" andRect:CGRectMake(241.5, 324, 67, 212)];
    [piano addKeyWithImage:@"tasten_black__taste_black1.png" andRect:CGRectMake(268.5, 358.5, 35, 137) onTop:YES];
    [piano addKeyWithImage:@"tasten_white__taste_white2.png" andRect:CGRectMake(301.5, 321, 67, 212)];
    [piano addKeyWithImage:@"tasten_black__taste_black2.png" andRect:CGRectMake(324, 356.5, 32, 137) onTop:YES];
    [piano addKeyWithImage:@"tasten_white__taste_white3.png" andRect:CGRectMake(356, 321, 76, 210)];
    [piano addKeyWithImage:@"tasten_white__taste_white4.png" andRect:CGRectMake(417, 322.5, 70, 213)];
    [piano addKeyWithImage:@"tasten_black__taste_black3.png" andRect:CGRectMake(444, 357.5, 32, 137) onTop:YES];
    [piano addKeyWithImage:@"tasten_white__taste_white5.png" andRect:CGRectMake(476, 319, 74, 208)];
    [piano addKeyWithImage:@"tasten_black__taste_black4.png" andRect:CGRectMake(512, 356.5, 32, 137) onTop:YES];
    [piano addKeyWithImage:@"tasten_white__taste_white6.png" andRect:CGRectMake(546.5, 320.5, 74, 208)];    
    [piano addKeyWithImage:@"tasten_black__taste_black5.png" andRect:CGRectMake(581, 356.5, 32, 137) onTop:YES];
    [piano addKeyWithImage:@"tasten_white__taste_white7.png" andRect:CGRectMake(611, 321, 74, 208)];    
    [piano addKeyWithImage:@"tasten_white__taste_white8.png" andRect:CGRectMake(678, 320, 74, 208)]; 
    [piano addKeyWithImage:@"tasten_black__taste_black6.png" andRect:CGRectMake(711, 356.5, 32, 137) onTop:YES];
    [piano addKeyWithImage:@"tasten_white__taste_white9.png" andRect:CGRectMake(740.5, 320.5, 74, 208)]; 
    [piano addKeyWithImage:@"tasten_black__taste_black7.png" andRect:CGRectMake(773, 356.5, 32, 137) onTop:YES];
    [piano addKeyWithImage:@"tasten_white__taste_white10.png" andRect:CGRectMake(805, 321, 74, 208)]; 
                              
    // add individual media objects for this page here
    [mediaObjects addObject:[MediaDefinition mediaDefinitionOfType:MEDIA_TYPE_PICTURE withValue:@"alice_example7__grafik_zettel.png" inRect:CGRectMake(511.5, 385.5, 865, 707)]];
    [mediaObjects addObject:[MediaDefinition mediaDefinitionOfType:MEDIA_TYPE_PICTURE withValue:@"alice_example7__noten.png" inRect:CGRectMake(720.5, 592.5, 241, 193)]];
    [mediaObjects addObject:[MediaDefinition mediaDefinitionOfType:MEDIA_TYPE_PICTURE withValue:@"alice_example7__text_titel.png" inRect:CGRectMake(789, 495, 230, 95)]];

    // common media objects will be loaded in the PageLayer
    [super loadPageContents];
}

- (void)displayContent {
    [piano performSelector:@selector(prepareAutoplay) withObject:nil afterDelay:kPianoAutoplayPreparationDelay];
    [piano performSelector:@selector(startAutoplay) withObject:nil afterDelay:kPianoAutoplayStartDelay];
    
    [super displayContent];
}

@end
