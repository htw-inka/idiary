//
//  ContentElement.mm
//  iDiary
//
//  Created by Markus Konrad on 12.01.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//


#import "ContentElement.h"

#import "Constants.h"
#import "Config.h"
#import "Makros.h"

//#import "GLModelLayer.h"
#import "VideoLayer.h"
//#import "MagicLayer.h"
#import "CoreHolder.h"
#import "SoundHandler.h"
#import "ProgressLayer.h"

@interface ContentElement(PrivateMethods)
// create an action with a callback
- (CCSequence *)_createActionWithCallbackAtEnd:(SEL)endCallback atObject:(id)endObj;

// set default properties
- (void)_setProperties;

// Private method that creates the display node depending on the media type
- (void)_createDisplayNode;

// Private method that creates a point from the attributes provided by a MediaDefintion object.
- (CGPoint)_makePointFromAttrib:(NSDictionary *)attrib;

// Private method that creates a rectangle from the attributes provided by a MediaDefintion object.
- (CGRect)_makeRectFromAttrib:(NSDictionary *)attrib;

// Get the CGSize struct for given attributes.
- (CGSize) _makeSizeFromAttrib:(NSDictionary*) attributes;

// Private method for calculating the scale factor for the displayNode.
- (void) _calculateScaleFactorForWidth:(int)width andHeight:(int)height;

// get a frame list from a plist files
- (NSArray *)_frameListFromPlists:(NSArray *)plistFiles;

// load all plist files
- (NSArray *)_loadPlistFiles;

// never ending glow animation 
- (void)_glowAnimWithSprite:(CCSprite *)sprite;

@end


@implementation ContentElement


#define TEXT_FONT_SIZE 32
#define TEXT_FONT_NAME @"Arial"

@synthesize mediaDef;
@synthesize displayNode;
@synthesize isInteractive;
@synthesize isMovable;
@synthesize physicalBehavior;
@synthesize restoreOriginalAnimFrame;
@synthesize anim;

#pragma mark init/dealloc

+ (ContentElement *)contentElementForMediaDefintion:(MediaDefinition *)pMediaDef {
    return [[[ContentElement alloc] initWithMediaDefinition:pMediaDef] autorelease];
}

+ (ContentElement *)contentElementOnPageLayer:(PageLayer *)pPageLayer forMediaDefintion:(MediaDefinition *)pMediaDef {
    ContentElement *contentElem = [[ContentElement alloc] initWithMediaDefinition:pMediaDef andPageLayer:pPageLayer];
    return [contentElem autorelease];
}

- (id)initWithMediaDefinition:(MediaDefinition *)pMediaDef {
    return [self initWithMediaDefinition:pMediaDef andPageLayer:nil];
}

- (id)initWithMediaDefinition:(MediaDefinition *)pMediaDef andPageLayer:(PageLayer *)pPageLayer {
    if ((self = [self init])) {
        // set default vars
        mediaDef = [pMediaDef retain];
        pageLayer = pPageLayer;
        restoreOriginalAnimFrame = NO;

        [self _setProperties];        
        [self _createDisplayNode];
    }
    
    return self;
}

- (void)dealloc {
    [displayNode release];
    [anim release];
    [mediaDef release];
    pageLayer = nil;
    
    [super dealloc];
}


#pragma mark public messages
- (void)playVideo:(NSString *)file {
    // after playback, return to same diary page
    [[CoreHolder sharedCoreHolder] scheduleAfterVideoPlaybackReturnToSameDiary];
    
    // start video now
    [[CoreHolder sharedCoreHolder] showVideo:file];
}

- (void)playAudio:(NSNumber *)soundId {
    // check if only one instance of this sound can be played
    BOOL playAlone = [[mediaDef.attributes objectForKey:@"playAlone"] boolValue];
    
    // get the sound id and the sound object
    int sndId = [soundId intValue];
    SoundObject *snd = [[SoundHandler shared] getSound:sndId];
    
    // cancel if sound is already playing and another sound is not allowed
    if (playAlone && snd.isPlaying) return;
    
    // play the sound
    NSLog(@"Playing fx sound#%d", sndId);
    [snd play];
}

