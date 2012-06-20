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
//  PageMainLayer.m
//  iDiary2
//
//  Created by Markus Konrad on 06.06.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "PageMainLayer.h"

#import "CCActionRealPageTurn3D.h"
#import "CoreHolder.h"
#import "Config.h"

// Define Cocos2D layer tags and z-indices:
static const int kLayerBgZ = 0;
static const int kLayerBookZ = 1;
static const int kLayerOtherPageZ = 2;
static const int kLayerEmptyPageZ1 = 3;
static const int kLayerEmptyPageZ2 = 4;
static const int kLayerTopPageZ = 5;

// private methods category
@interface PageMainLayer(PrivateMethods)

// reset page turn direction
- (void)resetPageTurnDirection;

// navigate to target page number
- (void)navigateToTargetPageNum;

// creates a PageLayer object for a specific person and pagename
- (PageLayer *)createPageLayerForPerson:(NSString *)person andPageName:(NSString *)pageName usingPersistentData:(BOOL)persistentDataUsed;

// page turn animation phase 1 folds the current page until it is in the middle and swaps the z orders of the pages
- (void)pageTurnAnimationPhase1;

// page turn animation phase 2 folds the other page until it lays flat
- (void)pageTurnAnimationPhase2;

// this method is called when the page turn animation is done
- (void)pageTurnAnimationDone;

// swap page layer z order indices
- (void)swapPageLayerZOrderIndices;

@end

@implementation PageMainLayer

@synthesize currentPageLayer;
@synthesize persistentPageElements;

#pragma mark init/dealloc

- (id)init {
    self = [super init];
    if (self) {        
        // set default values
        core = [CoreHolder sharedCoreHolder];
                
        currentPageTurnDirection = 0;
        pageTurnBeginMethod = nil;
        
        pageTurnDuration = kPageTurnDuration;
        pageCurlStrength = kPageCurlStrength;
        
        // set pages and page elements
        currentPageLayer = nil;
        otherPageLayer = nil;
        
        persistentPageElements = [[NSMutableArray alloc] init];
        
        // set sprites
//        bgSprite = [[CCSprite spriteWithFile:@"desk_background.png" rect:CGRectMake(0,0, (CGFloat)core.screenW, (CGFloat)core.screenH)] retain];
//        [bgSprite setPosition:ccp(core.screenW/2, core.screenH/2)];
//        [self addChild:bgSprite z:kLayerBgZ tag:kLayerBgZ];
    }
    return self;
}

- (void)dealloc {
    [persistentPageElements release];

    [currentPerson release];
    
    [currentPageLayer release];
    [otherPageLayer release];

    [bgSprite release];
    [bookSprite release];
    
    [super dealloc];
}

#pragma mark public messages

-(void)navigateInDirection:(int)turnDir {
    NSAssert(turnDir != 0, @"turnDir must be != 0");
        
    // allow only page turns in the same direction if a page turn is already going on
    if (currentPageTurnDirection != 0 && turnDir != currentPageTurnDirection) return;
    
    pageTurnBeginMethod = nil;
    
    // set the new target page number
    pageTurnTargetPageNum += turnDir;
    
    // consider min/max pages
    if (pageTurnTargetPageNum < 0) {
        [core showStartscreen:self];
        
        return;
    } else if (pageTurnTargetPageNum > core.maxPageNum) {
        pageTurnTargetPageNum = core.maxPageNum;
    }
    
    NSLog(@"Navigating to page number #%d", pageTurnTargetPageNum);
    
    // start navigating
    [self navigateToTargetPageNum];
}

-(void)loadPerson:(NSString *)person withPageName:(NSString *)pageName andOldPageStatus:(NSArray *)pageStatusData {
    // set defaults    
    pageTurnCurrentPageNum = core.currentPageNum;
    pageTurnTargetPageNum = pageTurnCurrentPageNum;
        
    // dynamically create class from person and page name
    PageLayer *pageLayer = [self createPageLayerForPerson:person andPageName:pageName usingPersistentData:(pageStatusData != nil)];
    NSAssert(pageLayer != nil, @"pageLayer must have been created!");
    
    // set a book sprite
    if ((bookSprite == nil || currentPerson == nil || ![currentPerson isEqualToString:person]) && !kDbgDrawPhysics) {
        [self removeChildByTag:kLayerBookZ cleanup:YES];
        [bookSprite release];
        
        NSString *bookSpriteFile = [NSString stringWithFormat:@"%@_buch_hintergrund.png", [person lowercaseString]];
        
        bookSprite = [[CCSprite spriteWithFile:bookSpriteFile rect:CGRectMake(0,0, (CGFloat)core.screenW, (CGFloat)core.screenH)] retain];
        [bookSprite setPosition:ccp(core.screenW/2, core.screenH/2)];
        [self addChild:bookSprite z:kLayerBookZ tag:kLayerBookZ];
    }
    
    [currentPerson release];
    currentPerson = [person retain];
    
    // set the new page...
    int pageLayerZ = kLayerTopPageZ;    // ... directly as the new page
    
    [otherPageLayer release];
    otherPageLayer = nil;
    currentPageLayer = [pageLayer retain];
    
    // load persistent page data if it exists
    if (pageStatusData) {
        [self loadPageStatusFromData:pageStatusData];
    }
    
    // change page status
    [currentPageLayer pageTurnComplete];
        
    // add the new page as child
    [self addChild:pageLayer z:pageLayerZ];
}

