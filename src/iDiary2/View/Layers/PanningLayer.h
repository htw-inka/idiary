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
//  PanningLayer.h
//  FUMediaStation
//
//  Created by Michael Witt on 10.01.12.
//  Copyright 2012 Hello IT GbR. All rights reserved.
//
//  ************************************************************************************
//  * Usage of this class is only permitted for the iDiary project in INKA/HardMut II! *
//  ************************************************************************************
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "PanningLayerDelegate.h"

extern const CGFloat PanningLayerDefaultXOverPanningFactor;
extern const CGFloat PanningLayerDefaultYOverPanningFactor;
extern const CGFloat PanningLayerDefaultVelocityAnimationDuration;
extern const CGFloat PanningLayerDefaultVelocityFactor;
extern NSString* PanningLayerDefaultVelocityAnimationClass;
extern const CGFloat PanningLayerDefaultBounceAnimationDuration;
extern NSString* PanningLayerDefaultBounceAnimationClass;

extern const CGFloat ZoomablePanningLayerDefaultPinchSpeedFactor;
extern const CGFloat ZoomablePanningLayerDefaultMinZoom;
extern const CGFloat ZoomablePanningLayerDefaultMaxZoom;

@interface PanningLayer : CCLayerGradient<UIGestureRecognizerDelegate> {
    // Delegate
    id<PanningLayerDelegate> delegate;
    
    // Touch start position
    CGPoint touchStart;
    BOOL panning;
    NSTimeInterval lastPanningTime;
    
    // Bounding box where panning is accepted
    BOOL usePanningRect;
    CGRect panningRect;
    
    // Panning detection
    UIPanGestureRecognizer* panGestureRecognizer;
    
    // Velocity multiply factor
    CGFloat velocityFactor;
    
    // Maximum panning of the content beyond the bounds
    CGFloat xOverPanningFactor;
    CGFloat yOverPanningFactor;
    
    // Animation durations
    CGFloat velocityAnimationDuration;
    Class velocityAnimationClass;
    CGFloat bounceAnimationDuration;
    Class bounceAnimationClass;
    
    // The node that is scrolled
    CCNode* scrollingNode;
    
    // snap in points
    NSArray* snapX;
    NSArray* snapY;
    
    // Current content zoom
    CGFloat zoom;
}

@property (nonatomic, assign) id<PanningLayerDelegate> delegate;
@property (nonatomic, assign) CGFloat velocityFactor;
@property (nonatomic, assign) CGFloat xOverPanningFactor;
@property (nonatomic, assign) CGFloat yOverPanningFactor;
@property (nonatomic, assign) CGFloat velocityAnimationDuration;
@property (nonatomic, assign) CGFloat bounceAnimationDuration;
@property (nonatomic, assign) NSString* velocityAnimationClass;
@property (nonatomic, assign) NSString* bounceAnimationClass;
@property (nonatomic, assign) CGSize scrollingContentSize;
@property (nonatomic, assign) CGPoint scrollingContentOffset;
@property (nonatomic, assign) CGFloat scrollingContentScale;
@property (nonatomic, assign) BOOL usePanningRect;
@property (nonatomic, assign) CGRect panningRect;

@property (nonatomic, assign) NSArray* snapX;
@property (nonatomic, assign) NSArray* snapY;

/**
 * Set the new scrolling content offset
 * @param offset New offset
 * @param animate Use an animation if set to YES
 */
- (void) setScrollingContentOffset:(CGPoint)scrollingContentOffset animated:(BOOL)animate;

/**
 * Set the new scrolling content offset
 * @param offset New offset
 * @param animate Use an animation if set to YES
 * @param duration Animation duration
 */
- (void) setScrollingContentOffset:(CGPoint)scrollingContentOffset animated:(BOOL)animate duration:(CGFloat)duration;

/**
 * Check if the specified node is completly visible
 * @param node Node to check
 * @return YES if the node is fully visible, else NO
 */
- (BOOL) isNodeVisible:(CCNode*)node;

/**
 * Return the nodes that are at the specified position
 * @param position Position on the panning layer, it will be automatically transferred to scrolling coordinates
 * @return Array with nodes that are at the specified point
 */
- (NSArray*) getNodesAtPosition:(CGPoint)position;

/**
 * Return the nodes that are at the specified offset
 * @param position Scrolling offset on the panning layer
 * @return Array with nodes that are at the specified point
 */
- (NSArray*) getNodesAtOffset:(CGPoint)position;

@end

// ZoomablePanningLayer is a PanningLayer that allows content zooming
@interface ZoomablePanningLayer : PanningLayer {
    // Gesture recognizer for pinch zoom and magnifying on tapping
    UITapGestureRecognizer* tapGestureRecognizer;
    UIPinchGestureRecognizer* pinchGestureRecognizer;
    
    // Zooming start factor
    CGFloat zoomStartFactor;
    CGPoint zoomStartPosition;
    CGPoint zoomStartCenter;
    
    // Pinching zoom multiply factor
    CGFloat pinchSpeedFactor;
    
    // Minimum possible zoom
    CGFloat minZoom;
    
    // Maximum possible zoom
    CGFloat maxZoom;
}

@property (nonatomic, assign) CGFloat pinchSpeedFactor;
@property (nonatomic, assign) CGFloat minZoom;
@property (nonatomic, assign) CGFloat maxZoom;

@end
