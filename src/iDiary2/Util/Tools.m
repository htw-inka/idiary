//
//  Tools.m
//  iPadPresenter
//
//  Created by Markus Konrad on 01.12.10.
//  Copyright 2010 INKA Forschungsgruppe. All rights reserved.
//

#import "Tools.h"


@implementation Tools

#pragma mark cocos2d helpers

+ (CGPoint)convertTouchToGLPoint:(UITouch *)touch {
    CGPoint point = [touch locationInView:[touch view]];    // get the point according to the UIView which has been touched
    return [[CCDirector sharedDirector] convertToGL:point];   // convert this point into GL space
}

+ (CGRect)absoluteBoundingBoxForNode:(CCNode *)node {
    CGRect absBB = [node boundingBoxInPixels];
        
    CGRect parentBB;
    
    // loop through parent nodes because all positions are relative to parent nodes!
    CCNode *parentNode = [node parent];
    while (parentNode != nil && [parentNode isKindOfClass:[CCNode class]]) {        
        parentBB = [parentNode boundingBox];
        absBB.origin.x += parentBB.origin.x;
        absBB.origin.y += parentBB.origin.y;
        
        parentNode = [parentNode parent];
    }
    
    return absBB;
}

+ (CGRect)absoluteBoundingBoxInPixelsForNode:(CCNode *)node {
    CGRect absBB = [node boundingBoxInPixels];
    
    CGRect parentBB;
    
    // loop through parent nodes because all positions are relative to parent nodes!
    CCNode *parentNode = [node parent];
    while (parentNode != nil && [parentNode isKindOfClass:[CCNode class]]) {        
        parentBB = [parentNode boundingBoxInPixels];
        absBB.origin.x += parentBB.origin.x;
        absBB.origin.y += parentBB.origin.y;
        
        parentNode = [parentNode parent];
    }
    
    return absBB;
}

+ (CGRect)absoluteRectForRect:(CGRect)r inNode:(CCNode *)node {
    CGRect parentBB;
    
    // loop through parent nodes because all positions are relative to parent nodes!
    CCNode *parentNode = [node parent];
    while (parentNode != nil && [parentNode isKindOfClass:[CCNode class]]) {        
        parentBB = [parentNode boundingBox];
        r.origin.x += parentBB.origin.x;
        r.origin.y += parentBB.origin.y;
        
        parentNode = [parentNode parent];
    }
    
    return r;
}

+ (BOOL)touch:(UITouch *)t isInNode:(CCNode *)node {
    return [Tools point:[Tools convertTouchToGLPoint:t] isInNode:node];
}

+ (BOOL)touch:(UITouch *)t isInNode:(CCNode *)node usingRadius:(float)r {
    return [Tools point:[Tools convertTouchToGLPoint:t] isInNode:node usingRadius:r];
}

+ (BOOL)touch:(UITouch *)t isInRect:(CGRect)rect {
    return CGRectContainsPoint(rect, [Tools convertTouchToGLPoint:t]);
}


+ (BOOL)point:(CGPoint)p isInNode:(CCNode *)node {
    return CGRectContainsPoint([Tools absoluteBoundingBoxForNode:node], p);
}

+ (NSValue *)hitPointInNode:(CCNode *)node forPoint:(CGPoint)p {
    CGRect bounds = [Tools absoluteBoundingBoxForNode:node];
    
    if (!CGRectContainsPoint(bounds, p)) {
        return nil;
    } else {
        // normalize:
        p.x -= bounds.origin.x;
        p.y -= bounds.origin.y; 
               
        return [NSValue valueWithCGPoint:p];
    }
}

+ (BOOL)point:(CGPoint)p isInNode:(CCNode *)node usingRadius:(float)r {
    CGRect bounds = [Tools absoluteBoundingBoxForNode:node];
    CGPoint n = bounds.origin;
    n.x = n.x + bounds.size.width / 2.0f;
    n.y = n.y + bounds.size.height / 2.0f;
    
    float dX = (p.x - n.x);
    float dY = (p.y - n.y);
    
    return (dX * dX + dY * dY) <= (r * r);
}

