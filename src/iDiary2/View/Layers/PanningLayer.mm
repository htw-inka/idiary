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
//  PanningLayer.m
//  FUMediaStation
//
//  Created by Michael Witt on 10.01.12.
//  Copyright 2012 Hello IT GbR. All rights reserved.
//
//  ************************************************************************************
//  * Usage of this class is only permitted for the iDiary project in INKA/HardMut II! *
//  ************************************************************************************
//

#import <objc/runtime.h>
#import "PanningLayer.h"
#import "Tools.h"

#define FIX_BOUNDS_OF_POINT(p, min, max) ccp(MIN(max.x, MAX(min.x, p.x)), MIN(max.y, MAX(min.y, p.y)))

// Our default configuration
const CGFloat PanningLayerDefaultXOverPanningFactor = 0.0f;
const CGFloat PanningLayerDefaultYOverPanningFactor = 0.0f;
const CGFloat PanningLayerDefaultVelocityFactor = 0.1f;
const CGFloat PanningLayerDefaultVelocityAnimationDuration = 0.2f;
NSString* PanningLayerDefaultVelocityAnimationClass = @"CCEaseSineOut";
const CGFloat PanningLayerDefaultBounceAnimationDuration = 0.5f;
NSString* PanningLayerDefaultBounceAnimationClass = @"CCEaseSineOut";

const CGFloat ZoomablePanningLayerDefaultPinchSpeedFactor = 0.5f;
const CGFloat ZoomablePanningLayerDefaultMinZoom = 0.5f;
const CGFloat ZoomablePanningLayerDefaultMaxZoom = 10.0f;

@interface PanningLayer(Private)

/**
 * Inital setup for the layer
 */
- (void) setup;

/**
 * Panning callback for the gesture recognizer
 * @param gestureRecognizer Gesture Recognizer that caused the action
 */
- (void) pan:(UIPanGestureRecognizer*)gestureRecognizer;

/**
 * Fix the requested position of the panning layer node to keep it inside configured bounds
 * @param requestedPosition The requested position
 * @param overpanning Is overpanning allowed
 * @param snapIn Perform snapping in
 * @return Fixed position
 */
- (CGPoint) fixPosition:(CGPoint)position allowOverPanning:(BOOL)overpanning performSnapIn:(BOOL)snapIn;

/**
 * Search the matching snap position in the specified array
 * @param input Input value to snap
 * @param values sorted array with possible values
 * @param s Scale that is applied to the coordinate
 * @return Snapped value
 */
- (CGFloat) snapValue:(CGFloat)input toSnaps:(NSArray*)values scale:(CGFloat)s;

/**
 * Inform the delegate about the new position
 * @param position New content offset
 */
- (void) informDelegate:(CGPoint)position;
- (void) informDelegate:(CGPoint)position aboutContinuousMovement:(BOOL)contMove;

@end

@implementation PanningLayer 

@synthesize delegate;
@synthesize velocityFactor;
@synthesize xOverPanningFactor;
@synthesize yOverPanningFactor;
@synthesize velocityAnimationDuration;
@synthesize bounceAnimationDuration;
@synthesize snapX;
@synthesize snapY;
@synthesize usePanningRect;
@synthesize panningRect;

