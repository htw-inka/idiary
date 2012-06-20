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
//  PageLayer.mm
//  iDiary2
//
//  Created by Markus Konrad on 02.05.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "PageLayer.h"

#import "Tools.h"
#import "Makros.h"
#import "Config.h"
#import "TextureLayer.h"
#import "CommonActions.h"

static const int kPageLayerCornerAnimNumStartFrames = 16;

// Implement simple model class "BackgroundSound"
@implementation BackgroundSound

@synthesize file;
@synthesize looped;
@synthesize startTime;
@synthesize duration;

-(void)dealloc {
    [file release];
    
    [super dealloc];
}

@end


// Declare private methods for PageLayer
@interface PageLayer(PrivateMethods)
// common initializer 
- (void)initializeWithDefaults;

// handle a set of touches with the correspondending callbacks
// return the number of hit content elements
- (int)handleTouches:(NSSet *)touches usingCallbacks:(NSMutableArray *)callbacks;

// called by BookControl
- (void)pageSwipeRecognized:(NSNumber *)directionObject;

// load all sounds into the buffer memory. Should be done after loadPageContents
- (void)loadSounds;

// perform a touch callback on a content element
- (void)performCallbackArray:(NSArray *)cb onContentElement:(ContentElement *)elem withTouchPoint:(CGPoint)p;

// highlight all interactive elements
- (void)highlightInteractiveElements;

// scheduled method for ongoing highlighting
-(void)tickHighlightElement:(ccTime)dt;

@end

// Implement PageLayer
@implementation PageLayer

@synthesize box2DWorldAttribs;
@synthesize curPage;
@synthesize maxPage;
@synthesize highestZOrder;
@synthesize person;
@synthesize pageName;
@synthesize pageBackgroundImg;
@synthesize glowSprites;
@synthesize persistentElements;
@synthesize interactiveElements;
@synthesize highlightInteractiveElementsEnabled;
@synthesize isRestoredFromPersistentData;

#pragma mark init/dealloc

- (id)init {
    self = [super init];
    if (self) {        
        // set default values
        [self initializeWithDefaults];
        
        // do not add children elements here but in displayContentForKey:andPage:
    }
    return self;
}

- (id)initWithEnabledPhysicsOfType:(b2dWorldType)worldType {
    self = [super init];
    if (self) {
        // set default values
        [self initializeWithDefaults];
        
        // enable physics
        enablePhysics = true;
        physicsWorldType = worldType;
        [self setIsAccelerometerEnabled:YES];
        
        // create new physical world
        box2DWorldAttribs = [box2D worldAttribsForType:physicsWorldType];
        
        NSLog(@"Created physics stuff!");
    }
    return self;
}

- (void)initializeWithDefaults {
    // enable better PVRT support
    [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
    
    // set default values
    core = [CoreHolder sharedCoreHolder];
    bookControl = [[BookControl alloc] initWithTarget:self action:@selector(pageSwipeRecognized:)];
    sndHandler = [SoundHandler shared];
    
    mainLayer = (PageMainLayer *)core.currentMainLayer;
    
    curPage = 0;
    maxPage = 0;
    
    highlightInteractiveElementsEnabled = YES;
    
    pageAlreadyGoneInvisble = 0;
    
    highestZOrder = 0;
    
    mediaObjects = [[NSMutableArray alloc] init];
    glowSprites = [[NSMutableArray alloc] init];
    backgroundSounds = [[NSMutableArray alloc] init];
    
    soundObjectIds = [[NSMutableArray alloc] init];
    
    enablePhysics = false;
    physicsWorldType = kB2dWorldTypeDefault;
    box2D = [Box2DWorldHolder shared];
    physicsUpdateInterval = 0.0f;
            
    touchCallbacksTap = [[NSMutableArray alloc] init];
    touchCallbacksMove = [[NSMutableArray alloc] init];
    
    activeContentElement = nil;
    
    interactiveElements = [[NSMutableArray alloc] init];
    persistentElements = [[NSMutableArray alloc] init];
    animationElements = [[NSMutableArray alloc] init];
    
    registeredSpriteFrames = [[NSMutableArray alloc] init];
            
    [self setIsTouchEnabled:YES];
    [self setIsAccelerometerEnabled:NO];
    
    [sndHandler setDelegate:self];
    
    // do not add children elements here but in displayContentForKey:andPage:
}

- (void)dealloc {
    NSLog(@"dealloc on page %@ - %@", person, pageName);

    // reset states
	[self clearState];

    // cancel scheduled actions
	[self cancelHighlightAnimations];
    
    // some times this must be called manually, e.g. when a video started playing
    if (!pageAlreadyGoneInvisble) {
        [self pageGoneInvisible];
    }
    
    // unregister as sound delegate
    [sndHandler unregisterDelegate:self];
    
    // remove all sprite frames
    for (NSString *frameFile in registeredSpriteFrames) {
        NSLog(@"Removing sprite frame: %@", frameFile);
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrameByName:frameFile];
    }
    
    [registeredSpriteFrames release];
    
    // stop animations that might be delayed (causes memory leaks!)
    for (ContentElement *animElem in animationElements) {
        NSLog(@"Canceling animation %@", animElem.mediaDef.value);
        [NSObject cancelPreviousPerformRequestsWithTarget:animElem];
    }
    
    // release book control
    [bookControl release];
    
    // release unused objects
    [glowSprites release];
    [pageBackgroundImg release];
            
    [soundObjectIds release];
    
    [interactiveElements release];
    [persistentElements release];
    [animationElements release];
    
    [person release];
    [pageName release];
    
    [mediaObjects release];
    [pageBackgroundImg release];
    [backgroundSounds release];
    
    [touchCallbacksTap release];
    [touchCallbacksMove release];
    
//    // destroy box2d world
//    if (box2DWorldAttribs) {
//        [box2D destroyWorldOfType:box2DWorldAttribs->worldType];
//    }
    
    [super dealloc];
}

