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
//  ModalOverlay.m
//  iDiary2
//
//  Created by Markus Konrad on 22.02.12.
//  Copyright (c) 2012 INKA Forschungsgruppe. All rights reserved.
//

#import "ModalOverlay.h"

#import "Tools.h"
#import "Config.h"

@implementation ModalOverlay

-(id)initWithColor:(ccColor4B)color width:(GLfloat)w height:(GLfloat)h {
    self = [super initWithColor:color width:w height:h];
    
    if (self) {
        core = [CoreHolder sharedCoreHolder];
        
        interactionBlockTime = CACurrentMediaTime();
        
        [self setIsTouchEnabled:YES];
    }
    
    return self;
}

-(void)dealloc {
    [bgSprite release];
    [closeBtn release];
    
    [contentLayer release];

    [super dealloc];
}

-(void)setBackgroundImage:(NSString *)bgImg {
    [bgSprite removeFromParentAndCleanup:YES];
    [bgSprite release];
    
    bgSprite = [[CCSprite alloc] initWithFile:bgImg];
    [bgSprite setPosition:ccp(self.contentSize.width / 2.0f, self.contentSize.height / 2.0f)];
    [self addChild:bgSprite z:0];
    
    [closeBtn removeFromParentAndCleanup:YES];
    [closeBtn release];
    
    closeBtn = [[CCSprite alloc] initWithFile:@"closeButton.png"];
    [closeBtn setPosition:ccp(bgSprite.position.x + bgSprite.contentSize.width / 2.0f + kModalOverlayCloseBtnOffsetX, bgSprite.position.y + bgSprite.contentSize.height / 2.0f + kModalOverlayCloseBtnOffsetY)];
    [self addChild:closeBtn z:100];
}

-(void)setContentImage:(NSString *)contentImg {
    [contentLayer removeFromParentAndCleanup:YES];
    [contentLayer release];
    
    CCSprite *contentSprite = [CCSprite spriteWithFile:contentImg];
    
    contentLayer = [[PanningLayer alloc] initWithColor:ccc4(0, 0, 0, 0)];
    [contentLayer setDelegate:self];
    [contentLayer setPosition:ccp(kModalOverlayMarginX + bgSprite.position.x - bgSprite.contentSize.width / 2.0f, kModalOverlayMarginY + bgSprite.position.y - bgSprite.contentSize.height / 2.0f)];
    [contentLayer setContentSize:CGSizeMake(bgSprite.contentSize.width - 2.0f * kModalOverlayMarginX, bgSprite.contentSize.height - 2.0f * kModalOverlayMarginY)];
    [contentLayer setScrollingContentSize:contentSprite.contentSize];
    [contentLayer setIsTouchEnabled:YES];
    [contentLayer setScrollingContentOffset:ccp(0, contentSprite.contentSize.height)];
    
    [contentSprite setPosition:ccp(contentSprite.contentSize.width / 2.0f, contentSprite.contentSize.height / 2.0f)];
    [contentLayer addChild:contentSprite];
    
    [self addChild:contentLayer z:1];
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (CACurrentMediaTime() - interactionBlockTime < 0.5f) return;

    UITouch *touch = [touches anyObject];

    if ([Tools touch:touch isInNode:closeBtn] || ![Tools touch:touch isInRect:[bgSprite boundingBox]]) {
        [core closeModalOverlay];
        
        return;
    }
}

-(void)panningLayer:(PanningLayer *)layer willMoveToOffset:(CGPoint)offset displayingNodes:(NSArray *)nodes {

}

-(void)panningLayerStartedPanning:(PanningLayer *)layer {
    interactionBlockTime = CACurrentMediaTime();
}

-(void)panningLayerFinishedPanning:(PanningLayer *)layer {
    interactionBlockTime = CACurrentMediaTime();
}

@end
