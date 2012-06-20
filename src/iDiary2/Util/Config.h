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