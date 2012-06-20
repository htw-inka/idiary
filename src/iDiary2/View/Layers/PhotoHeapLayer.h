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
//  PhotoHeapLayer.h
//  iDiary2
//
//  Created by Markus Konrad on 04.07.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"

#import "PageLayer.h"
#import "PhotoSprite.h"
#import "Box2DWorldHolder.h"

// defines a direction in 2D space
typedef enum {
    kDirectionUp = 0,
    kDirectionDown,
    kDirectionLeft,
    kDirectionRight
} direction_t;

// Defines a movement blocking border between p1 and p2 in a direction blockDirection.
// Slant borders are not supported!
@interface BlockBorder : NSObject {
    CGPoint p1; // p1.x and p1.y must be always less than p2.x and p2.y!
    CGPoint p2;
    direction_t blockDirection;
}

@property (nonatomic,assign) CGPoint p1;
@property (nonatomic,assign) CGPoint p2;
@property (nonatomic,assign) direction_t blockDirection;

// checks if a point is on or behind this border
-(BOOL)pointIsBehindBorder:(CGPoint)p;

// checks if a part of the rect is on or behind this border
-(BOOL)rectIsBehindBorder:(CGRect)rect;

@end

// Defines a Layer with a bunch of photos that can be moved within specific borders.
@interface PhotoHeapLayer : CCLayer<PhysicsNotificationDelegate> {
    PageLayer *pageLayer;               // page on which this game is running (weak ref)    

    NSMutableArray *photos;         // NSMutableArray with PhotoSprite objects
    NSMutableArray *blockBorders;   // NSMutableArray with BlockBorder objects
    
    PhotoSprite *selectedPhoto;   // photo that has been selected for moving (weak ref)
    
    b2World *box2dWorld;    // Physics world
    
    int lastPhotoZNum;      // z index of the last added photo
}

@property (nonatomic,readonly) NSArray *photos;

// initializer
- (id)initOnPageLayer:(PageLayer *)layer withBox2DWorld:(b2World *)world;

// add a new photo to the heap
-(void)addPhoto:(NSString *)photoFile atPos:(CGPoint)pos;

// add a new movement border
-(void)addMovementBorderFromPoint:(CGPoint)p1 toPoint:(CGPoint)p2 blockDirection:(direction_t)blockDir;

@end