- (id)initWithColor:(ccColor4B)color {
    // Don't forget to super init
    self = [super initWithColor:color];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (id)initWithColor:(ccColor4B)start fadingTo:(ccColor4B)end alongVector:(CGPoint)v {
    // Don't forget to super init
    self = [super initWithColor:start fadingTo:end alongVector:v];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (BOOL)isNodeVisible:(CCNode *)node {
    // Build the visible rectangle
    CGPoint position = [scrollingNode position];
    CGRect displayRect = CGRectMake(-position.x, -position.y, [self contentSize].width, [self contentSize].height);
    
    // Search newly displayed nodes
    return CGRectContainsRect(displayRect, [node boundingBox]);
}

- (NSArray *)getNodesAtPosition:(CGPoint)position {
    // Convert the position
    CGPoint p = [scrollingNode position];
    p.x = -p.x + position.x;
    p.y = -p.y + position.y;
    
    return [self getNodesAtOffset:p];
}

- (NSArray *)getNodesAtOffset:(CGPoint)position {
    NSMutableArray* result = [NSMutableArray array];
    
    for (CCNode* node in [scrollingNode children]) {
        if (CGRectContainsPoint([node boundingBox], position)) {
            [result addObject:node];
        }
    }
    
    return result;
}

#pragma mark mouse handling

- (void) pan: (UIPanGestureRecognizer*)gestureRecognizer {
    // We need to remember where the touch started
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        // We were touched, so the panning will start
        touchStart = [scrollingNode position];
        
        if ([delegate respondsToSelector:@selector(panningLayerStartedPanning:)]) {
            [delegate panningLayerStartedPanning:self];
        }
    }
    
    // Get the translation, but remember that y is inverted
    CGPoint translation = [gestureRecognizer translationInView:[[CCDirector sharedDirector] openGLView]];
    translation.y = -translation.y;
    
    // Map the position to fit in bounds
    CGPoint position = [self fixPosition:ccpAdd(touchStart, translation) allowOverPanning:YES performSnapIn:NO];
    
    // Set new position
    [scrollingNode setPosition:position];
    
    [self informDelegate:position aboutContinuousMovement:YES];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        // Perform the velocity zoom and then scale back to minimum zoom if needed
        CGPoint velocityTranslation = ccpMult([gestureRecognizer velocityInView:[[CCDirector sharedDirector] openGLView]], velocityFactor);
        velocityTranslation.y = -velocityTranslation.y;
        
        // Calculate the new position after the velocity translation
        position = [self fixPosition:ccpAdd(position, velocityTranslation) allowOverPanning:YES performSnapIn:NO];
        
        // Check if we need a bounce back and build an appropriate animation
        CCAction* action = nil;
        
        // Check if we need to "snap back" the position
        CGPoint snapBackPosition = [self fixPosition:position allowOverPanning:NO performSnapIn:YES];
        
        if (snapX || snapY) {
            action = [velocityAnimationClass actionWithAction: [CCMoveTo actionWithDuration:velocityAnimationDuration position:snapBackPosition]];
        }
        else if (CGPointEqualToPoint(position, snapBackPosition)) {
            action = [velocityAnimationClass actionWithAction: [CCMoveTo actionWithDuration:velocityAnimationDuration position:position]];
        }
        else if (CGPointEqualToPoint(position, [scrollingNode position])) {
            // Build an action sequence for velocity animation and bounce back
            action = [bounceAnimationClass actionWithAction: [CCMoveTo actionWithDuration:bounceAnimationDuration position:snapBackPosition]];
        }
        else {
            // Build an action sequence for velocity animation and bounce back
            action = [CCSequence actions: 
                      [velocityAnimationClass actionWithAction: [CCMoveTo actionWithDuration:velocityAnimationDuration position:position]], 
                      [bounceAnimationClass actionWithAction: [CCMoveTo actionWithDuration:bounceAnimationDuration position:snapBackPosition]], 
                      nil];
        } 
        
        // Run the action
        [scrollingNode runAction:action];
        
        // We are no longer panning
        panning = NO;
        lastPanningTime = CACurrentMediaTime();
        if ([delegate respondsToSelector:@selector(panningLayerFinishedPanning:)]) {
            [delegate panningLayerFinishedPanning:self];
        }
        
        // Inform the delegate about visible nodes
        [self informDelegate:snapBackPosition];
    }
}

#pragma mark UIGestureRecognizerDelegate messages

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint p = [Tools convertTouchToGLPoint:touch];
    CGRect r = (usePanningRect) ? [Tools absoluteRectForRect:panningRect inNode:self] : [Tools absoluteBoundingBoxForNode:self];

    return CGRectContainsPoint(r, p);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

#pragma mark parent messages

- (void)setIsTouchEnabled:(BOOL)isTouchEnabled {
    if (isTouchEnabled == [self isTouchEnabled]) {
        return;
    }
    
    [super setIsTouchEnabled:isTouchEnabled];
    
    if (isTouchEnabled) {
        [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:panGestureRecognizer];
    } else {
        [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:panGestureRecognizer];
    }
}