#pragma mark public methods

- (CoreHolder *)core {
    return core;
}

- (void)loadPageContents {
    // add common media objects here
}

- (void)registerTouchOfType:(TouchType)type withCallback:(SEL)selector onObject:(NSObject *)object withParameterObject:(NSObject *)parameterObject {    
    NSArray *callbackArray = nil;
    
    if (parameterObject != nil) {
        callbackArray = [NSArray arrayWithObjects:[NSValue valueWithPointer:selector], object, parameterObject, nil];
    } else {
        callbackArray = [NSArray arrayWithObjects:[NSValue valueWithPointer:selector], object, nil];
    }

    if (type == kTouchTypeTap)
        [touchCallbacksTap addObject:callbackArray];
    else if (type == kTouchTypeMove)
        [touchCallbacksMove addObject:callbackArray];
}

- (void)clearState {
//    NSLog(@"Clearing state for %@ (%d): %p %p", person, curPage, box2D, box2DWorldAttribs);

    // remove interactive elements
//    [interactiveElements removeAllObjects];

    // remove all glow sprites
    [glowSprites removeAllObjects];

    // remove callbacks
    [touchCallbacksTap removeAllObjects];
    [touchCallbacksMove removeAllObjects];
    
    // remove layers and sprites
    //[self removeAllChildrenWithCleanup:YES];
    
    // reset physics
    physicsUpdateInterval = 0.0f;
//    box2D = nil;
//    box2DWorldAttribs = nil;
    [self unschedule:@selector(tick:)];
}

