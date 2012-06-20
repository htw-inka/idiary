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
//  ArrangeGameLayer.mm
//  iDiary2
//
//  Created by Markus Konrad on 25.07.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "ArrangeGameLayer.h"

#import "Tools.h"
#import "Config.h"
#import "ManikinLayer.h"

#pragma mark ---
#pragma mark TargetGroup implementation
#pragma mark ---

@implementation TargetGroup

@synthesize identifier;
@synthesize successSndId;
@synthesize successSnd;
@synthesize unsuccessSndId;
@synthesize unsuccessSnd;
@synthesize areas;
@synthesize noMatchConditions;
@synthesize successActionTarget;
@synthesize successAction;
@synthesize magneticDistReachedTarget;
@synthesize magneticDistReachedAction;
@synthesize magneticDistLeftTarget;
@synthesize magneticDistLeftAction;
@synthesize objectMatchedTarget;
@synthesize objectMatchedAction;
@synthesize wasCompleted;
@synthesize arrangeableObjects;

-(id)initWithIdentifier:(NSString *)pIdentifier successSound:(NSString *)successSndFile successTarget:(id)successTarget successAction:(SEL)successAct unsuccessSound:(NSString *)unsuccessSndFile {
    self = [super init];
    if (self) {
        // set defaults
        identifier = [pIdentifier retain];
        areas = [[NSMutableArray alloc] init];
        successActionTarget = successTarget;
        successAction = successAct;
        wasCompleted = NO;
        successSndId = -1;
        unsuccessSndId = -1;
        noMatchConditions = [[NSMutableDictionary alloc] init];
        
        // load and get sound
        SoundHandler *sndHandler = [SoundHandler shared];
        
        if (successSndFile) {
            successSndId = [sndHandler registerSoundToLoad:successSndFile looped:NO gain:kFxSoundVolume];
        }
        
        if (unsuccessSndFile) {
            unsuccessSndId = [sndHandler registerSoundToLoad:unsuccessSndFile looped:NO gain:kFxSoundVolume];
        }
        
        if (successSndId != -1 || unsuccessSndId != -1) {
            [sndHandler loadRegisteredSounds];
            
            unsuccessSnd = [[sndHandler getSound:unsuccessSndId] retain];
            successSnd = [[sndHandler getSound:successSndId] retain];
        }
    }
    
    return self;    
}

-(id)initWithIdentifier:(NSString *)pIdentifier successSound:(NSString *)successSndFile successTarget:(id)successTarget successAction:(SEL)successAct {
    return [self initWithIdentifier:pIdentifier successSound:successSndFile successTarget:successTarget successAction:successAction unsuccessSound:nil];
}

-(void)dealloc {
    [noMatchConditions release];
    [identifier release];
    [areas release];

    // success sound
    [[SoundHandler shared] unloadSound:successSndId];
    [successSnd release];
    [[SoundHandler shared] unloadSound:unsuccessSndId];
    [unsuccessSnd release];

    [super dealloc];
}

-(void)setMagneticDistReachedTarget:(id)target action:(SEL)action {
    magneticDistReachedTarget = target;
    magneticDistReachedAction = action;
}

-(void)setMagneticDistLeftTarget:(id)target action:(SEL)action {
    magneticDistLeftTarget = target;
    magneticDistLeftAction = action;
}

-(void)setObjectMatchedTarget:(id)target action:(SEL)action {
    objectMatchedTarget = target;
    objectMatchedAction = action;
}

-(BOOL)conditionsOkayForObject:(ArrangeableObject *)obj {
    if ([noMatchConditions count] == 0) {
        return YES;
    }
    
    for (NSString *img1 in noMatchConditions) {
        NSString *img2 = [noMatchConditions objectForKey:img1];
        
        if ([img1 isEqualToString:obj.identifier]) {
            for (TargetArea *area in areas) {
                if ([img2 isEqualToString:area.matchedBy.identifier]) {
                    NSLog(@"NoMatchCondition is YES for %@ and %@", img1, img2);
                    return NO;
                }
            }
        }
        
        if ([img2 isEqualToString:obj.identifier]) {
            for (TargetArea *area in areas) {
                if ([img1 isEqualToString:area.matchedBy.identifier]) {
                    NSLog(@"NoMatchCondition is YES for %@ and %@", img1, img2);
                    return NO;
                }
            }
        }
    }
    
    return YES;
}

