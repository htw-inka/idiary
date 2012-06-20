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
//  Tools.h
//  iPadPresenter
//
//  Created by Markus Konrad on 01.12.10.
//  Copyright 2010 INKA Forschungsgruppe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"

/*!
 @class Tools
 @abstract Tools provides different small static methods for various problems
 */
@interface Tools : NSObject {}

// convert a touch to an OpenGL coordinate point
+ (CGPoint)convertTouchToGLPoint:(UITouch *)touch;

// calculate the absolute position of a bounding box for a node,
// because all positions are relative to parent nodes!
+ (CGRect)absoluteBoundingBoxForNode:(CCNode *)node;
+ (CGRect)absoluteBoundingBoxInPixelsForNode:(CCNode *)node;
+ (CGRect)absoluteRectForRect:(CGRect)r inNode:(CCNode *)node;

// returns YES if the touch occured inside of this CCNode object
+ (BOOL)touch:(UITouch *)t isInNode:(CCNode *)node;
+ (BOOL)touch:(UITouch *)t isInNode:(CCNode *)node usingRadius:(float)r;

// return the point where the object was hit (in relation to the bounds of the object) or return nil
+ (NSValue *)hitPointInNode:(CCNode *)node forPoint:(CGPoint)p;

// returns YES if the touch occured inside of this rect
+ (BOOL)touch:(UITouch *)t isInRect:(CGRect)rect;

// returns YES if the gl point p lies in the CCNode object
+ (BOOL)point:(CGPoint)p isInNode:(CCNode *)node;

// returns YES if the gl point p lies in the radius r of the CCNode's center
+ (BOOL)point:(CGPoint)p isInNode:(CCNode *)node usingRadius:(float)r;

// will add "child" to "parent", keeping the relative position of the "child" 
+ (void)addChild:(CCNode *)child keepingRelativePositionOfNode:(CCNode *)parent;
+ (void)addChild:(CCNode *)child keepingRelativePositionOfNode:(CCNode *)parent z:(int)z;

// will set an anchor point to "node" but keep its relative position
+ (void)setAnchorPoint:(CGPoint)anchorPoint keepingRelativePositionOfNode:(CCNode *)node;

// will calculate the relative position for an anchor point of "node"
+ (CGPoint)calcRelativePositionForAnchorPoint:(CGPoint)anchorPoint ofNode:(CCNode *)node;

// show animation sprite at the index relative to "progress" of "anim"
+ (void)setAnimationProgress:(float)progress ofAnimation:(CCAnimation *)anim inSprite:(CCSprite *)sprite;

// calculates the angle between two points in radians
+ (float)angleBetweenPoint1:(CGPoint)p1 andPoint2:(CGPoint)p2;

// returns the full path to the file in either the application storage or the bundle's resources
// return nil if it is nowhere to be found
+ (NSString *)getContentFile: (NSString *)fileName;

+ (NSString *)applicationStorage;
+ (NSString *)bundleStorage;
+ (NSString *)bundleStorageFile:(NSString *)file;

// shuffle an array
// taken from http://ykyuen.wordpress.com/2010/06/19/objective-c-how-to-shuffle-a-nsmutablearray/
+ (void)shuffleArray:(NSMutableArray *)anArray;

+ (CGFloat) distanceBetweenPointOne:(CGPoint) point1 andPointTwo:(CGPoint) point2;

@end
