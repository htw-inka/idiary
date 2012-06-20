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