- (void)visit {
    glEnable(GL_SCISSOR_TEST);
    
    CGRect bb = [Tools absoluteBoundingBoxInPixelsForNode:self];
    glScissor(bb.origin.x, bb.origin.y, bb.size.width, bb.size.height);
    
    [super visit];
    
    glDisable(GL_SCISSOR_TEST);
}

- (void)addChild:(CCNode *)node z:(NSInteger)z tag:(NSInteger)tag {
    if (node == scrollingNode) {
        [super addChild:node z:z tag:tag];
    } else {
        [scrollingNode addChild:node z:z tag:tag];
    }
}

- (void)removeChild:(CCNode *)node cleanup:(BOOL)cleanup {
    if (node == scrollingNode) {
        [super removeChild:node cleanup:cleanup];
    } else {
        [scrollingNode removeChild:node cleanup:cleanup];
    }
}

- (void)removeAllChildrenWithCleanup:(BOOL)cleanup {
    [scrollingNode removeAllChildrenWithCleanup:cleanup];
}

- (CCNode *)getChildByTag:(NSInteger)tag {
    return [scrollingNode getChildByTag:tag];
}

- (void)setOpacity:(GLubyte)opacity {
    [super setOpacity:opacity];
    
    for (CCNode* node in [scrollingNode children]) {
        if ([node respondsToSelector:@selector(setOpacity:)]) {
            [(id<CCRGBAProtocol>)node setOpacity:opacity];
        }
    }
}

- (void)setScrollingContentScale:(CGFloat)scrollingContentScale {
    zoom = scrollingContentScale;
    [scrollingNode setScale:scrollingContentScale];

    CGPoint p = [self fixPosition:[scrollingNode position] allowOverPanning:NO performSnapIn:YES];
    [scrollingNode setPosition:p];
}

- (CGFloat)scrollingContentScale {
    return zoom;
}

- (void)dealloc {
    [self setIsTouchEnabled:NO];
    [panGestureRecognizer release];    
    [self setSnapX:nil];
    [self setSnapY:nil];
    
    [super dealloc];
}

#pragma mark scrolling node properties

- (void)setScrollingContentSize:(CGSize)scrollingContentSize {
    [scrollingNode setContentSize:scrollingContentSize];
}

- (CGSize)scrollingContentSize {
    return [scrollingNode contentSize];
}

- (void)setScrollingContentOffset:(CGPoint)scrollingContentOffset {
    [self setScrollingContentOffset:scrollingContentOffset animated:NO];
}

- (void) setScrollingContentOffset:(CGPoint)scrollingContentOffset animated:(BOOL)animate {
    [self setScrollingContentOffset:scrollingContentOffset animated:animate duration:velocityAnimationDuration];
}    

- (void)setScrollingContentOffset:(CGPoint)scrollingContentOffset animated:(BOOL)animate duration:(CGFloat)duration {
    scrollingContentOffset.x = -scrollingContentOffset.x;
    scrollingContentOffset.y = -scrollingContentOffset.y;
    scrollingContentOffset = [self fixPosition:scrollingContentOffset allowOverPanning:NO performSnapIn:YES];

    [scrollingNode stopAllActions];
    if (animate) {
        [scrollingNode runAction:[velocityAnimationClass actionWithAction: [CCMoveTo actionWithDuration:duration position:scrollingContentOffset]]];
    } else {
        [scrollingNode setPosition:scrollingContentOffset];
    }
    
    [self informDelegate:scrollingContentOffset];
}

- (CGPoint)scrollingContentOffset {
    CGPoint p = [scrollingNode position];
    p.x = -p.x;
    p.y = -p.y;
    return p;
}

#pragma mark positions

- (void)setSnapX:(NSArray *)newSnapX {
    // Delete old values
    [snapX release];
    snapX = nil;
    
    if (newSnapX) {
        snapX = [[newSnapX sortedArrayUsingSelector:@selector(compare:)] retain];
    }
}

- (void)setSnapY:(NSArray *)newSnapY {
    // Delete old values
    [snapY release];
    snapY = nil;
    
    if (newSnapY) {
        snapY = [[newSnapY sortedArrayUsingSelector:@selector(compare:)] retain];
    }
}

#pragma mark animations classes properties

- (void)setVelocityAnimationClass:(NSString *)newVelocityAnimationClass {
    velocityAnimationClass = NSClassFromString(newVelocityAnimationClass);
}

