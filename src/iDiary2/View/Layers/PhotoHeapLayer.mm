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
//  PhotoHeapLayer.mm
//  iDiary2
//
//  Created by Markus Konrad on 04.07.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "PhotoHeapLayer.h"

#import "CoreHolder.h"
#import "Tools.h"

// Implement BlockBorder as simple model class with properties.
@implementation BlockBorder

@synthesize p1;
@synthesize p2;
@synthesize blockDirection;

-(BOOL)pointIsBehindBorder:(CGPoint)p {
    if (blockDirection == kDirectionUp || blockDirection == kDirectionDown) {   // check horizontal collision
        if (p.x >= p1.x && p.x <= p2.x) {
            if ((blockDirection == kDirectionUp && p.y >= p1.y)
            || (blockDirection == kDirectionDown && p.y <= p1.y)) {
                return YES;
            }
        } else {
            return NO;
        }
    } else {    // check vertical collision
        if (p.y >= p1.y && p.y <= p2.y) {
            if ((blockDirection == kDirectionRight && p.x >= p1.x)
            || (blockDirection == kDirectionLeft && p.x <= p1.x)) {
                return YES;
            }
        } else {
            return NO;
        }
    }
    
    return NO;
}

-(BOOL)rectIsBehindBorder:(CGRect)rect {
    NSArray *corners = [NSArray arrayWithObjects:
        [NSValue valueWithCGPoint:rect.origin],
        [NSValue valueWithCGPoint:ccp(rect.origin.x + rect.size.width, rect.origin.y)],
        [NSValue valueWithCGPoint:ccp(rect.origin.x + rect.size.width, rect.origin.y + rect.size.width)],
        [NSValue valueWithCGPoint:ccp(rect.origin.x, rect.origin.y + rect.size.width)],
        nil];
    
    for (NSValue *point in corners) {
        if ([self pointIsBehindBorder:[point CGPointValue]]) {
            return YES;
        }
    }
    
    return NO;
}

@end

// declare private methods for PhotoHeapLayer
@interface PhotoHeapLayer(PrivateMethods)

// bring a photo to the front
- (void)bringPhotoToFront:(PhotoSprite *)photo;

// check border collision
- (BOOL)borderCollisionOfNode:(CCNode *)node withNewPosition:(CGPoint)pos;

@end

// PhotoHeapLayer implementation
@implementation PhotoHeapLayer

@synthesize photos;

#pragma mark init/dealloc

- (id)initOnPageLayer:(PageLayer *)layer withBox2DWorld:(b2World *)world {
    self = [super init];
    if (self) {
        // set defaults
        pageLayer = layer;
        
        lastPhotoZNum = 0;
        photos = [[NSMutableArray alloc] init];
        blockBorders = [[NSMutableArray alloc] init];
        box2dWorld = world;
        
        // setup touches for the layer
        [self setIsTouchEnabled:YES];
    }
    return self;
}

- (void)dealloc {
    [photos release];
    [blockBorders release];
    
    [super dealloc];
}

#pragma mark public methods

// add a new photo to the heap
-(void)addPhoto:(NSString *)photoFile atPos:(CGPoint)pos {
    PhotoSprite *photoSprite = [[PhotoSprite alloc] initWithFile:photoFile atPos:pos inWorld:box2dWorld];
    
    [photos addObject:photoSprite];
    lastPhotoZNum++;
    
    [photoSprite setTag:lastPhotoZNum];
    [self addChild:photoSprite z:lastPhotoZNum];
    
    [photoSprite release];
}

// add a new movement border
-(void)addMovementBorderFromPoint:(CGPoint)p1 toPoint:(CGPoint)p2 blockDirection:(direction_t)blockDir {
    BlockBorder *border = [[BlockBorder alloc] init];
    
    // swap points
    if (   ((blockDir == kDirectionUp || blockDir == kDirectionDown) && (p1.x > p2.x))   
        || ((blockDir == kDirectionLeft || blockDir == kDirectionRight) && (p1.y > p2.y))) {
        CGPoint temp = p2;
        p2 = p1;
        p1 = temp;
    }
    
    // set border properties
    [border setP1:p1];
    [border setP2:p2];
    [border setBlockDirection:blockDir];
    
    // add the border
    [blockBorders addObject:border];
    
    [border release];
}

#pragma mark touch handling

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];   // no multitouch
    
    // check if a photo has been touched
    PhotoSprite *maxZphoto = nil;
    for (PhotoSprite *photo in photos) {
        if ([Tools touch:touch isInNode:photo]) {
            // get the photo that is on the top
            if (maxZphoto == nil || maxZphoto.zOrder < photo.zOrder) {
                maxZphoto = photo;
            }
        }
    }
    
    if (maxZphoto != nil) {
        // set the selected photo and bring it to the front
        selectedPhoto = maxZphoto;
        [self bringPhotoToFront:selectedPhoto];
        
        [pageLayer cancelHighlightAnimations];
        
        // disable gestures for now
        [[CoreHolder sharedCoreHolder] setInteractiveObjectWasTouched:YES];
    }
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {   
    if (selectedPhoto != nil) {
        CGPoint touchPoint = [Tools convertTouchToGLPoint:[touches anyObject]];
        
        [selectedPhoto setPhyPosition:touchPoint];
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // reenable gestures
    [[CoreHolder sharedCoreHolder] setInteractiveObjectWasTouched:NO];
    
    // deselect
    selectedPhoto = nil;
}

#pragma mark PhysicsNotificationDelegate methods

-(void)willUpdateNode:(CCNode *)node withNewPosition:(CGPoint *)posValue {
    CGPoint oldPos = node.position;
        
    // check border collision
    if ([self borderCollisionOfNode:node withNewPosition:(*posValue)]) {

//        NSLog(@"Border collision of %d with new position %f, %f", node.tag, posValue->x, posValue->y);
    
        // set old position
        *posValue = oldPos;
    }
}

#pragma mark other private methods

- (BOOL)borderCollisionOfNode:(CCNode *)node withNewPosition:(CGPoint)pos {
    CGRect rect = [node boundingBox];
    rect.origin = ccp(pos.x - rect.size.width / 2, pos.y - rect.size.height / 2);

    for (BlockBorder *border in blockBorders) { // check each border
        if ([border rectIsBehindBorder:rect]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)bringPhotoToFront:(PhotoSprite *)photo {
    [self reorderChild:photo z:(++lastPhotoZNum)];
}

@end
