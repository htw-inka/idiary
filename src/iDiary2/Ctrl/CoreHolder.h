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
//  CoreHolder.h
//  InterviewStation
//
//  Created by Markus Konrad on 23.03.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OverviewLayer.h"
#import "StartscreenLayer.h"
#import "PageLayer.h"
#import "PageMainLayer.h"
#import "VideoLayer.h"
#import "PanningLayer.h"
#import "ModalOverlay.h"

// Load diary definitions for this target
#ifdef DIARIES_HEADER
#import DIARIES_HEADER
#else
#define DIARY_LAUNCHER
#endif

// Application status types
typedef enum {
    kAppStateUninitialized = 0,     // right at the beginning, this status is set
    kAppStateStartscreenShowing,    // when the startscreen for a person is shown
    kAppStateVideoPlaying,          // when a video is playing
    kAppStatePageShowing            // when a diary page is shown
} appStateType;


// Forward declarations

@class ModalOverlay;

// Core Holder class is a singleton class that implements the overall application behavior.
// The public methods react to events like incomming RFID messages or video selection by the user.
// All scenes and layers are created only once at the CoreHolder initialization method.
@interface CoreHolder : NSObject {
@private
    CCDirector *director;       // shortcut to the CCDirector
    CCScene *currentScene;      // the scene that is currently active
    CCLayer *currentMainLayer;  // the main layer (OverviewLayer, PageLayer or VideoLayer) that is currently active
    
    ModalOverlay *currentModalOverlay;   // modal overlay layer or nil
    
    NSArray *persistentPageElements;    // save data that will be loaded after a video has been played
    
    NSArray *curPersonMetaData;    // meta data for current person
    
    NSString *currentPerson;    // the selected person
    NSString *currentPageName;  // the selected page name
    int currentPageNum;         // the selected page index (beginning with 0)
    int maxPageNum;             // the maximum page index
    
    appStateType appState;      // the current app state. see appStateType
    
    int screenW;            // screen width (normally 1024 on iPad)
    int screenH;            // screen height (normally 768 on iPad)
    CGPoint screenCenter;   // screen center point
    
    NSString *scheduledPerson;  // this person's diary will be shown after a video has ended
    int scheduledPageNum;       // this page number of the diary will be shown after a video has ended
    
    PageLayer *currentPageLayer;  // PageLayer object that is currently shown  
    PageLayer *otherPageLayer;    // PageLayer object for the next or the previous page
    
    BOOL allowPageTurn;             // enable / disable page navigation
}

@property (nonatomic,readonly) NSString *currentPerson;
@property (nonatomic,readonly) NSString *currentPageName;
@property (nonatomic,readonly) int currentPageNum;
@property (nonatomic,readonly) int maxPageNum;
@property (nonatomic,readonly) CCLayer *currentMainLayer;
@property (nonatomic,readonly) int screenW;
@property (nonatomic,readonly) int screenH;
@property (nonatomic,readonly) CGPoint screenCenter;
@property (nonatomic,readonly) BOOL allowPageTurn;
@property (nonatomic,assign) BOOL interactiveObjectWasTouched;
@property (nonatomic,readonly) NSArray *curPersonMetaData;
@property (nonatomic,assign) BOOL startedFromLauncher;

// Create / retrieve singleton object
+ (CoreHolder*)sharedCoreHolder;

// called upon first start
- (void)firstStart;

// show a modal overlay
- (void)showModalOverlay:(NSString *)overlayFile background:(NSString *)backgroundFile;
- (void)closeModalOverlay;

#ifndef DIARY_LAUNCHER
// switch to overview
- (void)showOverview:(id)sender;

// will show the start screen (desk of the person)
- (void)showStartscreen:(id)sender;

// show a video
- (void)showVideo:(NSString *)file;

// called when a person has been selected on the overview layer
- (void)selectedPerson:(NSString *)pPerson;

// called when the diary in the startscreen for the person has been selected
- (void)enterCurrentPersonsDiary;

// return a page name from the diary page at pageNum for the person
- (NSString *)getPageNameAtIndex:(int)pageNum forPerson:(NSString *)person;

// display the previous page of the current person
- (void)showPrevPage:(id)sender;

// display the next page of the current person
- (void)showNextPage:(id)sender;

// show a page layer with a given key and page using a turn direction: -1 is back, +1 is forward, 0 is "no page turn"
//- (void)showPageLayerWithKey:(NSString *)key andPage:(int)page usingPageTurn:(int)turnDir;

// called when a movie in the VideoLayer finished
- (void)videoLayerFinishedPlayback:(NSNotification *)notification;

// schedules an action that will be performed after a video has been showed: show this same diary again
- (void)scheduleAfterVideoPlaybackReturnToSameDiary;

// schedules an action that will be performed after a video has been showed: show this person on this page
- (void)scheduleAfterVideoPlaybackPerson:(NSString *)pPerson andPage:(int)page;

// Called by a PageLayer when it is fully loaded
- (void)pageTurnCompleted;

// go back to diary launcher app
- (void)switchToDiaryLauncher;

#endif

@end