-(void)registerPersistentElements:(NSArray *)elems {
    for (id<PageElementPersistencyProtocol>elem in elems) {
        [self registerPersistentElement:elem];
    }
}

-(void)registerPersistentElement:(id<PageElementPersistencyProtocol>)elem {
    NSLog(@"Registering persistent element: %@", [elem getIdentifer]);
        
    PersistentPageElement *registeredElem = [[PersistentPageElement alloc] initElement:elem withIdentifier:[elem getIdentifer]];

    // warning: does not check if the element already exists
    [persistentPageElements addObject:registeredElem];
    
    [registeredElem release];
}

-(void)unregisterPersistentElements {
    NSLog(@"Unregistering all persistent elements");
    [persistentPageElements removeAllObjects];
}

-(void)savePageStatus {
    NSLog(@"Saving page status...");
    
    // save each registered persistent page element
    for (PersistentPageElement *elem in persistentPageElements) {
        NSLog(@"Saving page status for element %@...", elem.identifier);
    
        [elem save];
    }
}

-(void)loadPageStatusFromData:(NSArray *)savedPageElements {
    NSLog(@"Loading page status...");
    
    // for each of the provided saved elements check if we have an element on the page
    for (PersistentPageElement *registeredElem in savedPageElements) {
        for (id<PageElementPersistencyProtocol> pageElem in currentPageLayer.persistentElements) {
            
            if ([[pageElem getIdentifer] isEqualToString:registeredElem.identifier]) {
                // we have found the element on the page correspondending to the saved element
                NSLog(@"Loading page status for element %@...", registeredElem.identifier);
                [pageElem loadElementStatus:registeredElem.data];
                
                break;
            }
        }
        
        [registeredElem clear];
    }
    
    // no more highlighting after loading
    [currentPageLayer cancelHighlightAnimations];
    [currentPageLayer setHighlightInteractiveElementsEnabled:NO];
}

#pragma mark private messages

- (PageLayer *)createPageLayerForPerson:(NSString *)person andPageName:(NSString *)pageName usingPersistentData:(BOOL)persistentDataUsed {
    // clear stuff
    [self unregisterPersistentElements];

    // dynamically create class from person and page name    
    NSString *pageClassName = [NSString stringWithFormat:@"Page_%@_%@", person, pageName];
    
    Class pageClass = NSClassFromString(pageClassName);
    
    if (pageClass == nil) {
        NSLog(@"ERROR: No page class found: %@", pageClassName);
        
        return nil;
    }
    
    // instanciate the dynamic class
    PageLayer *pageLayer = [pageClass node];
    
    // set properties
    [pageLayer setPerson:person];
    [pageLayer setPageName:pageName];
    [pageLayer setCurPage:pageTurnCurrentPageNum];
    [pageLayer setMaxPage:core.maxPageNum];
    [pageLayer setIsRestoredFromPersistentData:persistentDataUsed];
            
    // load and display contents
    [pageLayer loadPageContents];
    [pageLayer displayContent];

    return pageLayer;
}

- (void)resetPageTurnDirection {
    if (pageTurnCurrentPageNum == pageTurnTargetPageNum) {
        currentPageTurnDirection = 0;
    } else {
        if (pageTurnCurrentPageNum > pageTurnTargetPageNum) {
            currentPageTurnDirection = -1;
        } else {
            currentPageTurnDirection = 1;
        }
    }
}

- (void)navigateToTargetPageNum {
    // reset the page turn direction
    [self resetPageTurnDirection];
    
    // start a page turn animation if it has not been start yet
    if (pageTurnBeginMethod == nil) {
        if (currentPageTurnDirection > 0) {
            pageTurnBeginMethod = @selector(pageTurnAnimationPhase1); // forward: start with phase 1
        } else {
            pageTurnBeginMethod = @selector(pageTurnAnimationPhase2); // backward: start with phase 2
        }
        
        pageTurnCurrentPageNum += currentPageTurnDirection;
        
        // start page turning
        [self performSelector:pageTurnBeginMethod];
    }
}

