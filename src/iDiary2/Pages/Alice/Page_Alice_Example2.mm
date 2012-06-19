//
//  Page_Alice_Example2.m
//  iDiary2
//
//  Created by Markus Konrad on 13.06.12.
//  Copyright (c) 2012 INKA Forschungsgruppe. All rights reserved.
//

#import "Page_Alice_Example2.h"

#import "Tools.h"
#import "Node3DRotateActions.h"

// Define some tags
enum {
    kLabelSpriteTag = 1,
    kLabelBackSpriteTag,
};

// duration for label flip animation
static const float kLabelFlipAnimDur = 0.5f;

@interface Page_Alice_Example2(PrivateMethods)
// swaps the label sprites so that the other side of the label is shown.
// after that, rotates the label further.
-(void)swapLabelSprites:(CCNode *)labelNode;

// is called when the label has been completed turned around.
-(void)swapLabelSpritesFinished:(CCNode *)labelNode;

// dangle animation
-(void)dangleLabel:(CCNode *)labelNode;
@end


@implementation Page_Alice_Example2

- (id)init {
    self = [super init];
    if (self) {
        srand(time(NULL));
    
        // sounds
        swoshSndId = [self addFxSound:@"swosh1.mp3"];
        
        // rect for the text behind the texture
        priceRect = CGRectMake(820, 220, 315, 325);
        
        // texture on top of the text
        CCSprite *textureSprite = [CCSprite spriteWithFile:@"alice_example2__textur.png"];
        [textureSprite setPosition:ccp(822, 229)];
        
        // a sprite that is used as brush to wipe away the texture
        CCSprite *brushSprite = [CCSprite spriteWithFile:@"play_button_bg.png"];
        [brushSprite setScale:0.33f];
        [brushSprite setOpacity:2];
        
        // create the sprite mask on this page layer
        spriteMask = [[MagicLayer alloc] initOnPageLayer:self maskedSprite:textureSprite brush:brushSprite];
        [spriteMask setRubSound:@"scratch3.mp3"];
        [spriteMask setInteractionArea:CGRectMake(priceRect.origin.x - priceRect.size.width / 2.0f, priceRect.origin.y - priceRect.size.height / 2.0f, priceRect.size.width, priceRect.size.height)];
        [self addChild:spriteMask z:100];

    }
    return self;
}

- (void)dealloc {
    [spriteMask release];
    [labelNode release];
    
    [super dealloc];
}

- (void)loadPageContents {
    // set individual properties
    pageBackgroundImg = @"alice_seiten_hintergrund.png";
      
    // add individual media objects for this page here
    MediaDefinition *mDefWelcomeText = [MediaDefinition mediaDefinitionWithText:@"This page shows how to use Node3D, ProgressLayer and MagicLayer classes as well as background sounds."
                                                                           font:@"Courier New"
                                                                       fontSize:18
                                                                          color:ccBLACK
                                                                         inRect:CGRectMake(580, 700, 350, 100)];
    
    [mediaObjects addObject:mDefWelcomeText];

    // ----------------------------------------- //
    
    // add rope for "3D" label 
    [mediaObjects addObject:[MediaDefinition mediaDefinitionOfType:MEDIA_TYPE_PICTURE withValue:@"alice_example2__etikett1_strick.png" inRect:CGRectMake(175, 749, 64, 238)]];
    
    // set defaults
    labelFlipAnimRunning = NO;
    labelBackSideShowing = NO;
    
    // load label sprites for front and back
    CCSprite *labelSprite = [CCSprite spriteWithFile:@"alice_example2__etikett1.png"];
    CCSprite *labelBackSprite = [CCSprite spriteWithFile:@"alice_example2__etikett1_rueck.png"];
    [labelBackSprite setFlipX:YES];     // the back side must be flipped!
    [labelBackSprite setVisible:NO];
    
    // set label positions
    CGPoint labelPos = ccp(144, 473);
    
    // create special 3D node for flip animations
    labelNode = [[Node3D alloc] init];
    
    // add the sprites as children
    [labelNode addChild:labelSprite z:0 tag:kLabelSpriteTag];
    [labelNode addChild:labelBackSprite z:0 tag:kLabelBackSpriteTag];
    
    // set the position
    [labelNode setPosition:labelPos];
    
    // add 3D node as child
    [self addChild:labelNode z:101 tag:123];
    
    // start a "dangle" animation
    dangleAngle = 0.0f;
    dangleRepeatNum = 0;
    [self dangleLabel:labelNode];
    
    // ----------------------------------------- //
    
    // add medal and text
    [mediaObjects addObject:[MediaDefinition mediaDefinitionOfType:MEDIA_TYPE_PICTURE withValue:@"alice_example2__orden.png" inRect:priceRect interactive:YES]];
    [mediaObjects addObject:[MediaDefinition mediaDefinitionOfType:MEDIA_TYPE_PICTURE withValue:@"alice_example2__schrift_best_3.png" inRect:CGRectMake(823, 230, 146, 160)]];
    
    // scribble animation
    NSTimeInterval scribbleDuration = 4.0f;
    NSTimeInterval scribbleStartDelay = 1.5f;
    
    [mediaObjects addObject:[MediaDefinition mediaDefinitionWithProgress:@"alice_example2__silhouette.png"
                                                                  inRect:CGRectMake(500, 98, 970, 86)
                                                                duration:[NSNumber numberWithDouble:scribbleDuration]
                                                               direction:[NSNumber numberWithInt:progressDirectionHorizontalLR]
                                                               startTime:[NSNumber numberWithDouble:scribbleStartDelay]]];
    
    // ----------------------------------------- //
    
    // scribble sound
    [self addBackgroundSound:@"scribble.mp3" looped:NO startTime:(scribbleStartDelay - 0.7f) duration:scribbleDuration];

    // ----------------------------------------- //
    
    // common media objects will be loaded in the PageLayer
    [super loadPageContents];
}


