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

    [player setFullscreen:YES];
    [player setShouldAutoplay:YES];

    if (kVideoShowControls) { 
        [player setControlStyle:MPMovieControlStyleFullscreen];
    } else {
        [player setControlStyle:MPMovieControlStyleNone];    
    }
    
    // display the movie player
   	CGSize screenSize = [CCDirector sharedDirector].winSize;
    [player.view setFrame: CGRectMake(0, 0, screenSize.width, screenSize.height)];
    [[[CCDirector sharedDirector] openGLView] addSubview:player.view];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

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
