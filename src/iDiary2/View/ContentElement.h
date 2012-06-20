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
//  ContentElement.h
//  iDiary
//
//  Created by Markus Konrad on 12.01.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "cocos2d.h"

#import "MediaDefinition.h"
#import "PageElementPersistency.h"
#import "PageLayer.h"
#import "PhySprite.h"

@class PageLayer;

/*!
 @class ContentElement
 @abstract ContentElement is a general media element, with attributes taken from
 the MediaDefinition. Depending on the media type there are different visual representations
 stored in the displayNode property as a CCNode object.
 Add a ContentElement to your display graph by using [<your CCLayer object> addChild:<ContentElement object>];
 */
@interface ContentElement : NSObject <PageElementPersistencyProtocol> {
    MediaDefinition *mediaDef;  // media definition for this ContentElement (weak ref)
    CCNode *displayNode;        // view representation for this ContentElement
    PageLayer *pageLayer;       // the PageLayer on which this ContentElement occurs (weak ref)
    
    CCAnimation *anim;          // contains the animation object if type is MEDIA_TYPE_ANIM or nil
    
    BOOL isInteractive;         // is this an interactive element?
    BOOL isMovable;             // is this a movable element?
    physicalBehaviorType physicalBehavior;           // defines a physical behavior for this element
}


@property (readonly, nonatomic) MediaDefinition *mediaDef;
@property (readonly, nonatomic) CCNode *displayNode;
@property (readonly, nonatomic) CCAnimation *anim;
@property (readonly, nonatomic) BOOL isInteractive;
@property (readonly, nonatomic) BOOL isMovable;
@property (readonly, nonatomic) physicalBehaviorType physicalBehavior;
@property (assign, nonatomic) BOOL restoreOriginalAnimFrame;

// Get an autoreleased ContentElement from a MediaDefinition object
+ (ContentElement *)contentElementForMediaDefintion:(MediaDefinition *)pMediaDef;

//Get an autoreleased ContentElement from a MediaDefinition object for a specific PageScene.
+ (ContentElement *)contentElementOnPageLayer:(PageLayer *)pPageLayer forMediaDefintion:(MediaDefinition *)pMediaDef;

//Initialize a ContentElement with a MediaDefinition object
- (id)initWithMediaDefinition:(MediaDefinition *)pMediaDef;

//Initialize a ContentElement with a MediaDefinition object for a specific PageScene.
- (id)initWithMediaDefinition:(MediaDefinition *)pMediaDef andPageLayer:(PageLayer *)pPageLayer;

// play a video
- (void)playVideo:(NSString *)file;

// play a sound effect
- (void)playAudio:(NSNumber *)soundId;

// start an animation
- (void)startAnimationLooped:(NSNumber *)looped;
- (void)startAnimationWithCallbackAtEnd:(SEL)endCallback atObject:(id)endObj;
- (void)startAnimationBackwardsWithCallbackAtEnd:(SEL)endCallback atObject:(id)endObj;

// move a CCNode
- (void)moveNode:(NSValue *)newPos;

@end