- (void)displayContent {
    NSLog(@"Displaying content for: %@ %d (%@)", person, curPage, pageName);

    // remove old items
//    [self clearState];
        
    // create page background texture
    if (!kDbgDrawPhysics) {
        CCSprite *pageBgSprite = [CCSprite spriteWithFile:GET_FILE(pageBackgroundImg)];
        CGPoint pageOffset = [[core.curPersonMetaData objectAtIndex:1] CGPointValue];
        [pageBgSprite setPosition:ccp(core.screenCenter.x + pageOffset.x, core.screenCenter.y + pageOffset.y)];
        [self addChild:pageBgSprite];
    }
                
    // init physics
    physicsUpdateInterval = 0.0f;
    
    // display page corner animation if this is the very first page of the diary
    if (curPage == 0) {
        NSString *startAnimFile = [NSString stringWithFormat:@"%@_ecke_start", [person lowercaseString]];
        NSString *loopAnimFile = [NSString stringWithFormat:@"%@_ecke_loop", [person lowercaseString]];
        
        CGSize pageCornerSize = [[core.curPersonMetaData objectAtIndex:2] CGSizeValue];
        CGPoint pageCornerOffset = [[core.curPersonMetaData objectAtIndex:3] CGPointValue];
            
        CGRect cornerAnimRect = CGRectMake(
            core.screenW - pageCornerSize.width / 2.0f + pageCornerOffset.x,
            pageCornerSize.height / 2.0f + pageCornerOffset.y,
            pageCornerSize.width,
            pageCornerSize.height
        );
            
        // create start animation
        MediaDefinition *cornerStartAnimDef = [MediaDefinition mediaDefinitionWithAnimation:startAnimFile numberOfPlistFiles:1 inRect:cornerAnimRect];
        [cornerStartAnimDef setStartDelay:1.0f];
            
        ContentElement *cornerStartAnim = [ContentElement contentElementOnPageLayer:self forMediaDefintion:cornerStartAnimDef];
            
        if (cornerStartAnim.displayNode) {
            [self addChild:cornerStartAnim.displayNode z:10000];
            
            // create loop animation
            MediaDefinition *cornerLoopAnimDef = [MediaDefinition mediaDefinitionWithAnimation:loopAnimFile numberOfPlistFiles:1 inRect:cornerAnimRect loop:YES];
            NSTimeInterval loopStartDelay = 1.0f + (float)kPageLayerCornerAnimNumStartFrames / (float)kSpriteAnimFramesPerSecond;
            [cornerLoopAnimDef setStartDelay:loopStartDelay];    // play directly after the start animation
        
            ContentElement *cornerLoopAnim = [ContentElement contentElementOnPageLayer:self forMediaDefintion:cornerLoopAnimDef];
            [cornerLoopAnim.displayNode setVisible:NO];
            [self addChild:cornerLoopAnim.displayNode z:10001];
            
            // show the loop after the start animation has finished
            [cornerLoopAnim.displayNode performSelector:@selector(runAction:) withObject:[CCShow action] afterDelay:loopStartDelay];
            
            // hide the start after the start animation has finished
            [cornerStartAnim.displayNode performSelector:@selector(runAction:) withObject:[CCHide action] afterDelay:loopStartDelay];
        }
    }
                 
    // display content for this key and page
    for (MediaDefinition *mediaObj in mediaObjects) {
        // create a ContentElement from the MediaDefinition
        ContentElement *contentElem = [ContentElement contentElementOnPageLayer:self forMediaDefintion:mediaObj];
        
        if (contentElem.displayNode == nil) {
            NSLog(@"Warning: displayNode for '%@' element is nil!", [mediaObj value]);
            continue;
        }
        
        // add to special array if this is an animation. used in dealloc to cancel delayed animations to prevent memory leaks
        if ([contentElem.mediaDef.type intValue] == MEDIA_TYPE_ANIM) {
            [animationElements addObject:contentElem];
        }
        
        // register interactive/movable elements
        if (contentElem.isInteractive) {
            if (contentElem.isMovable) {
                [self registerPersistentElement:contentElem];
            }
        
            [interactiveElements addObject:contentElem.displayNode];
            
            // set the z order for this element
            if ([contentElem.mediaDef.attributes objectForKey:@"zIndex"] == nil) {
                [contentElem.mediaDef.attributes setObject:[NSNumber numberWithInt:[interactiveElements count]] forKey:@"zIndex"];
            }
        }
        
        // set provided z-order
        if ([contentElem.mediaDef.attributes objectForKey:@"zIndex"] == nil) {
            [self addChild:contentElem.displayNode];
        } else {
            [self addChild:contentElem.displayNode z:[[contentElem.mediaDef.attributes objectForKey:@"zIndex"] intValue]];
        }
    }
    
    highestZOrder = [interactiveElements count];
    
    // schedule tick method for updating physic states
    if (enablePhysics) {
        physicsUpdateInterval = 1.0f/24.0f;
        NSLog(@"Scheduled physics tick for %@ %d (%@) with interval %f", person, curPage, pageName, physicsUpdateInterval);
        [self schedule:@selector(tick:) interval:physicsUpdateInterval];
    } else {
        physicsUpdateInterval = 0.0f;
    }
}

- (int)addFxSound:(NSString *)soundFile {
    int sId = [sndHandler registerSoundToLoad:soundFile looped:NO gain:kFxSoundVolume];
    
//    NSLog(@"Added fx sound#%d: %@", sId, soundFile);
    
    [soundObjectIds addObject:[NSNumber numberWithInt:sId]];
    
    return sId;
}