- (NSString*) velocityAnimationClass {
    return [NSString stringWithCString:class_getName(velocityAnimationClass) encoding:NSASCIIStringEncoding]; 
}

- (void)setBounceAnimationClass:(NSString *)newBounceAnimationClass {
    bounceAnimationClass = NSClassFromString(newBounceAnimationClass);
}

- (NSString *)bounceAnimationClass {
    return [NSString stringWithCString:class_getName(bounceAnimationClass) encoding:NSASCIIStringEncoding]; 
}

#pragma mark private methods

- (void)setup {
    [self setAnchorPoint:CGPointZero];
    // Assign default values to ourself
    velocityFactor = PanningLayerDefaultVelocityFactor;
    velocityAnimationDuration = PanningLayerDefaultVelocityAnimationDuration;
    xOverPanningFactor = PanningLayerDefaultXOverPanningFactor;
    yOverPanningFactor = PanningLayerDefaultYOverPanningFactor;
    
    velocityAnimationDuration = PanningLayerDefaultVelocityAnimationDuration;
    bounceAnimationDuration = PanningLayerDefaultBounceAnimationDuration;
    
    [self setVelocityAnimationClass:PanningLayerDefaultVelocityAnimationClass];
    [self setBounceAnimationClass:PanningLayerDefaultBounceAnimationClass];
    
    // Register the pan gesture recognizer
    panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [panGestureRecognizer setDelaysTouchesBegan:NO];
    [panGestureRecognizer setCancelsTouchesInView:NO];
    [panGestureRecognizer setDelegate:self];
    
    // Default the scrolling content size is the same as the content size
    scrollingNode = [CCNode node];
    [scrollingNode setAnchorPoint:CGPointZero];
    [scrollingNode setScale:1.0f];
    [self addChild:scrollingNode];
    zoom = 1.0f;
    
    // Panning is enabled on the whole node
    usePanningRect = NO;
    panningRect = CGRectZero;
    
    // Not currently panning
    panning = NO;
    lastPanningTime = 0.0f;
}

- (CGPoint)fixPosition:(CGPoint)position allowOverPanning:(BOOL)overpanning performSnapIn:(BOOL)snapIn {
    // Calculate the scaled size
    CGSize cSize = [self contentSize];
    CGSize cScaled = CGSizeMake(cSize.width, cSize.height);
    CGSize t = [scrollingNode contentSize];
    t.width *= zoom;
    t.height *= zoom;
    
    CGPoint boundsMin = ccp(-t.width + cScaled.width, -t.height + cScaled.height);
    CGPoint boundsMax = ccp(0.0f, 0.0f);

    if (overpanning) {
        boundsMin.x -= ([self contentSize].width * xOverPanningFactor);
        boundsMin.y -= ([self contentSize].height * yOverPanningFactor);
        
        boundsMax.x += ([self contentSize].width * xOverPanningFactor);
        boundsMax.y += ([self contentSize].height * yOverPanningFactor);
    }
    
    CGPoint result = FIX_BOUNDS_OF_POINT(position, boundsMin, boundsMax);
    
    if (snapIn) {
        // Keep in mind that x is inverted
        result.x = -[self snapValue:-result.x toSnaps:snapX scale:zoom];
        result.y = -[self snapValue:-result.y toSnaps:snapY scale:zoom];
        
        // Check if snapping messed up our result
        result = FIX_BOUNDS_OF_POINT(result, boundsMin, boundsMax);
    }
    
    return result;
}

- (CGFloat)snapValue:(CGFloat)input toSnaps:(NSArray *)values scale:(CGFloat)s {
    // Check if values exist
    if (values == nil) {
        return input;
    }
    else if ([values count] == 1) {
        return [[values objectAtIndex:0] floatValue] * s;
    }
    else {
        // Remove the scale from the input value
        input /= s;
        
        // Perform a simple binary search
        int begin = 0;
        int end = [values count] - 1;
        int index = begin + ((end - begin) / 2);
        
        while (begin <= end) {
            CGFloat value = [[values objectAtIndex:index] floatValue];

            if (value < input) {
                begin = index + 1;
            } else if (value > input) {
                end = index - 1;
            } else {
                begin = index;
                end = index;
                break;
            }
            
            index = begin + ((end - begin) / 2);
        }
        
        // Check which item is near to the searched one
        CGFloat d1 = [[values objectAtIndex:index] floatValue];
        CGFloat d2 = (d1 > input) ? [[values objectAtIndex:MAX(0, index - 1)] floatValue] : [[values objectAtIndex:MIN(index + 1, [values count] - 1)] floatValue];
        
        // Return the nearest result and apply back the scale
        if (fabsf(input - d1) < fabsf(input - d2)) {
            return d1 * s;
        } else {
            return d2 * s;
        }
    }
}

