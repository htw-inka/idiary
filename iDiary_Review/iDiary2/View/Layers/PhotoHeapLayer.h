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