- (void)moveNode:(NSValue *)newPos {
    CGPoint point = [newPos CGPointValue];
    
    displayNode.anchorPoint = ccp(0.5,0.5);
    
    // move the sprite
    if ([displayNode isKindOfClass:[PhySprite class]]) {
        [(PhySprite *)displayNode setPhyPosition:point];
    } else {
        [displayNode setPosition:point];
    }
    
    // set the new z order to bring it to front
    if (pageLayer != nil) {
        [pageLayer reorderChild:displayNode z:(pageLayer.highestZOrder++)];
    }
}

- (void)startAnimationLooped:(NSNumber *)looped {
    CCAction *action;
    
    // create the action
    if (looped != nil && [looped intValue] == 1) {
        action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO]];
    } else {
        int loopTimes = 1;
        if (looped != nil && [looped intValue] > 0) {
            loopTimes = [looped intValue];
        }
        
        action = [CCRepeat actionWithAction:[CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO] times:loopTimes];
    }
    
    // run the action
    [displayNode runAction:action];
}

- (void)startAnimationWithCallbackAtEnd:(SEL)endCallback atObject:(id)endObj {
    // run the action
    [displayNode runAction:[self _createActionWithCallbackAtEnd:endCallback atObject:endObj]];
}

- (void)startAnimationBackwardsWithCallbackAtEnd:(SEL)endCallback atObject:(id)endObj {
    [displayNode runAction:[CCReverseTime actionWithAction:[self _createActionWithCallbackAtEnd:endCallback atObject:endObj]]];
}

#pragma mark private messages
- (CCSequence *)_createActionWithCallbackAtEnd:(SEL)endCallback atObject:(id)endObj {
    CCFiniteTimeAction *action = [CCRepeat actionWithAction:[CCAnimate actionWithAnimation:anim restoreOriginalFrame:restoreOriginalAnimFrame] times:1];
    CCSequence *seq = [CCSequence actions:action, [CCCallFunc actionWithTarget:endObj selector:endCallback], nil];
    
    return seq;
}

- (void)_setProperties {
    int type = [mediaDef.type intValue];
    
    if ([mediaDef.attributes valueForKey:@"isInteractive"] != nil) {
        isInteractive = [[mediaDef.attributes valueForKey:@"isInteractive"] boolValue];
    } else {
        isInteractive = (type == MEDIA_TYPE_AUDIO || type == MEDIA_TYPE_VIDEO);
    }
    
    if ([mediaDef.attributes valueForKey:@"isMovable"] != nil) {
        isMovable = [[mediaDef.attributes valueForKey:@"isMovable"] boolValue];
    } else {
        isMovable = NO;
    }
    
    if ([mediaDef.attributes valueForKey:@"physicalBehavior"] != nil) {
        physicalBehavior = (physicalBehaviorType)[[mediaDef.attributes valueForKey:@"physicalBehavior"] intValue];
    } else {
        physicalBehavior = kPhysicalBehaviorNone;
    }
}


