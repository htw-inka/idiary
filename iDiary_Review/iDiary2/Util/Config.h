//
//  Config.h
//  iDiary
//
//  Created by Markus Konrad on 12.01.11.
//  Copyright INKA Forschungsgruppe 2011. All rights reserved.
//

#ifndef __CONFIG_H
#define __CONFIG_H

// DEBUG STUFF
#ifdef DEBUG
#define kDbgStartWithPageNum 0          // at this page index
#define kVideoShowControls YES          // show the video controls
#define kDbgDrawPhysics 0               // show physics lines and borders
#else
#define kVideoShowControls YES          // show the video controls
#define kDbgDrawPhysics 0
#endif

// MEMORY

#define kClearCacheThreshold 42     // in MB

// INTERACTION

#define kPlayButtonRadius 50

#define kPageTurnCornerW 175
#define kPageTurnCornerH 175
#define kPageTurnTapMaxDist 15
#define kPageTurnGestureMinDist 100
#define kPageTurnGestureMaxTime 0.75    // in seconds
#define kPageTurnGestureAngleTolerance 30.0f   // in degrees

#define kDefaultSnappingDistance 50
#define kDefaultSnappingDuration 0.25

// MODAL OVERLAY LAYER
#define kModalOverlayMarginX 20
#define kModalOverlayMarginY 20
#define kModalOverlayCloseBtnOffsetX -5
#define kModalOverlayCloseBtnOffsetY -5

// VIDEO

#ifndef kVideoShowControls
#define kVideoShowControls NO
#endif

// SOUND

#define kBGSoundVolume 0.3f
#define kFxSoundVolume 0.9f

// ANIMATIONS

#define kSpriteAnimFramesPerSecond 10

#define kGeneralFadeDuration 0.25f

#define kVideoFadeDuration 0.75f

#define kPageTurnDuration 0.25f
#define kPageCurlStrength 0.2f

#define kGeneralAnimationStartDelay 2.0f

#define kInteractiveElementsAnimStartDelay 0.75f
#define kInteractiveElementsScaleAnimDuration 0.5f
#define kInteractiveElementsScaleBy 1.15f
#define kInteractiveElementsAnimReplayInterval 5.0f

#define kPopUpAnimationDuration 0.5f

#define kOverviewBookAnimationDuration 1.0f
#define kOverviewPolaroidAnimationDuration 0.75f

// GRAPHICS

#ifndef DEBUG
#define kOpenGLMultisampling 2
#else
#define kOpenGLMultisampling 0
#endif

#define kGlowBorderSize 40      // set to 0 to disable
#define kGlowAnimDur 2.0f
#define kGlowOpacityMin 50
#define kGlowOpacityMax 250
#define kGlowColor ccWHITE             //ccc3(116, 70, 106)

//
// Supported Autorotations:
//		None,
//		UIViewController,
//		CCDirector
//
#define kGameAutorotationNone 0
#define kGameAutorotationCCDirector 1
#define kGameAutorotationUIViewController 2

//
// Define here the type of autorotation that you want for your game
//
#define GAME_AUTOROTATION kGameAutorotationUIViewController


#endif // __CONFIG_H