- (void)addBackgroundSound:(NSString *)soundFile looped:(BOOL)looped startTime:(CFTimeInterval)startTime {
    return [self addBackgroundSound:soundFile looped:looped startTime:startTime duration:0.0];
}

- (void)addBackgroundSound:(NSString *)soundFile looped:(BOOL)looped startTime:(CFTimeInterval)startTime duration:(CFTimeInterval)duration {
    BackgroundSound *bgSound = [[BackgroundSound alloc] init];
    
    // setup the BackgroundSound object
    [bgSound setFile:soundFile];
    [bgSound setLooped:looped];
    [bgSound setStartTime:startTime];
    [bgSound setDuration:duration];
    
    // add it to the array
    [backgroundSounds addObject:bgSound];
    
    [bgSound release];
}

- (void)cancelHighlightAnimations {
    [self unschedule:@selector(tickHighlightElement:)];
}

- (void)pageTurnComplete {
    // load all sounds
    [self loadSounds];    

    // display "highlight" effect for interactive elements after small delay
    [self performSelector:@selector(highlightInteractiveElements) withObject:nil afterDelay:kInteractiveElementsAnimStartDelay];
    
    // schedule ongoing highlighting
    [self schedule:@selector(tickHighlightElement:) interval:kInteractiveElementsAnimReplayInterval];
     
    // tell the Core!
    [core pageTurnCompleted];
}

- (void)pageGoneInvisible {
    NSLog(@"page gone invisible, ready for dealloc");
    // unload only the sounds that are connected to THIS page!
    [sndHandler unloadSounds:soundObjectIds];
    
    // unload all pending performSelector requests
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    pageAlreadyGoneInvisble = YES;
}

- (void)registerSpriteFrame:(NSString *)frameFile {
    [registeredSpriteFrames addObject:frameFile];
}

-(void)registerPersistentElement:(id<PageElementPersistencyProtocol>)elem {
    [mainLayer registerPersistentElement:elem];
    [persistentElements addObject:elem];
}

#pragma mark touch handling

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // nothing here.
    // "tap" touch handling is handled on "ccTouchesEnded"
    
    if (!core.interactiveObjectWasTouched) {
        [bookControl touchesBegan:touches];
    }
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self handleTouches:touches usingCallbacks:touchCallbacksMove] > 0) {        
        // stop highlight elements scheduler
        [self cancelHighlightAnimations];
        
        [core setInteractiveObjectWasTouched:YES];
    }
}


- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self handleTouches:touches usingCallbacks:touchCallbacksTap] > 0) {                
        // stop highlight elements scheduler
        [self cancelHighlightAnimations];
    } else if (!core.interactiveObjectWasTouched) {
        [bookControl touchesEnded:touches];
    } 

    [core setInteractiveObjectWasTouched:NO];

    activeContentElement = nil;
}

-(int)handleTouches:(NSSet *)touches usingCallbacks:(NSMutableArray *)callbacks {
    if ([callbacks count] <= 0) {
//        NSLog(@"No touch callbacks for this type registered");
        return 0;
    }
    
    // get a point that's been touched
//    int numHitElements = 0;
    for (UITouch *touch in touches) {
        CGPoint convertedPoint = [Tools convertTouchToGLPoint:touch];
        
        // if we have an active element, use this
        if (activeContentElement && callbacks) {            
            for (NSArray *callbackArray in callbacks) {
                ContentElement *contentElem = (ContentElement *)[callbackArray objectAtIndex:1];
                
                if (contentElem == activeContentElement) {
                    [self performCallbackArray:callbackArray onContentElement:activeContentElement withTouchPoint:convertedPoint];
                }
            }
            
            return 1;
        }
        
        // loop through all registered touch-callbacks
        ContentElement *maxZElem = nil;
        NSArray *maxZCallbacks = nil;
        for (NSArray *callbackArray in callbacks) {
            ContentElement *contentElem = (ContentElement *)[callbackArray objectAtIndex:1];
            
            // if we touched the content element
            if (contentElem && contentElem.displayNode) {
                int mediaType = [contentElem.mediaDef.type intValue];
                
                // if it is a video, then use a radial "hit zone" defined by kPlayButtonRadius, else use the node's rect
                if (contentElem.displayNode.visible == YES
                && ((mediaType != MEDIA_TYPE_VIDEO && [Tools point:convertedPoint isInNode:contentElem.displayNode])
                || (mediaType == MEDIA_TYPE_VIDEO && [Tools point:convertedPoint isInNode:contentElem.displayNode usingRadius:kPlayButtonRadius]))) {   
                    if (maxZElem == nil || maxZElem.displayNode.zOrder < contentElem.displayNode.zOrder) {  // get the element with the highest z-order
                        maxZElem = contentElem;
                        maxZCallbacks = callbackArray;
                    }
                }
            }
        }
        
        // we hit an element
        if (maxZElem != nil) {
            [self performCallbackArray:maxZCallbacks onContentElement:maxZElem withTouchPoint:convertedPoint];
            activeContentElement = maxZElem;
            
            return 1;
        }
    }
    
    return 0;
}