- (void)_createDisplayNode {
    UIImage *img = nil;
    float fScaleX = 0.0f;
    float fScaleY = 0.0f;
    
    int type = [mediaDef.type intValue];
    
    switch (type) {
        case MEDIA_TYPE_AUDIO:
            
        case MEDIA_TYPE_VIDEO: {
            // MEDIA_TYPE_AUDIO and MEDIA_TYPE_VIDEO needs a thumbnail
            NSString *thumbnailImage = GET_FILE([mediaDef.attributes objectForKey:@"thumbnail"]);
            
            if (thumbnailImage == nil) { 
                NSLog(@"No thumbnail found for sound/video: %@", mediaDef.value);
            }
            
            // get the video file
            NSString *file = GET_FILE(mediaDef.value);
            if (file == nil) {
                NSLog(@"Ups, video or sound not found: %@", mediaDef.value);
                break;
            }
            
            // get the thumbnail
            if (thumbnailImage != nil) {
                img = [UIImage imageWithContentsOfFile:thumbnailImage];
            }
                        
            // now we register a callback thats called upon touching the image
            if (pageLayer != nil) {
                if (type == MEDIA_TYPE_VIDEO) {
                    [pageLayer registerTouchOfType:kTouchTypeTap withCallback:@selector(playVideo:) onObject:self withParameterObject:file];
                } else {
                    int soundId = [pageLayer addFxSound:file];
                    [pageLayer registerTouchOfType:kTouchTypeTap withCallback:@selector(playAudio:) onObject:self withParameterObject:[NSNumber numberWithInt:soundId]];
                }
            }
            
            // no break! -> continue with code from MEDIA_TYPE_PICTURE
        }
        
        case MEDIA_TYPE_PICTURE: {
//            NSLog(@"Creating displayNode for MEDIA_TYPE_PICTURE");
            
            // load and display image
            if (img == nil && type != MEDIA_TYPE_VIDEO) {
                img = [UIImage imageWithContentsOfFile: GET_FILE(mediaDef.value)];
            }
            
            if (img == nil) {
                break;
            }

            if (physicalBehavior != kPhysicalBehaviorNone) {
                displayNode = [[PhySprite spriteWithCGImage:[img CGImage] key:mediaDef.value] retain];
            } else {
                displayNode = [[CCSprite spriteWithCGImage:[img CGImage] key:mediaDef.value] retain];                
            }
            
            if (type == MEDIA_TYPE_PICTURE && isMovable) {
                [pageLayer registerTouchOfType:kTouchTypeMove withCallback:@selector(moveNode:) onObject:self withParameterObject:nil];
            }
            
            if (type == MEDIA_TYPE_PICTURE && [mediaDef.attributes objectForKey:@"progressDirection"] != nil) {                    
                // get the attributes
                NSNumber *duration = [mediaDef.attributes objectForKey:@"duration"];
                NSNumber *direction = [mediaDef.attributes objectForKey:@"progressDirection"];
                                           
                ProgressDirection progressDirection;    
                                           
                if ([direction intValue] == progressDirectionHorizontalLR) {
                    progressDirection = progressDirectionHorizontalLR;
                }
                
                if ([direction intValue] == progressDirectionHorizontalRL) {
                    progressDirection = progressDirectionHorizontalRL;
                }
                
                if ([direction intValue] == progressDirectionVerticalTB) {
                    progressDirection = progressDirectionVerticalTB;
                }
                
                if ([direction intValue] == progressDirectionVerticalBT) {
                    progressDirection = progressDirectionVerticalBT;
                }
                
                if ([direction intValue] == progressDirectionRadialCW) {
                    progressDirection = progressDirectionRadialCW;
                }
                
                if ([direction intValue] == progressDirectionRadialCCW) {
                    progressDirection = progressDirectionRadialCCW;
                }
                                                            
                                           
                NSNumber *startAnim = [mediaDef.attributes objectForKey:@"startTime"];
                
                NSNumber *posX = [mediaDef.attributes objectForKey:@"posX"];
                NSNumber *posY = [mediaDef.attributes objectForKey:@"posY"];
                
                CGPoint pos = ccp([posX intValue], [posY intValue]);
                
                // creates eitehr a display node with a horizontal or vertical animation
                displayNode = [ProgressLayer progressWithFile:mediaDef.value andDuration:duration andPosition:pos andDirection:progressDirection];
                
                if ([displayNode respondsToSelector:@selector(start)]) {
                    [displayNode performSelector:@selector(start) withObject:nil afterDelay:[startAnim doubleValue]];
                }                
            }
            
            displayNode.anchorPoint = ccp(0.5,0.5);
                        
            // set rect according to media attributes
            CGRect spriteRect = [self _makeRectFromAttrib: mediaDef.attributes];
            
            // auto scaling:
            fScaleX = (float)spriteRect.size.width / (float)img.size.width;
            fScaleY = (float)spriteRect.size.height / (float)img.size.height;
            
            if (physicalBehavior == kPhysicalBehaviorNone) {
                displayNode.scale = (fScaleX > fScaleY) ? fScaleX : fScaleY;
            }
            
            break;
        }
   
        case MEDIA_TYPE_TEXT: {      
            NSString *fontFamily = [mediaDef.attributes objectForKey:@"fontFamily"];
            if (!fontFamily) fontFamily = TEXT_FONT_NAME;
            
            float fontSize = [[mediaDef.attributes objectForKey:@"fontSize"] floatValue];
            if (fontSize <= 0.0f) fontSize = TEXT_FONT_SIZE;
            
            ccColor3B *fontColorPtr = (ccColor3B *)[[mediaDef.attributes objectForKey:@"fontColor"] pointerValue];
            ccColor3B fontColor;
            if (fontColorPtr != NULL) fontColor = *fontColorPtr;
            else fontColor = ccBLACK;
            
			displayNode = [[CCLabelTTF labelWithString:mediaDef.value 
                                           dimensions: [self _makeSizeFromAttrib:mediaDef.attributes]
                                            alignment:UITextAlignmentLeft
                                             fontName:fontFamily
                                             fontSize:fontSize] retain];
			
			// set the color to white
			[(CCLabelTTF *)displayNode setColor:fontColor];
            
			// set the anchor point to the left top
			displayNode.anchorPoint = ccp(0,1);
            
            if (isInteractive) {
                displayNode.anchorPoint = ccp(0.5,0.5);
            
                if (pageLayer != nil) {
                    [pageLayer registerTouchOfType:kTouchTypeMove withCallback:@selector(moveNode:) onObject:self withParameterObject:nil];
                }
            }
                    
            break;
        }  
          
        case MEDIA_TYPE_ANIM: {
//            NSLog(@"Creatinge displayNode for MEDIA_TYPE_ANIM");
            
            // create frame list
            NSArray *fileList = [self _loadPlistFiles];
            NSArray *frameList = [self _frameListFromPlists:fileList];
            
            NSMutableArray *frameSpriteList = [NSMutableArray array];
            for (NSString *frameName in frameList) {
                [pageLayer registerSpriteFrame:frameName];
                [frameSpriteList addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]];
            }
            
            // create animation
            if ([frameSpriteList count] == 0) {
                NSLog(@"Animation not found for value %@", mediaDef.value);
                break;
            }
            
            anim = [[CCAnimation animationWithFrames:frameSpriteList delay:1.0f / kSpriteAnimFramesPerSecond] retain];

            // create display node
            displayNode = [[CCSprite spriteWithSpriteFrame:[anim.frames objectAtIndex:0]] retain];
            displayNode.anchorPoint = ccp(0.5, 0.5);
            
			int width = displayNode.contentSize.width;
			int height = displayNode.contentSize.height;
			
			[self _calculateScaleFactorForWidth:width andHeight:height];
            
            // get start delay and loop settings
            NSNumber *startDelayNum = [mediaDef.attributes objectForKey:@"startDelay"];
            NSTimeInterval startDelay = kGeneralAnimationStartDelay;
            if (startDelayNum != nil) {
                startDelay = [startDelayNum doubleValue];
            }
            
            NSNumber *shouldLoop = [mediaDef.attributes objectForKey:@"loop"];            
			
            // start the animation
            if (startDelay >= 0) {
                [self performSelector:@selector(startAnimationLooped:) withObject:shouldLoop afterDelay:startDelay];            
            }
            
            break;
            
        }    
        default: {
            break;
        }
    }
    
    if (displayNode != nil) {
        // set a tag if necessary
        NSNumber *tagNum = [mediaDef.attributes objectForKey:@"tag"];
        if (tagNum != nil) {
            [displayNode setTag:[tagNum intValue]];
        }
    
        // if we have a pagelayer, and the element is interactive, use the special
        // position functions
        if (pageLayer != nil && [displayNode respondsToSelector:@selector(setupWithPos:andBehaviour:inWorld:)]) {
            [(PhySprite *)displayNode setupWithPos:[self _makePointFromAttrib: mediaDef.attributes]
                                        andBehaviour:kPhysicalBehaviorBall
                                            inWorld:pageLayer.box2DWorldAttribs->world];
            
            [(PhySprite *)displayNode setPhyScale:((fScaleX < fScaleY) ? fScaleX : fScaleY)];
        } else {
            displayNode.position = [self _makePointFromAttrib:mediaDef.attributes];
        }
                
        // add a glow effect to interactive elements
        if (isInteractive && type == MEDIA_TYPE_VIDEO && kGlowBorderSize > 0) {
            float dispNodeW = displayNode.contentSize.width * displayNode.scaleX;
            
            // create a glow sprite
            CCSprite *glowSprite = [CCSprite spriteWithFile:@"play_button_bg.png"];
            float glowW = glowSprite.contentSize.width;
            [glowSprite setAnchorPoint:ccp(0.5,0.5)];
            [glowSprite setPosition:ccp(displayNode.contentSize.width / 2.0f, displayNode.contentSize.height / 2.0f)];
                        
            float glowScale = (dispNodeW + kGlowBorderSize) / glowW;
            [glowSprite setScale:glowScale];
            [glowSprite setOpacity:kGlowOpacityMin];
            [glowSprite setColor:kGlowColor];
            
            // add it to the existing sprite
            [displayNode addChild:glowSprite z:-1];
            
            // and to the page layer
            [pageLayer.glowSprites addObject:glowSprite];
            
            // and begin with the animation
            [self _glowAnimWithSprite:glowSprite];
        }
    }
}

