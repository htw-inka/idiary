//
//  OverviewLayer.m
//  iDiary2
//
//  Created by Markus Konrad on 27.04.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "OverviewLayer.h"

#import "Config.h"
#import "Tools.h"
#import "CommonActions.h"
#import "MediaDefinition.h"
#import "ContentElement.h"

static const CGFloat kOverviewLayerPolaroidContentWidth = 136.0f;
static const CGFloat kOverviewLayerPolaroidContentHeight = 123.0f;

static const CGPoint kOverviewLayerInitialBookPos[2] = { ccp(528, 369), ccp(533, 372) };
static const float kOverviewLayerInitialBookRotation[2] = { -5.0f, +5.0f };
static const CGPoint kOverviewLayerBookMoveTo[2] = { ccp(719, 373), ccp(327, 365) };
static const float kOverviewLayerBookRotateTo[2] = { +12.0f, -10.0f };

static const CGPoint kOverviewLayerInitialPolaroidPos[2] = { ccp(719, 373), ccp(327, 365) };
static const float kOverviewLayerInitialPolaroidRotation[2] = { +46.0f, +8.0f };
static const CGPoint kOverviewLayerPolaroidMoveTo[2] = { ccp(889, 373), ccp(327, 615) };
static const float kOverviewLayerPolaroidRotateTo[2] = { 55.0f, 4.0f };

static const CGPoint kOverviewLayerPolaroidContentPos[2] = { ccp(889, 383), ccp(327, 625) };

@interface OverviewLayer(PrivateMethods)
// phase 1: move and rotate books
-(void)animationPhase1;

// phase 2: move and rotate polaroids
-(void)animationPhase2;

// phase 3: start showing the animations in the polaroid
-(void)animationPhase3;
@end

@implementation OverviewLayer

#pragma mark public methods

+(id)nodeWithPersons:(NSArray *)pPersons; {
    NSLog(@"Persons: %@, %@", [pPersons objectAtIndex:0] , [pPersons objectAtIndex:1]);
    return [[[OverviewLayer alloc] initWithPersons:pPersons] autorelease];    
}

-(id)initWithPersons:(NSArray *)pPersons {
    self = [super init];
    if (self) {
        animationEnded = NO;
        core = [CoreHolder sharedCoreHolder];
        NSLog(@"Persons: %@, %@", [pPersons objectAtIndex:0] , [pPersons objectAtIndex:1]);
        // create background
        CCSprite *bg = [CCSprite spriteWithFile:@"default_startscreen_bg.png"];
        [bg setPosition:core.screenCenter];
        [self addChild:bg];
        
        // setup everthing for 2 persons
        for (int i = 0; i < 2; i++) {
            // set the person string
            persons[i] = [[pPersons objectAtIndex:i] retain];
            
            // get the lowercase person string
            NSString *personLC = [persons[i] lowercaseString];
            
            // create the polaroid background
            polaroids[i] = [[CCSprite alloc] initWithFile:@"default_startscreen_polaroid.png"]; 
            [polaroids[i] setVisible:NO];
            CGRect polaroidBounds = [polaroids[i] boundingBox]; // get before rotating
            [polaroids[i] setRotation:kOverviewLayerInitialPolaroidRotation[i]];
            [polaroids[i] setPosition:kOverviewLayerInitialPolaroidPos[i]];
            [self addChild:polaroids[i]];
            
            // create the polaroid picture content (spritesheet animation)
            float animPosX = 0.51 * polaroidBounds.size.width;      // position relative to polaroid background
            float animPosY = 0.57 * polaroidBounds.size.height;     // position relative to polaroid background
            CGRect animRect = CGRectMake(animPosX, animPosY, kOverviewLayerPolaroidContentWidth, kOverviewLayerPolaroidContentHeight);
            MediaDefinition *animMediaDef = [MediaDefinition mediaDefinitionWithAnimation:[NSString stringWithFormat:@"%@_startanim", personLC] numberOfPlistFiles:1 inRect:animRect loop:YES];
            ContentElement *animElem = [ContentElement contentElementForMediaDefintion:animMediaDef];
            [animElem.displayNode setVisible:NO];
            anim[i] = [animElem.displayNode retain];
            [polaroids[i] addChild:anim[i]];  // set as child of the polaroid background
            
            // create the books
            books[i] = [[CCSprite alloc] initWithFile:[NSString stringWithFormat:@"%@_buch.png", personLC]]; 
            [books[i] setOpacity:0];
            [books[i] setRotation:kOverviewLayerInitialBookRotation[i]];
            [books[i] setPosition:kOverviewLayerInitialBookPos[i]];
            [self addChild:books[i]];
        }
    
        // enable touches
        [self setIsTouchEnabled:YES];
        
        
    }
    return self;
}

- (void)dealloc {
    for (int i = 0; i < 2; i++) {
        [persons[i] release];
        [books[i] release];
        [polaroids[i] release];
        [anim[i] release];
    }

    [super dealloc];
}

-(void)startAnimation {
    NSLog(@"Starting animation...");
    
    animationEnded = NO;
    
    for (int i = 0; i < 2; i++) {
        [CommonActions fadeElement:books[i] in:YES];
    }
    
    [self performSelector:@selector(animationPhase1) withObject:nil afterDelay:1.0f];
}

#pragma mark touch handling

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {		
    if (!animationEnded) return;
    
    UITouch *touch = [touches anyObject];
    
    for (int i = 0; i < 2; i++) {
        if ([Tools touch:touch isInNode:books[i]] || [Tools touch:touch isInNode:polaroids[i]]) {
            [core selectedPerson:persons[i]];
        }
    }
}

#pragma mark private methods

-(void)animationPhase1 {
    for (int i = 0; i < 2; i++) {
        CCMoveTo *moveTo = [CCMoveTo actionWithDuration:kOverviewBookAnimationDuration position:kOverviewLayerBookMoveTo[i]];
        CCEaseSineInOut *moveToEased = [CCEaseSineInOut actionWithAction:moveTo];
        [books[i] runAction:moveToEased];
        
        CCRotateTo *rotateTo = [CCRotateTo actionWithDuration:kOverviewBookAnimationDuration angle:kOverviewLayerBookRotateTo[i]];
        CCEaseSineInOut *rotateToEased = [CCEaseSineInOut actionWithAction:rotateTo];
        [books[i] runAction:rotateToEased];
    }
    
    [self performSelector:@selector(animationPhase2) withObject:nil afterDelay:kOverviewBookAnimationDuration];
}

-(void)animationPhase2 {
    for (int i = 0; i < 2; i++) {
        [polaroids[i] setVisible:YES];
        [anim[i] setVisible:YES];
        
        CCMoveTo *moveTo = [CCMoveTo actionWithDuration:kOverviewPolaroidAnimationDuration position:kOverviewLayerPolaroidMoveTo[i]];
        CCEaseSineInOut *moveToEased = [CCEaseSineInOut actionWithAction:moveTo];
        [polaroids[i] runAction:moveToEased];
        
        CCRotateTo *rotateTo = [CCRotateTo actionWithDuration:kOverviewPolaroidAnimationDuration angle:kOverviewLayerPolaroidRotateTo[i]];
        CCEaseSineInOut *rotateToEased = [CCEaseSineInOut actionWithAction:rotateTo];
        [polaroids[i] runAction:rotateToEased];
    }
    
    [self performSelector:@selector(animationPhase3) withObject:nil afterDelay:kOverviewPolaroidAnimationDuration];
}

-(void)animationPhase3 {
    animationEnded = YES;
}

@end