+ (void)addChild:(CCNode *)child keepingRelativePositionOfNode:(CCNode *)parent {
    [Tools addChild:child keepingRelativePositionOfNode:parent z:INT_MIN];
}

+ (void)addChild:(CCNode *)child keepingRelativePositionOfNode:(CCNode *)parent z:(int)z {
    // use relative position
    CGPoint newPos = ccpSub(child.position, parent.position);
    [child setPosition:newPos];
    
    // add the child
    if (z == INT_MIN) {
        [parent addChild:child];
    } else {
        [parent addChild:child z:z];
    }
}

// will set an anchor point to "node" but keep its relative position
+ (void)setAnchorPoint:(CGPoint)anchorPoint keepingRelativePositionOfNode:(CCNode *)node {
    CGPoint newPos = [Tools calcRelativePositionForAnchorPoint:anchorPoint ofNode:node];
    [node setAnchorPoint:anchorPoint];
    [node setPosition:newPos];
}

// will calculate the relative position for an anchor point of "node"
+ (CGPoint)calcRelativePositionForAnchorPoint:(CGPoint)anchorPoint ofNode:(CCNode *)node {
    return ccpAdd(node.position, ccp((anchorPoint.x - 0.5f) * node.contentSize.width, (anchorPoint.y - 0.5f) * node.contentSize.height));
}

+ (void)setAnimationProgress:(float)progress ofAnimation:(CCAnimation *)anim inSprite:(CCSprite *)sprite {
    CCSpriteFrame *frame = [anim.frames objectAtIndex:(int)(progress * (float)([anim.frames count] - 1))];
    [sprite setDisplayFrame:frame];
}

+ (float)angleBetweenPoint1:(CGPoint)p1 andPoint2:(CGPoint)p2 {
    return ccpToAngle(ccpSub(p2, p1));
}

#pragma mark file management

+ (NSString*)getContentFile: (NSString *)fileName {
    NSFileManager *fman = [NSFileManager defaultManager];
    
    // if it is already an absolute path, just check if the file exists or return nil
    if ([fileName isAbsolutePath]) {
        if ([fman fileExistsAtPath:fileName])
            return fileName;
        else
            return nil;
    }
    
    // create the path to the file in the document storage    
    NSString *pathInStorage = [[[Tools applicationStorage]
                                stringByAppendingPathComponent:@"/contents"]
                               stringByAppendingPathComponent:fileName];
    
    // if it exists, return it
    if ([fman fileExistsAtPath:pathInStorage]) {
        return pathInStorage;
    } else {    // else look in the application bundle
        NSString *pathInBundle =  [[Tools bundleStorage]
                                   stringByAppendingPathComponent:fileName];
        if ([fman fileExistsAtPath:pathInBundle])
            return pathInBundle;
    }
    
    // or return nil if the file is nowhere
    return nil;
}

+ (NSString *)applicationStorage {
	NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *path = [docPaths objectAtIndex: 0];
	
	return path;
}

+ (NSString *)bundleStorage {
    return [[NSBundle mainBundle] resourcePath];    
}

+ (NSString *)bundleStorageFile:(NSString *)file {
    return [[Tools bundleStorage] stringByAppendingPathComponent:file];
}

#pragma mark misc

+ (void)shuffleArray:(NSMutableArray *)anArray {
    // taken from http://ykyuen.wordpress.com/2010/06/19/objective-c-how-to-shuffle-a-nsmutablearray/

    /* anArray is a NSMutableArray with some objects */
    srandom(time(NULL));
    NSUInteger count = [anArray count];
    for (NSUInteger i = 0; i < count; ++i) {
        int nElements = count - i;
        int n = (random() % nElements) + i;
        [anArray exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

+ (CGFloat) distanceBetweenPointOne:(CGPoint) point1 andPointTwo:(CGPoint) point2 {
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    return sqrt(dx*dx + dy*dy );
}

@end