- (void)_glowAnimWithSprite:(CCSprite *)sprite {
    float newOpacity = kGlowOpacityMin;

    if (sprite.opacity < kGlowOpacityMax) {
        newOpacity = kGlowOpacityMax;
    }
    
    CCFadeTo *fade = [CCFadeTo actionWithDuration:(kGlowAnimDur / 2.0f) opacity:newOpacity];
    
    CCSequence *seq = [CCSequence actions:
        fade,
        [CCCallFuncN actionWithTarget:self selector:@selector(_glowAnimWithSprite:)],   // will pass the sprite as argument
        nil];
        
    [sprite runAction:seq];
}

- (void) _calculateScaleFactorForWidth:(int)width andHeight:(int)height {
	// set rect according to media attributes
	CGRect spriteRect = [self _makeRectFromAttrib: mediaDef.attributes];
	float scale;
    
    if (spriteRect.size.width <= 0 || spriteRect.size.height <= 0) {
        scale = 1.0f;
    } else {
        float scaleX = (float)spriteRect.size.width / (float)width;
        float scaleY = (float)spriteRect.size.height / (float)height;
        
        scale = (scaleX > scaleY) ? scaleX : scaleY;
    }
	
	displayNode.scale = scale;
}

- (CGPoint)_makePointFromAttrib:(NSDictionary *)attrib {
    return ccp([[attrib objectForKey:@"posX"] intValue], [[attrib objectForKey:@"posY"] intValue]);
}

