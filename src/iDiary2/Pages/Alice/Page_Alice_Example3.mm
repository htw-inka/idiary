//
//  Page_Alice_Example3.m
//  iDiary2
//
//  Created by Markus Konrad on 13.06.12.
//  Copyright (c) 2012 INKA Forschungsgruppe. All rights reserved.
//

#import "Page_Alice_Example3.h"

// Define Z-Orders
enum {
    kPhotoHeapZ = 2,
    kLetterCoverZ
};

@implementation Page_Alice_Example3

- (id)init {
    self = [super initWithEnabledPhysicsOfType:kB2dWorldTypeTable]; // phys. environment: simulate a table
    if (self) {
        // Create a PhotoHeapLayer on this page in the physical environment ("box2d world")
        photoHeap = [[PhotoHeapLayer alloc] initOnPageLayer:self withBox2DWorld:box2DWorldAttribs->world];
        
        [box2D setDelegate:photoHeap];  // PhotoHeap gets notified on physics updates
        
        // add movements borders
        int h = core.screenH;
        int envelopeLeftX = 100;
        int envelopeRightX = 410;
        int envelopeBottomY = h - 670;
        int envelopeTopY = h - 215;
        
        [photoHeap addMovementBorderFromPoint:ccp(envelopeLeftX,0)                  toPoint:ccp(envelopeLeftX, h) blockDirection:kDirectionLeft];  // left envelope border
        [photoHeap addMovementBorderFromPoint:ccp(0,envelopeBottomY)                toPoint:ccp(envelopeRightX, envelopeBottomY) blockDirection:kDirectionDown];  // bottom envelope border
        [photoHeap addMovementBorderFromPoint:ccp(0,envelopeTopY)                   toPoint:ccp(envelopeRightX, envelopeTopY) blockDirection:kDirectionUp];  // top envelope border
        [photoHeap addMovementBorderFromPoint:ccp(envelopeRightX,envelopeBottomY)   toPoint:ccp(envelopeRightX, 0) blockDirection:kDirectionLeft];  // border beneath envelope
        [photoHeap addMovementBorderFromPoint:ccp(envelopeRightX,envelopeTopY)      toPoint:ccp(envelopeRightX, h) blockDirection:kDirectionLeft];  // border above envelope
        [photoHeap addMovementBorderFromPoint:ccp(1000,0)                           toPoint:ccp(950,h) blockDirection:kDirectionRight]; // border right screen end
                                        
        // set it as child
        [self addChild:photoHeap z:kPhotoHeapZ];

    }
    return self;
}

- (void)dealloc {
    [box2D setDelegate:nil];  // important! photoHeap will be released, so don't notify it anymore
    [photoHeap release];

    [super dealloc];
}

- (void)loadPageContents {
    // set individual properties
    pageBackgroundImg = @"alice_seiten_hintergrund.png";
      
    // add individual media objects for this page here
    MediaDefinition *mDefWelcomeText = [MediaDefinition mediaDefinitionWithText:@"This page shows how to use the PhotoHeapLayer class."
                                                                           font:@"Courier New"
                                                                       fontSize:18
                                                                          color:ccBLACK
                                                                         inRect:CGRectMake(60, 700, 350, 100)];
    
    [mediaObjects addObject:mDefWelcomeText];
    
    // add photos to photo heap
    [photoHeap addPhoto:@"alice_example3__foto4.jpg" atPos:ccp(303, 288)];
    [photoHeap addPhoto:@"alice_example3__foto3.jpg" atPos:ccp(277, 404)];
    [photoHeap addPhoto:@"alice_example3__foto5.jpg" atPos:ccp(345, 270)];
    [photoHeap addPhoto:@"alice_example3__foto2.jpg" atPos:ccp(277, 377)];
    [photoHeap addPhoto:@"alice_example3__foto1.jpg" atPos:ccp(259, 288)];
    
    // add the letter cover
    [mediaObjects addObject:[MediaDefinition mediaDefinitionOfType:MEDIA_TYPE_PICTURE withValue:@"alice_example3__umschlag-u_8.png" inRect:CGRectMake(366, 319, 560, 583)]];
    
    MediaDefinition *letterCoverDef = [MediaDefinition mediaDefinitionOfType:MEDIA_TYPE_PICTURE withValue:@"alice_example3__umschlag_o_b.png" inRect:CGRectMake(304, 319, 436, 583)];
    [letterCoverDef setZIndex:kLetterCoverZ];   // set the z-order manually
    [mediaObjects addObject:letterCoverDef];
        
    // show the photos as interactive elements
    [interactiveElements addObjectsFromArray:photoHeap.photos];
    
    // register them as persistant
    [persistentElements addObjectsFromArray:photoHeap.photos];
    [mainLayer registerPersistentElements:photoHeap.photos];

    // common media objects will be loaded in the PageLayer
    [super loadPageContents];

}


@end
