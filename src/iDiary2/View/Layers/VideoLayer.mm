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
//  IntroScene.mm
//  iDiary
//
//  Created by Markus Konrad on 24.01.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "VideoLayer.h"

#import "CoreHolder.h"

#import "Config.h"

@implementation VideoLayer


-(id) init {
	if( (self=[super init])) {
		self.isTouchEnabled = NO;
        self.isAccelerometerEnabled = NO;
	}
	
	return self;
}

- (void) dealloc {	
	[player release];
	[super dealloc];
	
	
}

-(BOOL)playVideo:(NSString *)video {    
    if (![[NSFileManager defaultManager] fileExistsAtPath:video]) {
        NSLog(@"No video at %@", video);
        return NO;
    }
    
    NSLog(@"Playing video: %@", video);
    
    // set up the movie player
    player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:video]];
    [player prepareToPlay];
    [player setFullscreen:YES];
    [player setShouldAutoplay:YES];

    if (kVideoShowControls) { 
        [player setControlStyle:MPMovieControlStyleFullscreen];
    } else {
        [player setControlStyle:MPMovieControlStyleNone];    
    }
    
    // display the movie player
    // added code to fix issue #1: not playing on iOS 6
   	CGSize screenSize = [CCDirector sharedDirector].winSize;
    CGFloat w = screenSize.width;
    CGFloat h = screenSize.height;
//    [player.view setBounds:CGRectMake(w/2, -h/2, w, h)];
    [player.view setFrame:CGRectMake((h-w)/2, (w-h)/2, w, h)];
    [player.view setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
    [[[CCDirector sharedDirector] openGLView] addSubview:player.view];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [player play];

    // add a notification handler thats called when the movie ends
    [[NSNotificationCenter defaultCenter] addObserver:[CoreHolder sharedCoreHolder]
                                             selector:@selector(videoLayerFinishedPlayback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    return YES;
}

- (void)stop {
    if (player == nil)
        return;
    
    [player stop];
    [[player view] removeFromSuperview];
    
    [player autorelease];   // "release" doesnt work!
    player = nil;
}

@end
