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
//  Page_Alice_Example5.m
//  iDiary2
//
//  Created by Markus Konrad on 13.06.12.
//  Copyright (c) 2012 INKA Forschungsgruppe. All rights reserved.
//

#import "Page_Alice_Example5.h"

#import "Makros.h"

@interface Page_Alice_Example5(PrivateMethods)

-(void)playerCrashed;

@end

@implementation Page_Alice_Example5

-(id)init {
    self = [super init];
    
    if (self) {
        // sounds
        [self addBackgroundSound:@"wind1.mp3" looped:YES startTime:0.25f];
        crashSndId = [self addFxSound:@"thunder1.mp3"];
    
        // create the game
        game = [[ScrollingRaceGame alloc] initOnPageLayer:self inRect:CGRectMake(60, 100, 1024 - 120, 768 - 100) obstaclesPerSecond:0.75f goodBadRatio:0.75f];
        
        // set the offset for the spawning of the obstacles
        [game setSpawnOffset:ccp(0, -300.0f)];
        
        // set callback for crash
        [game setCrashCallbackObj:self];
        [game setCrashCallbackMethod:@selector(playerCrashed)];
        
        // set game controls
        [game setControlsForLeft:@"alice_example5__button_li.png" pos:ccp(427, 85) andRight:@"alice_example5__button_re.png" pos:ccp(584, 87)];
        
        // set racer
        [game setRacer:@"alice_example5__player.png" pos:ccp(484, 389)];        // taken from http://en.opensuse.org/index.php?title=File:Icon-package.png&filetimestamp=20100615144104
        [game setRacerTail:@"alice_example5__playertail.png" offsetToRacer:ccp(57, 60)];
        
        // set obstacles: "good" (non-crashing) and "bad" ones
        [game setObstacle:@"alice_example5__wolke1.png" good:YES minScale:0.5f maxScale:1.2f];
        [game setObstacle:@"alice_example5__wolke2.png" good:YES minScale:0.5f maxScale:1.2f];
        [game setObstacle:@"alice_example5__wolke3.png" good:YES minScale:0.5f maxScale:1.2f];
        [game setObstacle:@"alice_example5__gewitter.png" good:NO minScale:0.5f maxScale:1.0f];    // iz bad!
        
        [self addChild:game z:1];
    }
    
    return self;
}

-(void)dealloc {
    [game release];

    [super dealloc];
}

#pragma mark parent methods

- (void)loadPageContents {
    // set individual properties
    pageBackgroundImg = @"alice_seiten_hintergrund.png";
    
    // text
    MediaDefinition *mDefWelcomeText = [MediaDefinition mediaDefinitionWithText:@"This page shows how to use the ScrollingRaceGame class."
                                                                           font:@"Courier New"
                                                                       fontSize:18
                                                                          color:ccBLACK
                                                                         inRect:CGRectMake(60, 700, 350, 100)];
    
    [mediaObjects addObject:mDefWelcomeText];
    
    // start game
    [game performSelector:@selector(startGame) withObject:nil afterDelay:0.25f];
    
    // common media objects will be loaded in the PageLayer
    [super loadPageContents];

}

#pragma mark private methods

-(void)playerCrashed {
    NSLog(@"Player crashed!");
    
    [[sndHandler getSound:crashSndId] playAtPitch:RAND_MIN_MAX(0.75f, 1.25f)];
}



@end