-(void)performCallbackArray:(NSArray *)cb onContentElement:(ContentElement *)elem withTouchPoint:(CGPoint)p {
    if ([cb count] == 2) {                 
        [elem performSelector:((SEL)[(NSValue *)[cb objectAtIndex:0] pointerValue])   // selector method
                   withObject:[NSValue valueWithCGPoint:p]];  // parameter object                                
    } else {
        [elem performSelector:((SEL)[(NSValue *)[cb objectAtIndex:0] pointerValue])   // selector method
                   withObject:[cb objectAtIndex:2]];  // parameter object                
    }
}

- (void)pageSwipeRecognized:(NSNumber *)directionObject {
    if (!core.allowPageTurn) return;

    BookControlTurnDirection dir = (BookControlTurnDirection)[directionObject intValue];
    
    NSLog(@"Page swipe recognized: %d", dir);
    
    if (dir == kBookControlTurnDirectionLeft) {
        [core showPrevPage:nil];
    } else {
        [core showNextPage:nil];
    }
}

#pragma mark sound

- (void)loadSounds {
    // preload sounds    
    if ([backgroundSounds count] > 0) {
        // register sounds to load
        NSMutableArray *soundIds = [[NSMutableArray alloc] initWithCapacity:[backgroundSounds count]];
        for (BackgroundSound *bgSound in backgroundSounds) {
            int sId = [sndHandler registerSoundToLoad:bgSound.file looped:bgSound.looped gain:kBGSoundVolume];
            [soundIds addObject:[NSNumber numberWithInt:sId]];
        }
        
        // register as used sound ids for this page
        [soundObjectIds addObjectsFromArray:soundIds];
        
        // cleanup
        [soundIds release];
    }
    
    // will notify via SoundHandlerDelegate when ready to play
    [sndHandler loadRegisteredSounds];
}

#pragma mark other private methods

-(void)tickHighlightElement:(ccTime)dt {
    [self highlightInteractiveElements];
}

- (void)highlightInteractiveElements {
    if (!highlightInteractiveElementsEnabled) return;

    // display "highlight" effect for interactive elements
    for (CCNode *elem in interactiveElements) {        
        [elem runAction:[CommonActions highlightForInteractiveElement:elem]];  
    }
}

#pragma mark SoundHandlerDelegate methods

-(void)readyToPlaySounds:(NSArray *)soundObjects {
    // start playing background sounds
    for (BackgroundSound *bgSound in backgroundSounds) {
        SoundObject *snd = [sndHandler getSoundByFile:bgSound.file];
        
        if (bgSound.startTime > 0) {    // play later
            [snd performSelector:@selector(play) withObject:nil afterDelay:bgSound.startTime];
        } else {    // play now!
            [snd play];
        }
        
        // schedule sound stop
        if (bgSound.duration > 0) {
            [snd performSelector:@selector(stop) withObject:nil afterDelay:(bgSound.startTime + bgSound.duration)];
        }
    }
}

#pragma mark physics/box2d

#if (kDbgDrawPhysics == 1)
-(void) draw {
    [super draw];
    [box2D drawDebugViewForAttributes:box2DWorldAttribs];
}
#endif

-(void)tick:(ccTime)dt {
	if (physicsUpdateInterval > 0.0f) {
        [box2D updateWorldForAttributes:box2DWorldAttribs withDeltaTime:dt];
    }
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {
    if (physicsUpdateInterval > 0.0f) {
        [box2D updateGravityForAttributes:box2DWorldAttribs withX:acceleration.x andY:acceleration.y];
    }
}

@end