#pragma mark touch handling

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super ccTouchesBegan:touches withEvent:event];

    UITouch *touch = [touches anyObject];
    
    // check if we touched a label
    CCSprite *labelSprite = (CCSprite *)[labelNode getChildByTag:kLabelSpriteTag];      // get the sprite
    CCSprite *labelBackSprite = (CCSprite *)[labelNode getChildByTag:kLabelBackSpriteTag];  // get the sprite back
    
    if (!labelFlipAnimRunning
    && ([Tools touch:touch isInNode:labelSprite] || [Tools touch:touch isInNode:labelBackSprite])) { // a label has been touched
        [core setInteractiveObjectWasTouched:YES];
    
        // play sound
        [[sndHandler getSound:swoshSndId] playAtPitch:1.5f];
    
        // set new status
        labelFlipAnimRunning = YES;
        
        [labelNode stopAllActions];
        
        // rotate by 90°
        float rotAngle = 90.0f;
        
        CCActionInterval *rotateAction = [Node3DRotateTo actionWithDuration:kLabelFlipAnimDur / 2.0f angle:rotAngle axis:kNode3DAxisY];
        // call swap sprites function
        CCCallFuncN *swapAction = [CCCallFuncN actionWithTarget:self selector:@selector(swapLabelSprites:)];
        
        // create the action sequence
        CCSequence *seq = [CCSequence actions:rotateAction, swapAction, nil];
        
        // run the sequence
        [labelNode runAction:seq];
    }
}

#pragma mark private methods

-(void)swapLabelSprites:(CCNode *)labelNode {
//    NSLog(@"label sprite swapping for %d", labelNode.tag);

    CCSprite *labelSprite = (CCSprite *)[labelNode getChildByTag:kLabelSpriteTag];      // get the sprite
    CCSprite *labelBackSprite = (CCSprite *)[labelNode getChildByTag:kLabelBackSpriteTag];  // get the sprite back
    
    // swap visibility
    [labelSprite setVisible:!labelSprite.visible];
    [labelBackSprite setVisible:!labelBackSprite.visible];
    
    // rotate by 90°
    float rotAngle = 180.0f;
    if (labelBackSideShowing) rotAngle = 0.0f;

    CCActionInterval *rotateAction = [Node3DRotateTo actionWithDuration:kLabelFlipAnimDur / 2.0f angle:rotAngle axis:kNode3DAxisY];

    // call swap sprites function
    CCCallFuncN *swapAction = [CCCallFuncN actionWithTarget:self selector:@selector(swapLabelSpritesFinished:)];

    // create the action sequence
    CCSequence *seq = [CCSequence actions:rotateAction, swapAction, nil];

    // run the sequence
    [labelNode runAction:seq];
}

-(void)swapLabelSpritesFinished:(CCNode *)labelNode {
    labelFlipAnimRunning = NO;   // reset status
    labelBackSideShowing = !labelBackSideShowing;
    
    // start again with dangle di ding dong
    [self dangleLabel:labelNode];
}

-(void)dangleLabel:(CCNode *)labelNode {    
    // set dangle angle
    if (dangleRepeatNum % 2 == 0) {
        dangleAngle = CCRANDOM_MINUS1_1() * 5.0f; // start new rotation
    } else {
        dangleAngle *= -1.0f;    // rotate back
    }
    
    // set dangle duration
    float dangleDur = 1.5f + CCRANDOM_0_1() * 0.25f;
    
    // create actions
    CCActionInterval *dangleAction = [Node3DRotateBy actionWithDuration:dangleDur angle:dangleAngle axis:kNode3DAxisY];
    CCCallFuncN *dangleCallback = [CCCallFuncN actionWithTarget:self selector:@selector(dangleLabel:)];
    
    // create and run sequence
    CCSequence *dangleSeq = [CCSequence actions:dangleAction, dangleCallback, nil];
    
    [labelNode runAction:dangleSeq];
    
    // increase repeat number
    dangleRepeatNum++;
}


@end
