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
//  PageMainLayer.h
//  iDiary2
//
//  Created by Markus Konrad on 06.06.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"

#import "PageLayer.h"
#import "PageElementPersistency.h"

@class PageLayer;

// This class is the layer that is underneath a PageLayer. It displays common elements
// that are available on each page, such as the desk background and the control layer element.
@interface PageMainLayer : CCLayer {    
    CoreHolder *core;               // shortcut to singleton

    CCSprite *bgSprite;             // background sprite (desk)
    CCSprite *bookSprite;           // sprite (book)
    
    PageLayer *currentPageLayer;    // page layer that is currently visible
    PageLayer *otherPageLayer;      // page layer to which will be switched upon page turn. is only NOT nil upon page turn animation
    
    NSMutableArray *persistentPageElements;  // array with objects of type PersistentPageElement
    
    NSString *currentPerson;        // current selected person
    
    int currentPageTurnDirection;   // current page turn direction. -1 is to prev. page, +1 is to next page
    SEL pageTurnBeginMethod;        // page turn animation phase begin method
    
    int pageTurnTargetPageNum;      // page number to which shall be navigated. can be increased/decreased while turning the pages
    int pageTurnCurrentPageNum;     // current page number
    
    float pageTurnDuration;         // duration of a page turn phase
    float pageCurlStrength;         // page curl strength (0..1)
}

@property (nonatomic,readonly) PageLayer *currentPageLayer;
@property (nonatomic,readonly) NSArray *persistentPageElements;

// load a person's diary with a page and display it (without page turn animations)
-(void)loadPerson:(NSString *)person withPageName:(NSString *)pageName andOldPageStatus:(NSArray *)pageStatusData;

// navigate in a direction and make page turns. -1 is to prev. page, +1 is to next page.
-(void)navigateInDirection:(int)turnDir;

// add an element to persistentPageElements
-(void)registerPersistentElements:(NSArray *)elems;
-(void)registerPersistentElement:(id<PageElementPersistencyProtocol>)elem;

// clear persistentPageElements array
-(void)unregisterPersistentElements;

// save the current page status
-(void)savePageStatus;

// load the current page status, clear the saved data
-(void)loadPageStatusFromData:(NSArray *)savedPageElements;

@end
