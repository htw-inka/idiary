//
//  Node3D.mm
//  iDiary2
//
//  Created by Markus Konrad on 01.09.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "Node3D.h"

#if CC_COCOSNODE_RENDER_SUBPIXEL
#define RENDER_IN_SUBPIXEL
#else
#define RENDER_IN_SUBPIXEL (NSInteger)
#endif

@implementation Node3D

@synthesize rotationX;
@synthesize rotationY;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)transform {
	// BEGIN original implementation
	// 
	// translate
	if ( [self isRelativeAnchorPoint] && ([self anchorPointInPixels].x != 0 || [self anchorPointInPixels].y != 0 ) )
		glTranslatef( RENDER_IN_SUBPIXEL(-[self anchorPointInPixels].x), RENDER_IN_SUBPIXEL(-[self anchorPointInPixels].y), 0);
	
	if ([self anchorPointInPixels].x != 0 || [self anchorPointInPixels].y != 0)
		glTranslatef( RENDER_IN_SUBPIXEL([self positionInPixels].x + [self anchorPointInPixels].x), RENDER_IN_SUBPIXEL([self positionInPixels].y + [self anchorPointInPixels].y), [self vertexZ]);
	else if ( [self positionInPixels].x !=0 || [self positionInPixels].y !=0 || [self vertexZ] != 0)
		glTranslatef( RENDER_IN_SUBPIXEL([self positionInPixels].x), RENDER_IN_SUBPIXEL([self positionInPixels].y), [self vertexZ] );
	
	// rotate
	if ([self rotation] != 0.0f )
		glRotatef( -[self rotation], 0.0f, 0.0f, 1.0f );
        
    glRotatef(rotationX, 1.0f, 0.0f, 0.0f);
    glRotatef(rotationY, 0.0f, 1.0f, 0.0f);
	
	// scale
	if ([self scaleX] != 1.0f || [self scaleY] != 1.0f)
		glScalef( [self scaleX], [self scaleY], 1.0f );
	
	if ( [self camera] && !([self grid] && [self grid].active) )
		[[self camera] locate];
	
	// restore and re-position point
	if ([self anchorPointInPixels].x != 0.0f || [self anchorPointInPixels].y != 0.0f)
		glTranslatef(RENDER_IN_SUBPIXEL(-[self anchorPointInPixels].x), RENDER_IN_SUBPIXEL(-[self anchorPointInPixels].y), 0);
	
	//
	// END original implementation
}

@end
