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