- (CGRect)_makeRectFromAttrib:(NSDictionary *)attrib {
    return CGRectMake(0,    // x-offset inside the image
                      0,    // y-offset inside the image
                      [[attrib objectForKey:@"sizeW"] intValue],
                      [[attrib objectForKey:@"sizeH"] intValue]);
}

//- (CGRect)_makeRectFromAttribForUIKitElement:(NSDictionary *)attrib {
//    return CGRectMake([[attrib objectForKey:@"posX"] intValue],
//                      [[attrib objectForKey:@"posY"] intValue],
//                      [[attrib objectForKey:@"sizeW"] intValue],
//                      [[attrib objectForKey:@"sizeH"] intValue]);
//}

- (CGSize) _makeSizeFromAttrib:(NSDictionary*) attributes {
	return [self _makeRectFromAttrib:attributes].size;
}

- (NSArray *)_frameListFromPlists:(NSArray *)plistFiles {
    //code from apple documentation:
    NSError *errorDesc;
    NSMutableArray *frameList = [NSMutableArray arrayWithCapacity:20];
    
    for(NSString *fileName in plistFiles) {
        NSString *plistPath = fileName;  // get the plist file either from Documents storage or AppBundle
        
        if (GET_FILE(plistPath) == nil) continue;
        
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:GET_FILE(plistPath)];

        NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
                                              propertyListWithData:plistXML
                                              options:NSPropertyListImmutable
                                              format:NULL
                                              error:&errorDesc];
        NSAssert1(temp, @"im not able to load the plist file %@", plistPath);
        
        NSDictionary *frameDict = [temp objectForKey:@"frames"];
        NSArray *keys = [frameDict allKeys];
        NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];        
        
        NSString *frameName;
        for (frameName in sortedKeys) {
            [frameList addObject:frameName];
        }    
    }
    
    return frameList;
}

- (NSArray *)_loadPlistFiles {
    NSInteger numberOfPlistFiles = [[mediaDef.attributes objectForKey:@"numberOfPlistFiles"] intValue];
    NSMutableArray *fileList = [NSMutableArray arrayWithCapacity:numberOfPlistFiles];
    
    for (NSInteger i = 0; i < numberOfPlistFiles; i++) {
        NSString *fileName = [NSString stringWithFormat:@"%@_%d.plist", mediaDef.value, i];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:fileName];
        [fileList addObject:fileName];
    }
    
    return fileList;
}

#pragma mark PageElementPersistencyProtocol methods

-(id)saveElementStatus {
    if (!isMovable || !displayNode) return nil;
    
    return [NSValue valueWithCGPoint:displayNode.position];
}

-(void)loadElementStatus:(id)saveData {
    if (!isMovable || !displayNode || !saveData) return;
    
    [displayNode setPosition:[saveData CGPointValue]];
}

-(NSString *)getIdentifer {
    return mediaDef.value;
}

@end
