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
//  TextureLayer.mm
//  iDiary2
//
//  Created by Markus Konrad on 16.05.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "TextureLayer.h"

#import "Makros.h"


@implementation TextureLayer

@synthesize texPoint;
@synthesize texColor;
@synthesize texSize;
@synthesize texOffset;

- (id)init {
    self = [super init];
    if (self) {        
        // set defaults
        texture = nil;
        
        texPoint = CGPointZero;
        texOffset = CGPointZero;
        texSize = CGSizeMake(0, 0);
        drawSize = CGSizeMake(0, 0); 
        texColor.r = 255;
        texColor.g = 255;
        texColor.b = 255;
        texColor.a = 255;
    }
    return self;
}

- (void)dealloc {
    [texture release];
    
    [super dealloc];
}

-(void)setupWithTextureFile:(NSString *)file andDrawSize:(CGSize)s {
    [texture release];

    // create background texture
    UIImage *texImg = [UIImage imageWithContentsOfFile:file];
    texSize = texImg.size;
    drawSize = s;
    texture = [[CCTexture2D alloc] initWithImage:texImg];
}

-(void) draw
{
    [super draw];
    
    if (!texture) return;
    
    // this code is partly taken from http://www.codza.com/making-seamless-repeating-backgrounds-photoshop-cocos2d-iphone
    
    // calculate texture coordinates
    float xOffset = texOffset.x / texSize.width;
    float yOffset = texOffset.y / texSize.height;
    
    float repeatX = drawSize.width / texSize.width;
    float repeatY = drawSize.height / texSize.height;
    
    GLfloat  coordinates[] = {
        0.0f + xOffset, repeatY * texture.maxT + yOffset,
        repeatX * texture.maxS + xOffset, repeatY * texture.maxT + yOffset,
        0.0f + xOffset, 0.0f + yOffset,
        repeatX * texture.maxS + xOffset, 0.0f + yOffset
    };

    // calculate quad coordinates
    GLfloat    vertices[] = {texPoint.x, texPoint.y, vertexZ_,                          
                            texPoint.x + drawSize.width, texPoint.y, vertexZ_,                          
                            texPoint.x, texPoint.y + drawSize.height,  vertexZ_,      
                            texPoint.x + drawSize.width, texPoint.y + drawSize.height, vertexZ_};

    // setup draw states
    CC_DISABLE_DEFAULT_GL_STATES();
    glDisableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);

	glEnable(GL_TEXTURE_2D);

	glColor4ub(texColor.r, texColor.g, texColor.b, texColor.a);

    // setup texture
    glBindTexture(GL_TEXTURE_2D, texture.name);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    // draw stuff
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    // reset draw state defaults
    glColor4ub( 255, 255, 255, 255);

	glDisable( GL_TEXTURE_2D);
	glDisableClientState(GL_VERTEX_ARRAY );
	glDisableClientState( GL_TEXTURE_COORD_ARRAY );
    
    glEnableClientState(GL_COLOR_ARRAY);
    
    CC_ENABLE_DEFAULT_GL_STATES();
}

@end