- (void)informDelegate:(CGPoint)position {
    [self informDelegate:position aboutContinuousMovement:NO];
}

- (void)informDelegate:(CGPoint)position aboutContinuousMovement:(BOOL)contMove {
    // Nothing to do if no delegate is available
    if (delegate == nil) {
        return;
    }
    
    // Fix axis inversion
    position.x = -position.x;
    position.y = -position.y;
    
    // Build the visible rectangle
    CGRect displayRect = CGRectMake(position.x, position.y, [self contentSize].width, [self contentSize].height);
    
    // Search newly displayed nodes
    NSMutableArray* result = [NSMutableArray array];
    for (CCNode* node in [scrollingNode children]) {
        if (CGRectIntersectsRect(displayRect, [node boundingBox])) {
            [result addObject:node];
        }
    }
    
    if (contMove && [delegate respondsToSelector:@selector(panningLayer:isNowAtOffset:)]) {
        [delegate panningLayer:self isNowAtOffset:position];
    } else if (!contMove) {
        [delegate panningLayer:self willMoveToOffset:position displayingNodes:result];    
    }
}

@end

@interface ZoomablePanningLayer(Private)

/**
 * Inital setup for the layer
 */
- (void) setupGestures;

/**
 * Tapping callback for the gesture recognizer
 * @param gestureRecognizer Gesture Recognizer that caused the action
 */
- (void) tap:(UITapGestureRecognizer*)gestureRecognizer;

/**
 * Pinching callback for the gesture recognizer
 * @param gestureRecognizer Gesture Recognizer that caused the action
 */
- (void) pinch:(UIPinchGestureRecognizer*)gestureRecognizer;

/**
 * Fix the requested scale to stay within bounds
 * @param s Requested scale
 * @return Fixed value
 */
- (CGFloat) fixScale:(CGFloat)s;

/**
 * Calculate the new scrolling content offset when doing a zoom so 
 * it feel like zooming happens with the specified center
 * @param startZoom Original zooming factor that was applied when zooming started
 * @param startPosition Position of the content layer when startZoom was applied
 * @param center Center point of the zooming process
 * @param newZoom New zooming factor
 * @return New content position
 */
- (CGPoint) positionForZoomingFromFactor:(CGFloat)startZoom fromPosition:(CGPoint)startPosition withZoomingCenter:(CGPoint)center toFactor:(CGFloat)newZoom;

@end

@implementation ZoomablePanningLayer

@synthesize maxZoom;
@synthesize minZoom;
@synthesize pinchSpeedFactor;

- (id)initWithColor:(ccColor4B)color {
    // Don't forget to super init
    self = [super initWithColor:color];
    
    if (self) {
        [self setupGestures];
    }
    
    return self;
}

- (id)initWithColor:(ccColor4B)start fadingTo:(ccColor4B)end alongVector:(CGPoint)v {
    // Don't forget to super init
    self = [super initWithColor:start fadingTo:end alongVector:v];
    
    if (self) {
        // Create the gesture recognizer
        [self setupGestures];
    }
    
    return self;
}

#pragma mark touch handling

