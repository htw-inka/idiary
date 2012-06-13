/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Sindesso Pty Ltd http://www.sindesso.com/
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "CCActionRealPageTurn3D.h"
#import "ccMacros.h"

@implementation CCRealPageTurn3D

@synthesize beneath;
@synthesize curlStrength;
@synthesize curlForward;

+(id) actionWithSize:(ccGridSize)size duration:(ccTime)d curlStrength:(float)cs curlForward:(BOOL)cf beneath:(BOOL)pIsBeneath
{
    id obj = [super actionWithSize:size duration:d];
    
    [obj setBeneath:pIsBeneath];
    [obj setCurlStrength:cs];
    [obj setCurlForward:cf];
    
	return obj;
}

/*
 * Update each tick
 * Time is the percentage of the way through the duration
 */
-(void)update:(ccTime)time
{
    float alpha = time * M_PI_2;
    
    if (beneath) {
        alpha = M_PI_2 - alpha;
//        alpha -= curlStrength;
    }
	    
    BOOL vertexConditionTrue = NO;
    float curlVal = 0.0f;
    
	for( int i = 0; i <=gridSize_.x; i++ )
	{
		for( int j = 0; j <= gridSize_.y; j++ )
		{
			// Get original vertex
			ccVertex3F	p = [self originalVertex:ccg(i,j)];
        
            vertexConditionTrue = (i >= gridSize_.x / 2);
            
            if ((!beneath && vertexConditionTrue) || (beneath && !vertexConditionTrue)) {
                curlVal = (float)j / gridSize_.y - 0.5f;
                
                if (curlForward) {
                    curlVal = 0.5f - curlVal;
                }
                
                curlVal *= curlStrength;
            
                p.x = (p.x - 512.0f) * cosf(alpha + alpha * curlVal) + 512.0f;
                //p.z = 0.0f;
            }
    
        
            
			// Set new coords
			[self setVertex:ccg(i,j) vertex:p];
		}
	}
}

@end
