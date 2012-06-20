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
//  ArrangeGameLayer.h
//  iDiary2
//
//  Created by Markus Konrad on 25.07.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "cocos2d.h"

#import "PageLayer.h"
#import "SoundHandler.h"

@class ArrangeableObject;
@class TargetArea;

// Defines a group for target areas with an identifier and success sounds
@interface TargetGroup : NSObject {
    NSString *identifier;       // identifier for this group 
    
    int successSndId;           // success sound id
    SoundObject *successSnd;    // success sound object
    
    int unsuccessSndId;           // unsuccess sound id
    SoundObject *unsuccessSnd;    // unsuccess sound object
    
    NSMutableArray *areas;      // array with TargetArea objects
    
    NSMutableDictionary *noMatchConditions;  // dictionary with NSString image1 to NSString image2 mapping
    
    id magneticDistReachedTarget;    // object on which inMagneticDistAction is called when an object has entered the magnetic distance of a target
    SEL magneticDistReachedAction;   // action that is called when an object  has entered the magnetic distance of a target
    
    id magneticDistLeftTarget;    // object on which inMagneticDistAction is called when an object has left the magnetic distance of a target
    SEL magneticDistLeftAction;   // action that is called when an object has left the magnetic distance of a target
    
    id objectMatchedTarget;     // object on which objectMatchedTarget is called when an object was correctly arranged
    SEL objectMatchedAction;    // action that is called when an object was correctly arranged
    
    id successActionTarget;     // object on which successAction is called on game succcess
    SEL successAction;          // action that is called on game succcess
    
    id unsuccessActionTarget;
    SEL unsuccessAction;
    
    BOOL wasCompleted;          // is YES when this group has been solved
    
    NSArray *arrangeableObjects;    // all arrangeable objects from ArrangeGameLayer
}

@property (nonatomic,readonly) NSString *identifier;
@property (nonatomic,readonly) int successSndId;
@property (nonatomic,readonly) SoundObject *successSnd;
@property (nonatomic,readonly) int unsuccessSndId;
@property (nonatomic,readonly) SoundObject *unsuccessSnd;
@property (nonatomic,readonly) NSMutableArray *areas;
@property (nonatomic,readonly) id magneticDistReachedTarget;
@property (nonatomic,readonly) SEL magneticDistReachedAction;
@property (nonatomic,readonly) id magneticDistLeftTarget;
@property (nonatomic,readonly) SEL magneticDistLeftAction;
@property (nonatomic,readonly) id objectMatchedTarget;
@property (nonatomic,readonly) SEL objectMatchedAction;
@property (nonatomic,readonly) id successActionTarget;
@property (nonatomic,readonly) SEL successAction;
@property (nonatomic,assign) BOOL wasCompleted;
@property (nonatomic,readonly) NSMutableDictionary *noMatchConditions;
@property (nonatomic,assign) NSArray *arrangeableObjects;

-(id)initWithIdentifier:(NSString *)pIdentifier successSound:(NSString *)successSndFile successTarget:(id)successTarget successAction:(SEL)successAct;
-(id)initWithIdentifier:(NSString *)pIdentifier successSound:(NSString *)successSndFile successTarget:(id)successTarget successAction:(SEL)successAct unsuccessSound:(NSString *)unsuccessSndFile;
-(void)setMagneticDistReachedTarget:(id)target action:(SEL)action;
-(void)setMagneticDistLeftTarget:(id)target action:(SEL)action;
-(void)setObjectMatchedTarget:(id)target action:(SEL)action;
-(BOOL)conditionsOkayForObject:(ArrangeableObject *)obj;
-(BOOL)targetIsCompleted:(TargetArea *)target;
-(BOOL)targetArea:(TargetArea *)area canByMatchedByIdentifier:(NSString *)matchId;

@end


// Defines a target area to which a arrangable object can match.
@class ArrangeableObject;
@interface TargetArea : NSObject {
    NSString *identifier;               // identifier to which an arrangable object must match. retained
    CGPoint targetPoint;                // this is where the arrangeable object must come to.
    CCSprite *sprite;                   // sprite to display (optional - can be "nil). must not match "targetPoint" but usualy does. retained.
    ArrangeableObject *matchedBy;       // is set to the object that currently matches this area or is nil (weak ref)
}

@property (nonatomic,readonly) NSString *identifier;
@property (nonatomic,readonly) CGPoint targetPoint;
@property (nonatomic,readonly) CCSprite *sprite;
@property (nonatomic,assign) ArrangeableObject *matchedBy;

// init a new TargetArea
-(id)initWithIdentifier:(NSString *)pIdentifier targetPoint:(CGPoint)pTargetPoint sprite:(CCSprite *)pSprite;

@end

// Defines an arrangable object that can match to a TargetArea.
@interface ArrangeableObject : NSObject {
    NSString *identifier;               // identifier for this object. usually the name of the image file for the sprite
    NSArray *matchingTargets;           // array of NSStrings with idenfiers of matching TargetAreas
    CCSprite *sprite;                   // sprite to display. retained.
    CGPoint beginPos;                   // initial position
    CGFloat beginRot;                   // initial rotation
    CGPoint targetOffset;               // offset when laying on the target
    TargetArea *matchedTarget;          // is set to the area to which this object currently matches or is nil (weak ref)
    BOOL isInMagneticDist;              // is YES if this object is in the magnetic distance of a target area
    BOOL isValid;                       // is YES if this object can complete a target
}