- (void)pinch:(UIPinchGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        zoomStartFactor = zoom;
        zoomStartPosition = [self scrollingContentOffset];
        
        // Calculate the zooming center
        CGPoint p0 = [[CCDirector sharedDirector] convertToGL:[gestureRecognizer locationOfTouch:0 inView:[gestureRecognizer view]]];
        p0 = [self convertToNodeSpace:p0];
        CGPoint p1 = [[CCDirector sharedDirector] convertToGL:[gestureRecognizer locationOfTouch:1 inView:[gestureRecognizer view]]];
        p1 = [self convertToNodeSpace:p1];
        zoomStartCenter = ccp(zoomStartPosition.x + ((p0.x + p1.x) / 2.0f), zoomStartPosition.y + ((p0.y + p1.y) / 2.0f));
    }
    
    // Ease the zooming speed a bit
    CGFloat fixedScale = 1.0f + (([gestureRecognizer scale] - 1.0f) * pinchSpeedFactor);
    
    // Apply the new content scale
    [self setScrollingContentScale:[self fixScale:zoomStartFactor * fixedScale]];
    
    // Calculate the change in size and resulting change in position
    CGPoint p = [self positionForZoomingFromFactor:zoomStartFactor fromPosition:zoomStartPosition withZoomingCenter:zoomStartCenter toFactor:zoom];
    [self setScrollingContentOffset:p];
}

- (void) tap:(UITapGestureRecognizer*)gestureRecognizer {
    // Zoom in by 50% on double tap
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        // Calculate the new scale
        CGFloat newScale = [self fixScale:zoom * 1.5f];
        
        // Calculate the scaling center by converting the touch location to our space
        CGPoint center = [[CCDirector sharedDirector] convertToGL:[gestureRecognizer locationInView:[gestureRecognizer view]]];
        center = ccpAdd([self scrollingContentOffset], [self convertToNodeSpace:center]);
        
        // Calculate the new content offset
        CGPoint p = [self positionForZoomingFromFactor:zoom fromPosition:[self scrollingContentOffset] withZoomingCenter:center toFactor:newScale];
        
        CCActionInstant* zoomAnimation = [CCEaseSineOut actionWithAction:[CCScaleTo actionWithDuration:0.2f scale:newScale]];
        zoom = newScale;
    
        [self setScrollingContentOffset:p animated:YES];
        [scrollingNode runAction:zoomAnimation];
    }
}

#pragma mark UIGestureRecognizerDelegate messages

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == panGestureRecognizer || otherGestureRecognizer == panGestureRecognizer) {
        return NO;
    } else {
        return (otherGestureRecognizer == pinchGestureRecognizer || otherGestureRecognizer == tapGestureRecognizer);
    }
}

#pragma mark parent messages

- (void)dealloc {
    [tapGestureRecognizer release];
    [pinchGestureRecognizer release];
    
    [super dealloc];
}

#pragma mark private messages

- (void)setIsTouchEnabled:(BOOL)isTouchEnabled {
    if (isTouchEnabled == [self isTouchEnabled]) {
        return;
    }
    
    [super setIsTouchEnabled:isTouchEnabled];
    
    if (isTouchEnabled) {
        [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:tapGestureRecognizer];
        [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:pinchGestureRecognizer];
    } else {
        [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:tapGestureRecognizer];
        [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:pinchGestureRecognizer];
    }
}

- (void)setupGestures {
    // Setup default values
    pinchSpeedFactor = ZoomablePanningLayerDefaultPinchSpeedFactor;
    minZoom = ZoomablePanningLayerDefaultMinZoom;
    maxZoom = ZoomablePanningLayerDefaultMaxZoom;
    
    // Create the gesture recognizer
    // Tap gesture recognizer for double touch zoom in
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [tapGestureRecognizer setNumberOfTapsRequired:2];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [tapGestureRecognizer setDelegate:self];
    
    // Pinch gesture recognizer for zooming
    pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    [pinchGestureRecognizer setDelegate:self];
}

- (CGFloat)fixScale:(CGFloat)s {
    return MAX(minZoom, MIN(maxZoom, s));
}

- (CGPoint)positionForZoomingFromFactor:(CGFloat)startZoom fromPosition:(CGPoint)startPosition withZoomingCenter:(CGPoint)center toFactor:(CGFloat)newZoom {
    // We need the content size
    CGSize s = [self scrollingContentSize];
    
    // Calculate the factorial influence of the zooming center to the new position based on scale factor change
    CGFloat dx = (s.width * (newZoom - startZoom)) * (center.x / (s.width * startZoom));
    CGFloat dy = (s.height * (newZoom - startZoom)) * (center.y / (s.height * startZoom));
    
    return ccp(startPosition.x + dx, startPosition.y + dy);
}

@end
