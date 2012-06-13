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