@property (nonatomic,retain) NSString *identifier;
@property (nonatomic,readonly) CCSprite *sprite;
@property (nonatomic,readonly) NSArray *matchingTargets;
@property (nonatomic,assign) TargetArea *matchedTarget;
@property (nonatomic,assign) BOOL isInMagneticDist;
@property (nonatomic,assign) BOOL isValid;
@property (nonatomic,assign) CGPoint beginPos;
@property (nonatomic,assign) CGFloat beginRot;
@property (nonatomic,assign) CGPoint targetOffset;

// init a new ArrangeableObjects.
// "pMatchingTargets" contains NSStrings with identifiers for TargetAreas
-(id)initWithIdentifier:(NSString *)pIdentifier matchingTargets:(NSArray *)pMatchingTargets sprite:(CCSprite *)pSprite beginPos:(CGPoint)pPos isValid:(BOOL)pIsValid;
-(id)initWithIdentifier:(NSString *)pIdentifier matchingTargets:(NSArray *)pMatchingTargets sprite:(CCSprite *)pSprite beginPos:(CGPoint)pPos;

// ArrangeableObject is informed that it got selected
-(void)gotSelected;

@end

// Base class for "arrange games" for movable things like letters, countries, etc.
// Should be subclassed for special cases.
@interface ArrangeGameLayer : CCLayer {
    SoundHandler *sndHandler;          // shortcut to sound handler singleton

    PageLayer *pageLayer;               // page on which this game is running (weak ref)    
    
    NSMutableDictionary *targetGroups;      // dictionary with group identifier -> TargetGroup mapping
    NSMutableArray *arrangableObjects;      // array with ArrangeableObjects objects
    
    ArrangeableObject *selectedObject;    // ArrangeableObject that is currently moved or "nil" (weak ref)
    
    float magneticDist;     // distance for magnetic snapping
    
    int targetAreaZ;        // z index of last added target area
    int arrangableObjectsZ; // z index of last added ArrangeableObject
    
    BOOL moveObjectsToStartPosOnNoMatch;    // move an arrangable object to its start position if it does not match to the target
    
    BOOL isActive; // YES if sprites can be moved around, otherwise NO
    
    BOOL pageLayerIsSpriteParent; // if set to YES, then all arrangable objects will be children of the pageLayer, NOT of the ArrangeGameLayer itself
    
    BOOL allowMovingOfAlreadyMatchedObjects;    // if set to YES, then already matched objects can be moved out of the target zone again. default is YES
}

@property (nonatomic,readonly) NSArray *arrangableObjects;
@property (nonatomic,readonly) NSDictionary *targetGroups;
@property (nonatomic,assign) BOOL moveObjectsToStartPosOnNoMatch;
@property (nonatomic,assign) BOOL isActive;
@property (nonatomic,assign) float magneticDist;
@property (nonatomic,assign) int targetAreaZ;
@property (nonatomic,assign) int arrangableObjectsZ;
@property (nonatomic,assign) BOOL pageLayerIsSpriteParent;
@property (nonatomic,assign) BOOL allowMovingOfAlreadyMatchedObjects;

// initialize on page layer with a magnetic distance for the snapping to the targets
-(id)initOnPageLayer:(PageLayer *)layer withMagneticDistance:(float)pMagnDist targetAreaZBegin:(int)targetAreaZBegin arrangableObjectsZBegin:(int)arrangableObjectsZBegin;

// create a new group
-(TargetGroup *)addGroup:(NSString *)identifier successSound:(NSString *)successSndFile successTarget:(id)target successAction:(SEL)successAction;
-(TargetGroup *)addGroup:(NSString *)identifier successSound:(NSString *)successSndFile successTarget:(id)target successAction:(SEL)successAction unsuccessSound:(NSString *)unsuccessSndFile;

// add a new target area with a identifier, target point and sprite (optional)
// returns the created TargetAreas as autoreleased object
-(TargetArea *)addTargetArea:(NSString *)identifier targetPoint:(CGPoint)targetPoint toGroup:(NSString *)groupIdentifier;
-(TargetArea *)addTargetArea:(NSString *)identifier targetPoint:(CGPoint)targetPoint toGroup:(NSString *)groupIdentifier image:(NSString *)image pos:(CGPoint)pos;

// add a new arrangable object that matches to a TargetArea via identfier.
// "matchingTargets" containts NSStrings with TargetArea identifiers
-(ArrangeableObject *)addArrangableObject:(NSString *)image pos:(CGPoint)pos matchingTo:(NSArray *)matchingTargets;
-(ArrangeableObject *)addArrangableObject:(NSString *)image pos:(CGPoint)pos matchingTo:(NSArray *)matchingTargets isValid:(BOOL)isValid;
-(ArrangeableObject *)addArrangableObject:(NSString *)image pos:(CGPoint)pos matchingTo:(NSArray *)matchingTargets isValid:(BOOL)isValid addAsChildrenToParentNode:(CCNode *)parentNode;

// set a matching object to a target area
-(void)setMatchingObject:(ArrangeableObject *)obj toTarget:(NSString *)targetIdentifier inGroup:(NSString *)groupIdentifier;

// add a "no-match" condition for a group
// img2 can not be matched if img1 has already matched or vice versa
-(void)addNoMatchConditionForGroup:(NSString *)grp image1:(NSString *)img1 image2:(NSString *)img2;

// shuffle all arrangable objects
-(void)shuffleArrangableObjects;

// add all arrangable objects to a node
-(void)addAllArrangableObjectsToNode:(CCNode *)node;

@end
