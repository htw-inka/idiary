//
//  PanningLayerDelegate.h
//  FUMediaStation
//
//  Created by Michael Witt on 10.01.12.
//  Copyright (c) 2012 Hello IT GbR. All rights reserved.
//
//  ************************************************************************************
//  * Usage of this class is only permitted for the iDiary project in INKA/HardMut II! *
//  ************************************************************************************
//

#import <Foundation/Foundation.h>

@class PanningLayer;

@protocol PanningLayerDelegate <NSObject>

/**
 * Informs the delegate that the viewport will change to the following position 
 * and the specified nodes will become visible
 * @param layer panning layer that caused the action
 * @param offset New content offset
 * @param nodes All visible nodes
 */
- (void) panningLayer:(PanningLayer*)layer willMoveToOffset:(CGPoint)offset displayingNodes:(NSArray*)nodes;

@optional

/**
 * Informs the delegate that the viewport is now at this point
 * @param layer panning layer that caused the action
 * @param offset New content offset
 */
- (void) panningLayer:(PanningLayer*)layer isNowAtOffset:(CGPoint)offset;

/**
 * The panning layer did begin to start panning
 * @param layer panning layer that caused the action 
 */
- (void) panningLayerStartedPanning:(PanningLayer*)layer;

/**
 * The panning layer did begin to start panning
 * @param layer panning layer that caused the action 
 */
- (void) panningLayerFinishedPanning:(PanningLayer*)layer;

@end
