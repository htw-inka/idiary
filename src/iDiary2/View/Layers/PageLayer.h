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
//  PageLayer.h
//  iDiary2
//
//  Created by Markus Konrad on 02.05.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"

#import "Box2DWorldHolder.h"
#import "ContentElement.h"
#import "MediaDefinition.h"
#import "SoundHandler.h"
#import "BookControl.h"
#import "CoreHolder.h"

@class ContentElement;
@class CoreHolder;

// Touch type definitions
typedef enum {
    kTouchTypeTap = 0,
    kTouchTypeMove
} TouchType;

// Defines a background sound with an audio file, start time and duration
@interface BackgroundSound : NSObject {
    NSString *file;             // audio file
    BOOL looped;                // loop the sound file
    NSTimeInterval startTime;   // start time in seconds after the page has been completely turned
    NSTimeInterval duration;    // duration in seconds. if this is 0, then it will loop infinitely
}

@property (nonatomic,retain) NSString *file;
@property (nonatomic,assign) BOOL looped;
@property (nonatomic,assign) NSTimeInterval startTime;
@property (nonatomic,assign) NSTimeInterval duration;

@end

@class PageMainLayer;
@class BookControl;

// This class is an abstract class that represents a single page of a diary.
// It offers common methods for all individual diary pages.
// Parent classes of PageLayer are found in the folder "Pages" and are named like "Page_Adam_Sukkot"
@interface PageLayer : CCLayer<SoundHandlerDelegate> {
    CoreHolder *core;   // shortcut to singleton of Core
    
    SoundHandler *sndHandler;   // shortcut to singleton of SoundHandler
    
    PageMainLayer *mainLayer;   // PageMainLayer in which this page sits
    
    BookControl *bookControl;   // class that handles page swipes

    int curPage;    // current page number. set in CoreHolder
    int maxPage;    // maximum page number (= absolute number of available page for that person). set in CoreHolder
    
    int highestZOrder;  // highest Z order index for interactive elements
    
    NSString *person;   // person to which this page belongs. set in CoreHolder
    NSString *pageName; // page name of the current page index. set in CoreHolder
    
    NSMutableArray *mediaObjects;   // NSMutableArray of type MediaDefinition. Will be set in parent page class
    NSString *pageBackgroundImg;       // background image of the page. Will be set in parent page class
    NSMutableArray *backgroundSounds;   // NSMutableArray with BackgroundSound objects
    NSMutableArray *soundObjectIds;   // NSMutableArray with NSNumbers with sound ids that exist on this page
    
    BOOL enablePhysics;             // use physics on this page? Will be set in parent page class
    b2dWorldType physicsWorldType;  // the world type if enablePhysics is true
    
    ContentElement *activeContentElement;   // content element that is currently selected (touched)
    
    NSMutableArray *interactiveElements;    // NSMutableArray with CCNode objects that are interactive (and have a glow effect)
    NSMutableArray *persistentElements;     // NSMutableArray with id<PageElementPersistencyProtocol> objects that can be saved and loaded
    NSMutableArray *animationElements;      // NSMutableArray with ContentElement objects that are of the type MEDIA_TYPE_ANIM
    
    NSMutableArray *touchCallbacksTap; // NSMutableArray for taps with NSArrays with each consisting of (SEL)selector, (NSObject *)object, (NSObject *)parameterObject
    NSMutableArray *touchCallbacksMove; // NSMutableArray for moves with NSArrays with each consisting of (SEL)selector, (NSObject *)object, (NSObject *)parameterObject
    
    Box2DWorldHolder *box2D;                // Shortcut to Box2D world holder singleton
    b2dWorldAttributes *box2DWorldAttribs;  // Attributes for this box2d world
    
    float physicsUpdateInterval;    // update interval for box2d-ticks in seconds
    
    NSMutableArray *glowSprites;    // glow sprites: array with CCSprites with glow effect
    
    NSMutableArray *registeredSpriteFrames; // sprite frame files that are loaded. is used for cleanup later
    
    BOOL highlightInteractiveElementsEnabled;   // is YES if the highlightInteractiveElements animation shall be displayed
    
    BOOL pageAlreadyGoneInvisble;   // is YES if pageGoneInvisible was already called
    
    BOOL isRestoredFromPersistentData;  // is YES if this page will be / was restored from persistent data
}

@property (nonatomic,readonly) b2dWorldAttributes *box2DWorldAttribs;
@property (nonatomic,assign) int curPage;
@property (nonatomic,assign) int maxPage;
@property (nonatomic,assign) int highestZOrder;
@property (nonatomic,retain) NSString *person;
@property (nonatomic,retain) NSString *pageName;
@property (nonatomic,retain) NSString *pageBackgroundImg;
@property (nonatomic,readonly) NSMutableArray *glowSprites;
@property (nonatomic,readonly) NSArray *persistentElements;
@property (nonatomic,readonly) NSMutableArray *interactiveElements;
@property (nonatomic,assign) BOOL highlightInteractiveElementsEnabled;
@property (nonatomic,assign) BOOL isRestoredFromPersistentData;

// initialize with enabled physics
- (id)initWithEnabledPhysicsOfType:(b2dWorldType)worldType;

// fill the mediaObjects array with MediaDefinition objects. Will be called in CoreHolder after initialization of the parent PageLayer object
- (void)loadPageContents;

// Register a callback selector for a ContentElement, thats called after
// a single tap occured on this ContentElement
- (void)registerTouchOfType:(TouchType)type withCallback:(SEL)selector onObject:(NSObject *)object withParameterObject:(NSObject *)parameterObject;

// removes all registered touch callbacks and removes all children elements
- (void)clearState;

// Display the content for the given key and page
- (void)displayContent;

// Add an effect sound to this page and return the sound id
- (int)addFxSound:(NSString *)soundFile;

// register a persistent page element
-(void)registerPersistentElement:(id<PageElementPersistencyProtocol>)elem;

// Add a background sound that will be played "startTime" seconds after page turn is complete
- (void)addBackgroundSound:(NSString *)soundFile looped:(BOOL)looped startTime:(CFTimeInterval)startTime;
- (void)addBackgroundSound:(NSString *)soundFile looped:(BOOL)looped startTime:(CFTimeInterval)startTime duration:(CFTimeInterval)duration;

// This method is called by PageMainLayer when the page turn is complete and the page is fully visible
- (void)pageTurnComplete;

// This method is called by PageMainLayer when the page has been turned over and is NOT visible any more
- (void)pageGoneInvisible;

// cancel the ongoing highlight animations
- (void)cancelHighlightAnimations;

// register a loaded sprite frame. is used for cleanup later
- (void)registerSpriteFrame:(NSString *)frameFile;

// update physics
- (void)tick:(ccTime)dt;

- (CoreHolder *)core;
@end