-(BOOL)targetIsCompleted:(TargetArea *)target {
    // simple without conditions:
    if ([noMatchConditions count] == 0) {
        return (target.matchedBy != nil);
    } else {    // more complex with conditions:
        if (target.matchedBy) return YES;
        
        // the target has not been matched, but maybe it cannot be matched
        // because of noMatchConditions!
        for (NSString *img1 in noMatchConditions) {
            NSString *img2 = [noMatchConditions objectForKey:img1];
            
            if ([self targetArea:target canByMatchedByIdentifier:img2]) {
                for (TargetArea *area in areas) {
                    if ([img1 isEqualToString:area.matchedBy.identifier]) {
                        return YES;
                    }
                }
            }
        }
        
        return NO;
    }
}

-(BOOL)targetArea:(TargetArea *)area canByMatchedByIdentifier:(NSString *)matchId {
    NSString *areaId = area.identifier;

    for (ArrangeableObject *obj in arrangeableObjects) {
        if ([obj.identifier isEqualToString:matchId]) {
            for (NSString *possibleMatchId in obj.matchingTargets) {
                if ([areaId isEqualToString:possibleMatchId]) {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

@end

#pragma mark ---
#pragma mark TargetArea implementation
#pragma mark ---

@implementation TargetArea

@synthesize identifier;
@synthesize targetPoint;
@synthesize sprite;
@synthesize matchedBy;

-(id)initWithIdentifier:(NSString *)pIdentifier targetPoint:(CGPoint)pTargetPoint sprite:(CCSprite *)pSprite {
    self = [super init];
    if (self) {
        // set defaults
        identifier = [pIdentifier retain];
        targetPoint = pTargetPoint;
        sprite = [pSprite retain];
    }
    
    return self;    
}

-(void)dealloc {
    [identifier release];
    [sprite release];

    [super dealloc];
}

@end

#pragma mark ---
#pragma mark ArrangeableObject implementation
#pragma mark ---

@implementation ArrangeableObject

@synthesize identifier;
@synthesize sprite;
@synthesize matchingTargets;
@synthesize matchedTarget;
@synthesize isInMagneticDist;
@synthesize isValid;
@synthesize beginPos;
@synthesize beginRot;
@synthesize targetOffset;

-(id)initWithIdentifier:(NSString *)pIdentifier matchingTargets:(NSArray *)pMatchingTargets sprite:(CCSprite *)pSprite beginPos:(CGPoint)pPos isValid:(BOOL)pIsValid {
    if (self) {
        // set defaults
        identifier = [pIdentifier retain];
        matchingTargets = [pMatchingTargets retain];
        sprite = [pSprite retain];
        beginPos = pPos;
        isValid = pIsValid;
    }
    
    return self;  
}

-(id)initWithIdentifier:(NSString *)pIdentifier matchingTargets:(NSArray *)pMatchingTargets sprite:(CCSprite *)pSprite beginPos:(CGPoint)pPos {
    return [self initWithIdentifier:pIdentifier matchingTargets:pMatchingTargets sprite:pSprite beginPos:pPos isValid:YES];
}

-(void)dealloc {
    [matchingTargets release];
    [sprite release];
    
    [super dealloc];
}

-(void)setBeginPos:(CGPoint)pBeginPos {
    beginPos = pBeginPos;
    [sprite setPosition:pBeginPos];
}

-(void)setBeginRot:(CGFloat)pBeginRot {
    beginRot = pBeginRot;
    [sprite setRotation:pBeginRot];
}

-(void)gotSelected {

}

@end

#pragma mark ---
#pragma mark ArrangeGameLayer implementation
#pragma mark ---

@interface ArrangeGameLayer(PrivateMethods)

// called when a group is completed
-(void)groupCompleted:(TargetGroup *)grp;
// checks if a group contains invalid arrangable objects and returns an array of these invalid objects or nil
-(NSMutableArray *)groupContainsInvalidArrangableObjects:(TargetGroup *)grp;
// will move the ArrangeableObject back to the begin position
-(void)moveBackArrangeableObject:(ArrangeableObject *)obj;

@end

@implementation ArrangeGameLayer

@synthesize arrangableObjects;
@synthesize targetGroups;
@synthesize moveObjectsToStartPosOnNoMatch;
@synthesize isActive;
@synthesize magneticDist;
@synthesize targetAreaZ;
@synthesize arrangableObjectsZ;
@synthesize pageLayerIsSpriteParent;
@synthesize allowMovingOfAlreadyMatchedObjects;

#pragma mark init/dealloc

-(id)initOnPageLayer:(PageLayer *)layer withMagneticDistance:(float)pMagnDist targetAreaZBegin:(int)targetAreaZBegin arrangableObjectsZBegin:(int)arrangableObjectsZBegin; {
    self = [super init];
    if (self) {
        // set defaults
        sndHandler = [SoundHandler shared];
        
        pageLayer = layer;
        
        magneticDist = pMagnDist;
        targetAreaZ = targetAreaZBegin;
        arrangableObjectsZ = arrangableObjectsZBegin;
        
        moveObjectsToStartPosOnNoMatch = NO;
        pageLayerIsSpriteParent = NO;
        allowMovingOfAlreadyMatchedObjects = YES;
        
        // init containers
        targetGroups = [[NSMutableDictionary alloc] init];
        arrangableObjects = [[NSMutableArray alloc] init];
        
        // enable touches
        [self setIsTouchEnabled:YES];
        
        self.isActive = YES;
    }
    
    return self;
}

-(void)dealloc {
    [targetGroups release];
    [arrangableObjects release];
    
    [super dealloc];
}

#pragma mark public methods

-(TargetArea *)addTargetArea:(NSString *)identifier targetPoint:(CGPoint)targetPoint toGroup:(NSString *)groupIdentifier {
    return [self addTargetArea:identifier targetPoint:targetPoint toGroup:groupIdentifier image:nil pos:CGPointZero];
}

-(TargetArea *)addTargetArea:(NSString *)identifier targetPoint:(CGPoint)targetPoint toGroup:(NSString *)groupIdentifier image:(NSString *)image pos:(CGPoint)pos {
    // check if this group exists
    TargetGroup *grp = [targetGroups objectForKey:groupIdentifier];
    
    if (!grp) return nil;

    // create sprite
    CCSprite *sprite = nil;
    if (image) {
        sprite = [CCSprite spriteWithFile:image];
        [sprite setPosition:pos];
    }
    
    // create target area
    TargetArea *newTarget = [[TargetArea alloc] initWithIdentifier:identifier targetPoint:targetPoint sprite:sprite];
    
    // add it
    [grp.areas addObject:newTarget];
    
    if (sprite) {
        if (!pageLayerIsSpriteParent) [self addChild:newTarget.sprite z:(targetAreaZ++)];
        else [pageLayer addChild:newTarget.sprite z:(targetAreaZ++)];
    }
    
    return [newTarget autorelease];
}

-(ArrangeableObject *)addArrangableObject:(NSString *)image pos:(CGPoint)pos matchingTo:(NSArray *)matchingTargets {
    return [self addArrangableObject:image pos:pos matchingTo:matchingTargets isValid:YES];
}

-(ArrangeableObject *)addArrangableObject:(NSString *)image pos:(CGPoint)pos matchingTo:(NSArray *)matchingTargets isValid:(BOOL)pIsValid {
    return [self addArrangableObject:image pos:pos matchingTo:matchingTargets isValid:YES addAsChildrenToParentNode:(pageLayerIsSpriteParent ? pageLayer : self)];
}

-(ArrangeableObject *)addArrangableObject:(NSString *)image pos:(CGPoint)pos matchingTo:(NSArray *)matchingTargets isValid:(BOOL)pIsValid addAsChildrenToParentNode:(CCNode *)parentNode {
    // create sprite
    CCSprite *sprite = [CCSprite spriteWithFile:image];

    // create target area
    ArrangeableObject *newObj = [[ArrangeableObject alloc] initWithIdentifier:image matchingTargets:matchingTargets sprite:sprite beginPos:pos isValid:pIsValid];
    [newObj setBeginPos:pos];
    
    // add it to the array ...
    [arrangableObjects addObject:newObj];
    
    // ... and as child to a parent node
    if (parentNode) {
       [parentNode addChild:newObj.sprite z:(arrangableObjectsZ++)];
    }
    
    // also make it "glow" in the page layer
    [pageLayer.interactiveElements addObject:newObj.sprite];
    
    return [newObj autorelease];
}

-(TargetGroup *)addGroup:(NSString *)identifier successSound:(NSString *)successSndFile successTarget:(id)target successAction:(SEL)successAction unsuccessSound:(NSString *)unsuccessSndFile {
    TargetGroup *grp = [[TargetGroup alloc] initWithIdentifier:identifier successSound:successSndFile successTarget:target successAction:successAction unsuccessSound:unsuccessSndFile];
    [grp setArrangeableObjects:arrangableObjects];
    
    [targetGroups setObject:grp forKey:identifier];
    
    return [grp autorelease];
}

-(TargetGroup *)addGroup:(NSString *)identifier successSound:(NSString *)successSndFile successTarget:(id)target successAction:(SEL)successAction {
    return [self addGroup:identifier successSound:successSndFile successTarget:target successAction:successAction unsuccessSound:nil];
}

-(void)addNoMatchConditionForGroup:(NSString *)groupIdentifier image1:(NSString *)img1 image2:(NSString *)img2 {
    TargetGroup *grp = [targetGroups objectForKey:groupIdentifier];
    
    if (!grp) return;

    [grp.noMatchConditions setObject:img2 forKey:img1];
}

-(void)setMatchingObject:(ArrangeableObject *)obj toTarget:(NSString *)targetIdentifier inGroup:(NSString *)groupIdentifier {
    TargetGroup *grp = [targetGroups objectForKey:groupIdentifier];
    
    if (!grp) return;
    
    // find target
    TargetArea *foundTarget = nil;
    for (TargetArea *t in grp.areas) {
        if ([t.identifier isEqualToString:targetIdentifier]) {
            foundTarget = t;
            break;
        }
    }
    
    if (!foundTarget) return;
    
    // set matching object
    [foundTarget setMatchedBy:obj];
    [obj setMatchedTarget:foundTarget];
}

-(void)shuffleArrangableObjects {
    [Tools shuffleArray:arrangableObjects];
}

-(void)addAllArrangableObjectsToNode:(CCNode *)node {
    for (ArrangeableObject *obj in arrangableObjects) {
        [node addChild:obj.sprite z:(arrangableObjectsZ++)];
    }
}

#pragma mark touch handling

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isActive) {
        return;
    }

    UITouch *touch = [touches anyObject];   // no multitouch
    
    // check if an object has been touched
    ArrangeableObject *maxZobj = nil;
    for (ArrangeableObject *obj in arrangableObjects) {
        if ((allowMovingOfAlreadyMatchedObjects || (!allowMovingOfAlreadyMatchedObjects && !obj.matchedTarget))
        && [Tools touch:touch isInNode:obj.sprite]) {
            // get the object that is on the top
            if (maxZobj == nil || maxZobj.sprite.zOrder < obj.sprite.zOrder) {
                maxZobj = obj;
            }
        }
    }
    
    if (maxZobj != nil) {
        // set the selected object and bring it to the front
        selectedObject = maxZobj;
        [selectedObject gotSelected];
        [self reorderChild:maxZobj.sprite z:(++arrangableObjectsZ)];    // bring to front
        
        [pageLayer cancelHighlightAnimations];
        
        // disable gestures for now
        [[CoreHolder sharedCoreHolder] setInteractiveObjectWasTouched:YES];
    }
    

//    [super ccTouchesBegan:touches withEvent:event];
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isActive) {
        return;
    }
    
    if (selectedObject != nil) {
        CGPoint touchPoint = [Tools convertTouchToGLPoint:[touches anyObject]];
        
        // set new position
        [selectedObject.sprite setPosition:touchPoint];
        
        for (TargetGroup *group in [targetGroups allValues]) {
            // check if we are near a target
            for (TargetArea *target in group.areas) {
                for (NSString *matchIdentifier in selectedObject.matchingTargets) {
                    if ([matchIdentifier isEqualToString:target.identifier] && [group conditionsOkayForObject:selectedObject]) {
                        CGPoint realTrgtPt = ccpAdd(target.targetPoint, selectedObject.targetOffset);
                            
                        float dist = ccpDistance(realTrgtPt, selectedObject.sprite.position);
                        
                        if (dist <= magneticDist && (!target.matchedBy || target.matchedBy == selectedObject)) {
                            if (group.magneticDistReachedTarget != nil && !selectedObject.isInMagneticDist) {   // object reached the magnetic distance
                                [selectedObject setIsInMagneticDist:YES];
                                [group.magneticDistReachedTarget performSelector:group.magneticDistReachedAction
                                                                      withObject:group.identifier
                                                                      withObject:target.identifier];
                            }
                        }
                        
                        if (dist > magneticDist && selectedObject.isInMagneticDist) {      // object left the magnetic distance
                            [selectedObject setIsInMagneticDist:NO];
                            [group.magneticDistLeftTarget performSelector:group.magneticDistLeftAction
                                                               withObject:group.identifier
                                                               withObject:target.identifier];
                        }
                    }
                }
            }
        }
    }

//    [super ccTouchesMoved:touches withEvent:event];
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isActive) {
        return;
    }
    
    // for each group ...
    for (TargetGroup *group in [targetGroups allValues]) {
        BOOL groupCompleted = YES;
        BOOL targetFound = NO;
        ArrangeableObject *objToMoveBack = nil;
        
        // ... and each of its targets ...
        for (TargetArea *target in group.areas) {    
            // ... and each of the selected objects possible targets ...
            for (NSString *matchIdentifier in selectedObject.matchingTargets) {
                CGPoint realTrgtPt = ccpAdd(target.targetPoint, selectedObject.targetOffset);
                
                // calculate the distance between the target and the selected object
                float dist = ccpDistance(realTrgtPt, selectedObject.sprite.position);
                
                // ... if it is a valid target ...
                if ([matchIdentifier isEqualToString:target.identifier]) {
                    // ... check if we are near a target!
                    if (dist <= magneticDist && (!target.matchedBy || target.matchedBy == selectedObject)
                    && [group conditionsOkayForObject:selectedObject]) {
                        float snapDur = dist / (float)magneticDist * kDefaultSnappingDuration;
                        
                        // create "move to" action
                        CCMoveTo *snapMove = [CCMoveTo actionWithDuration:snapDur position:realTrgtPt];
                        [selectedObject.sprite runAction:snapMove];
                        
                        // create "rotate to" action
                        if (selectedObject.beginRot != 0.0f) {
                            CCRotateTo *rotateMove = [CCRotateTo actionWithDuration:snapDur angle:0.0f];
                            [selectedObject.sprite runAction:rotateMove];
                        }
                        
                        // set new status
                        NSLog(@"Target %@ matched by %@", target.identifier, selectedObject.identifier);
                        [target setMatchedBy:selectedObject];
                        [selectedObject setMatchedTarget:target];
                        
                        if (group.objectMatchedTarget != nil) {   // call the "objectMatched" action
                            [group.objectMatchedTarget performSelector:group.objectMatchedAction
                                                            withObject:group.identifier
                                                            withObject:target.identifier];
                        }
                        
                        // we found something, break the loop
                        targetFound = YES;
                        objToMoveBack = nil;
                    } else {
                        if (dist > magneticDist && [target.matchedBy.identifier isEqualToString:selectedObject.identifier]) {
                            // No match!!
                            // set new status
                            [target.matchedBy setMatchedTarget:nil];
                            [target setMatchedBy:nil];
                            
                            NSLog(@"Target %@ unmatched", target.identifier);
                        }
                            
                        if (!target.matchedBy && !selectedObject.matchedTarget && !targetFound && moveObjectsToStartPosOnNoMatch) {  // move back
                            NSLog(@"Selected for moving back: %@", selectedObject.identifier);
                            objToMoveBack = selectedObject;
                        }
                    }
                }
                
                // we found something, break the loop
                if (targetFound) break;
            }
            
            // set success status
            if (![group targetIsCompleted:target]) {
                NSLog(@"*** NOT completed in group %@: %@", group.identifier, target.identifier);
                groupCompleted = NO;
            } else {
                NSLog(@"*** completed in group %@: %@", group.identifier, target.identifier);
            }
        }
        
        // if a have an object that was not matched, move it back!
        if (objToMoveBack) {
            NSLog(@"Moving back %@", objToMoveBack.identifier);
            [self moveBackArrangeableObject:objToMoveBack];
        }
        
        // check if group was successful completed
        if (groupCompleted && !group.wasCompleted) {
            [self groupCompleted:group];
        }
    }

    // deselect
    selectedObject = nil;
    
    // reenable gestures
    [[CoreHolder sharedCoreHolder] setInteractiveObjectWasTouched:NO];

//    [super ccTouchesEnded:touches withEvent:event];
}

#pragma mark private methods

-(void)groupCompleted:(TargetGroup *)grp {
    NSMutableArray *invalidObjs = [self groupContainsInvalidArrangableObjects:grp];
    
    if (invalidObjs == nil) {
        NSLog(@"arrange group completed: %@", grp.identifier);
        
        // set completed
        [grp setWasCompleted:YES];
        
        // play sound
        [grp.successSnd play];
        
        // call callbacks
        if (grp.successAction && grp.successActionTarget) {
            [grp.successActionTarget performSelector:grp.successAction];
        }        
    } else {
        NSLog(@"group contains invalid objects");
        // group contains invalid objects
        
        // play sound
        [grp.unsuccessSnd play];
        
        // move the objects back
        if (moveObjectsToStartPosOnNoMatch) {
            for (ArrangeableObject *obj in invalidObjs) {
                if ([obj isKindOfClass:[ArrangableClothes class]]) {
                    [((ArrangableClothes *)obj).spriteBg setVisible:YES];
                }
                
                [self moveBackArrangeableObject:obj];
            }
        }
    }
    
    // important!
    [invalidObjs removeAllObjects];
}

-(NSMutableArray *)groupContainsInvalidArrangableObjects:(TargetGroup *)grp {
    NSMutableArray *invalidObjs = [NSMutableArray array];

    for (TargetArea *area in grp.areas) {
        if (area.matchedBy != nil) {
            if (!area.matchedBy.isValid) {
                [invalidObjs addObject:area.matchedBy];
                [area setMatchedBy:nil];
            }
        }
    }
    
    if ([invalidObjs count] <= 0) return nil;
    
    return invalidObjs;
}

-(void)moveBackArrangeableObject:(ArrangeableObject *)obj {
    // create "rotate to" action
    if (obj.beginRot != 0.0f) {
        CCRotateTo *rotateMove = [CCRotateTo actionWithDuration:0.5f angle:obj.beginRot];
        [obj.sprite runAction:rotateMove];
    }

    CCMoveTo *backMove = [CCMoveTo actionWithDuration:0.5f position:obj.beginPos];
    [obj.sprite runAction:backMove];
}

@end
