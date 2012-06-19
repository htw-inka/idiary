//
//  MagicLayer.m
//  iDiary
//
//  Created by Markus Konrad on 18.04.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "MagicLayer.h"

#import "Config.h"
#import "Tools.h"

static const float kRubSoundMaxInterval = 0.25f;

@implementation MagicLayer

@synthesize interactionArea;

-(id)initOnPageLayer:(PageLayer *)pPage maskedSprite:(CCSprite *)pMaskedSprite brush:(CCSprite *)pBrush {
	if( (self = [super init]) ) {
        // defaults
        pageLayer = pPage;
        lastHoriRubDirection = 0;
        lastVertRubDirection = 0;
        lastRubTime = 0;
            
        // set sprite that will be masked
        maskedSprite = [pMaskedSprite retain];
                
		// create a render texture, this is what we're going to draw into
        renderTexture = [[CCRenderTexture alloc] initWithWidth:maskedSprite.contentSize.width height:maskedSprite.contentSize.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
		[renderTexture setPosition:maskedSprite.position];  // it sits on the position of the masked sprite
		[self addChild:renderTexture];
        
        [maskedSprite setPosition:ccp(maskedSprite.contentSize.width / 2.0f, maskedSprite.contentSize.height / 2.0f)];  // align in the middle
        
        // the render texture is initially empty ("black")
        // we copy the image data of "maskedSprite" to it by using "visit"
        [renderTexture begin];
        [maskedSprite visit];
        [renderTexture end];
                
        // set the brush that will draw into the render texture
        brush = [pBrush retain];
        
        // set the blend functions
        [brush setBlendFunc:(ccBlendFunc){GL_ZERO, GL_ONE_MINUS_SRC_ALPHA}];      // draw transparency into renderTexture (multiply source (brush) by zero and destination (renderTexture) by one minus brush's transparency
        
        // enable touches
		[self setIsTouchEnabled:YES];
	}
	return self;
}

-(void)dealloc {
    [[SoundHandler shared] unloadSound:rubSndId];
    [rubSnd release];

    [maskedSprite release];
	[brush release];
	[renderTexture release];
    
	[super dealloc];
	
}

-(void)setRubSound:(NSString *)rubSndFile {
    rubSndId = [[SoundHandler shared] registerSoundToLoad:rubSndFile looped:NO gain:kFxSoundVolume];
    [[SoundHandler shared] loadRegisteredSounds];
    rubSnd = [[[SoundHandler shared] getSound:rubSndId] retain];
}

-(void)rubFromPos:(CGPoint)start to:(CGPoint)end {
    // brush offset inside of the render texture
    CGPoint brushOffset = ccp(renderTexture.sprite.contentSize.width / 2.0f, renderTexture.sprite.contentSize.height / 2.0f);
    
    // make the start and end points relative to the render texture
    start = ccpSub(start, renderTexture.position);
    start = ccpAdd(start, brushOffset);
    end = ccpSub(end, renderTexture.position);
    end = ccpAdd(end, brushOffset);
    
    // get the movement angle and the set direction
    float angle = [Tools angleBetweenPoint1:start andPoint2:end];
    NSLog(@"rubbing angle: %f", angle);
    int curHoriDir = 0;
    int curVertDir = 0;
    if (fabsf(angle) >= M_PI_2) curHoriDir = 1;
    else curHoriDir = -1;
    if (angle >= 0) curVertDir = 1;
    else curVertDir = -1;
    
    CFTimeInterval now = CACurrentMediaTime();
    
    if (lastRubTime + kRubSoundMaxInterval <= now
    && (curHoriDir != lastHoriRubDirection || curVertDir != lastVertRubDirection)) { // if one of the directions changed, play the rub sound
        [rubSnd playAtPitch:0.75f + 0.5f * CCRANDOM_0_1()];
        lastRubTime = now;
    }
    
    lastHoriRubDirection = curHoriDir;
    lastVertRubDirection = curVertDir;
    
	// begin drawing to the render texture
    [renderTexture begin];
        
	// for extra points, we'll draw this smoothly from the last position and vary the sprite's
	// scale/rotation/offset
	float distance = ccpDistance(start, end);
	if (distance > 1)
	{
        [pageLayer cancelHighlightAnimations];
    
		int d = (int)distance;
        
		for (int i = 0; i < d; i++)
		{
			float difx = end.x - start.x;
			float dify = end.y - start.y;
			float delta = (float)i / distance;
			[brush setPosition:ccp(start.x + (difx * delta), start.y + (dify * delta))];
            
            // stamp the brush on it as mask
			[brush visit];
		}
	}
	// finish drawing and return context back to the screen
	[renderTexture end];
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {    
	UITouch *touch = [touches anyObject];
	CGPoint start = [touch locationInView: [touch view]];	
	start = [[CCDirector sharedDirector] convertToGL: start];
	CGPoint end = [touch previousLocationInView:[touch view]];
	end = [[CCDirector sharedDirector] convertToGL:end];
    
    if ((CGPointEqualToPoint(interactionArea.origin, CGPointZero) && interactionArea.size.width <= 0 && interactionArea.size.height <= 0)
        || CGRectContainsPoint(interactionArea, start)) {    
        // do the rubbing!
        [self rubFromPos:start to:end];
        
        [[CoreHolder sharedCoreHolder] setInteractiveObjectWasTouched:YES];
    }
}

@end
