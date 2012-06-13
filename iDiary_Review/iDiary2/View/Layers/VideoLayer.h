//
//  VideoLayer.h
//  iDiary
//
//  Created by Markus Konrad on 24.01.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "cocos2d.h"


// VideoLayer plays a video in fullscreen
@interface VideoLayer : CCLayer {
    MPMoviePlayerController* player;
}

// Play a video in fullscreen
- (BOOL)playVideo:(NSString *)video;

// Stop showing the video and release the player
- (void)stop;


@end