- (void)pageTurnAnimationPhase1 {
    // swap the z order of the page layers when moving backwards
    if (currentPageTurnDirection < 0) {
        [self swapPageLayerZOrderIndices];
    } else {    // when moving forwards, this is the first thing to do: create the "other" layer that is now beneath the current layer
        // create the other layer
        otherPageLayer = [self createPageLayerForPerson:currentPerson
                                            andPageName:[core getPageNameAtIndex:pageTurnCurrentPageNum forPerson:currentPerson]
                                    usingPersistentData:NO];
        NSAssert(otherPageLayer != nil, @"pageLayer must have been created!");
        
        // retain it. will be released in the pageTurnAnimationDone method
        [otherPageLayer retain];
        
        // add it as child underneath the current page
        [self addChild:otherPageLayer z:kLayerOtherPageZ];
    }

    // define page turn animation action
    CCActionInterval *action = [CCRealPageTurn3D actionWithSize:ccg(16, 12)
                                                       duration:pageTurnDuration
                                                   curlStrength:pageCurlStrength
                                                    curlForward:(currentPageTurnDirection == 1)
                                                        beneath:NO];

    // alter page turn animation action for playing backwards   
    if (currentPageTurnDirection < 0) {
        action = [CCReverseTime actionWithAction:action];
    }
    
    // define next action after this animation phase
    SEL nextAction;
    if (currentPageTurnDirection > 0) {
        nextAction = @selector(pageTurnAnimationPhase2);    // forward
    } else {
        nextAction = @selector(pageTurnAnimationDone);      // backward
    }
    
    // define action sequence
    CCSequence *actionSeq = [CCSequence actions:
                             action,
                             [CCCallFunc actionWithTarget:self selector:nextAction],
                             [CCStopGrid action],
                             nil];
                             
    // run action sequence
    if (currentPageTurnDirection > 0) {
        [currentPageLayer runAction:actionSeq];
    } else {
        [otherPageLayer runAction:actionSeq];
    }
}

- (void)pageTurnAnimationPhase2 {
    // swap the z order of the page layers when moving forwards
    if (currentPageTurnDirection > 0) {
        [self swapPageLayerZOrderIndices];
    } else {    // when moving forwards, this is the first thing to do: create the "other" layer that is now beneath the current layer
        // create the other layer
        otherPageLayer = [self createPageLayerForPerson:currentPerson
                                            andPageName:[core getPageNameAtIndex:pageTurnCurrentPageNum forPerson:currentPerson]
                                    usingPersistentData:NO];
        NSAssert(otherPageLayer != nil, @"pageLayer must have been created!");
        
        // retain it. will be released in the pageTurnAnimationDone method
        [otherPageLayer retain];
        
        // add it as child underneath the current page
        [self addChild:otherPageLayer z:kLayerOtherPageZ];
    }

    // alter page turn animation action for playing backwards
    CCActionInterval *action = [CCRealPageTurn3D actionWithSize:ccg(16, 12)
                                                       duration:pageTurnDuration
                                                   curlStrength:pageCurlStrength
                                                    curlForward:(currentPageTurnDirection == -1)
                                                        beneath:YES];
    
    if (currentPageTurnDirection < 0) {
        action = [CCReverseTime actionWithAction:action];
    }
    
    // define next action after this animation phase
    SEL nextAction;
    if (currentPageTurnDirection > 0) {
        nextAction = @selector(pageTurnAnimationDone);    // forward
    } else {
        nextAction = @selector(pageTurnAnimationPhase1);      // backward
    }
    
    // define action sequence
    CCSequence *actionSeq = [CCSequence actions:
                             action,
                             [CCCallFunc actionWithTarget:self selector:nextAction],
                             [CCStopGrid action],
                             nil];
                             
    // run action sequence
    if (currentPageTurnDirection < 0) {
        [currentPageLayer runAction:actionSeq];
    } else {
        [otherPageLayer runAction:actionSeq];
    }
}

- (void)pageTurnAnimationDone {
    [self resetPageTurnDirection];

    // begin a again if we have a another page turn to do
    if (currentPageTurnDirection != 0 && pageTurnBeginMethod != nil) {
        pageTurnCurrentPageNum += currentPageTurnDirection;
        
        // release the old layer beneath the current layer
        [currentPageLayer pageGoneInvisible];
        [currentPageLayer removeFromParentAndCleanup:YES];
        [currentPageLayer release];
        
        // swap page layers
        currentPageLayer = otherPageLayer;
        otherPageLayer = nil;
        
        NSLog(@"Doing another page turn to page num %d", pageTurnCurrentPageNum);
    
        // begin again with another page turn
        [self performSelector:pageTurnBeginMethod];
        
        return;
    }

    // cleanup
    pageTurnBeginMethod = nil;
    currentPageTurnDirection = 0;
    
    [currentPageLayer pageGoneInvisible];        
    [self removeChild:currentPageLayer cleanup:YES];
    [currentPageLayer release];
    
    // swap page layers
    currentPageLayer = otherPageLayer;
    otherPageLayer = nil;
    
    // tell the new current page layer that page turn is complete
    [currentPageLayer pageTurnComplete];
}

- (void)swapPageLayerZOrderIndices {
    // now the "current" page layer will be beneath, and the "other" page layer will be on top:
    
    [self reorderChild:currentPageLayer z:kLayerOtherPageZ];
    [self reorderChild:otherPageLayer z:kLayerTopPageZ]; 
}

@end
