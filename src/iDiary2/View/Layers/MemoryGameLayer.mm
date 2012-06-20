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
//  MemoryGameLayer.mm
//  iDiary2
//
//  Created by Markus Konrad on 05.10.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "MemoryGameLayer.h"

#import "Makros.h"
#import "Tools.h"
#import "Node3DRotateActions.h"
#import "Config.h"

#pragma mark ---
#pragma mark constants
#pragma mark ---

static const float kRandomCardLocationMaxOffset = 3.0f;
static const float kRandomCardLocationMaxAngle = 5.0f;
static const float kFlipAnimDur = 0.25f;
static const float kFlipBackDelay = 1.5f;

enum {
    kBackSpriteTag = 1,
    kFrontSpriteTag
};

#pragma mark ---
#pragma mark MemoryCard implementation
#pragma mark ---

@implementation MemoryCard

@synthesize node;
@synthesize backSprite;
@synthesize frontSprite;
@synthesize isFlipped;
@synthesize flipAnimIsRunning;
@synthesize column;
@synthesize row;

-(id)init {
    self = [super init];
    if (self) {
        // set defaults
        isFlipped = NO;
        flipAnimIsRunning = NO;
        column = 0;
        row = 0;
    }
    
    return self;
}

-(void)dealloc {
    [node release];
    [backSprite release];
    [frontSprite release];

    [super dealloc];
}

@end

#pragma mark ---
#pragma mark MemoryCardPair implementation
#pragma mark ---

@implementation MemoryCardPair

@synthesize identifier;
@synthesize card1;
@synthesize card2;
@synthesize matched;
@synthesize successObject;
@synthesize successAction;

-(id)init {
    self = [super init];
    if (self) {
        // set defaults
        matched = NO;
    }
    
    return self;
}

-(void)dealloc {
    [identifier release];
    [card1 release];
    [card2 release];

    [super dealloc];
}

@end

#pragma mark ---
#pragma mark MemoryGameLayer private declarations & class implementation
#pragma mark ---

@interface MemoryGameLayer(PrivateMethods)
// handle a touch on a card and return YES if the card was touched
-(BOOL)handleTouch:(UITouch *)touch onCard:(MemoryCard *)card ofPair:(MemoryCardPair *)pair;

// creates and runs the flip card animation
-(void)flipCard:(MemoryCard *)card ofPair:(MemoryCardPair *)pair doGameChecks:(BOOL)gameChecks;

// method to be called in a performSelector:-manner
-(void)flipCardDelayed:(NSArray *)params;

// swap the front/back-sprites of a card when it is being flipped
-(void)swapCardSprites:(CCNode *)cardNode ofPairAndCard:(NSArray *)pairAndCard;

// called when the flip anim finished
-(void)swapCardSpritesFinished:(CCNode *)cardNode ofPairAndCard:(NSArray *)pairAndCard;

// unload a sound, destroy the buffer
-(void)unloadSoundForId:(int)sndId object:(SoundObject *)obj;
@end

@implementation MemoryGameLayer

@synthesize matchSuccessActionCallDelay;
@synthesize gameFinishedAction;
@synthesize gameFinishedObject;
@synthesize pairs;

#pragma mark init/dealloc

-(id)initOnPageLayer:(PageLayer *)page inRect:(CGRect)rect rows:(int)r columns:(int)c coverImage:(NSString *)cover {
    self = [super init];
    if (self) {
        // set defaults
        pageLayer = page;
        displayRect = rect;
        rows = r;
        columns = c;
        pairs = [[NSMutableArray alloc] initWithCapacity:rows * columns / 2.0f];
        coverImage = [cover retain];
        numCardsFlipped = 0;
        numPairsMatched = 0;
        matchSuccessActionCallDelay = 0.0f;
        sndHandler = [SoundHandler shared];
        gameFinished = NO;
        
        [self setIsTouchEnabled:YES];
        
        // create card cover batch node
//        coverSpriteBatchNode = [[CCSpriteBatchNode alloc] initWithFile:cover capacity:rows * columns];
    }
    
    return self;
}

-(void)dealloc {
    [self unloadSoundForId:flipSndId    object:flipSndObj];
    [self unloadSoundForId:successSndId object:successSndObj];

    [pairs release];
    [coverImage release];

    [super dealloc];
}

#pragma mark public methods

-(void)addPair:(NSString *)img successObject:(id)successObj successAction:(SEL)successAction {    
    // create memory cards
    MemoryCard *card1 = [[[MemoryCard alloc] init] autorelease];
    MemoryCard *card2 = [[[MemoryCard alloc] init] autorelease];
    
    // create sprites
    CCSprite *backSprite1 = [CCSprite spriteWithFile:coverImage];
    CCSprite *frontSprite1 = [CCSprite spriteWithFile:img];
    CCSprite *backSprite2 = [CCSprite spriteWithFile:coverImage];
    CCSprite *frontSprite2 = [CCSprite spriteWithFile:img];
    
    [frontSprite1 setVisible:NO];
    [frontSprite2 setVisible:NO];
    
    [card1 setFrontSprite:frontSprite1];
    [card1 setBackSprite:backSprite1];
    [card2 setFrontSprite:frontSprite2];
    [card2 setBackSprite:backSprite2];
    
    // create pair
    MemoryCardPair *pair = [[[MemoryCardPair alloc] init] autorelease];
    [pair setIdentifier:img];
    [pair setCard1:card1];
    [pair setCard2:card2];
    [pair setSuccessObject:successObj];
    [pair setSuccessAction:successAction];
    
    // add pair to array
    [pairs addObject:pair];
}

-(void)generateGame {
    const int numCards = rows * columns;
    
    NSAssert(numCards <= [pairs count] * 2, @"Not enough card pairs added!");
    
    // create nodes-array
    NSMutableArray *nodes = [NSMutableArray arrayWithCapacity:numCards];
    
    for (int i = 0; i < numCards; i++) {
        // get the current pair
        MemoryCardPair *pair = [pairs objectAtIndex:i/2];
        
        // get the current card
        MemoryCard *card;
        if (i % 2 == 0) {
            card = pair.card1;
        } else {
            card = pair.card2;
        }
            
        // create and set up Node3D
        Node3D *node = [Node3D node];
        [node addChild:card.backSprite z:0 tag:kBackSpriteTag];    // the back sprite is shown as default
        [node addChild:card.frontSprite z:0 tag:kFrontSpriteTag];
        [pageLayer.interactiveElements addObject:card.backSprite];
        
        [nodes addObject:node];
        
        // set the Node3D to the card
        [card setNode:node];
        [node setUserData:card];    // and vice versa
    }
    
    // set node positions with (slightly random) positions and rotations
    // first shuffle the array
    [Tools shuffleArray:nodes];
    
    // set cell width, height and offsets
    const float cellW = displayRect.size.width / (float)columns;
    const float cellH = displayRect.size.height / (float)rows;
    const float startX = displayRect.origin.x + cellW / 2.0f;
    const float startY = displayRect.origin.y + cellH / 2.0f;
    
    // make placement a bit random, so it looks naturally
    int i = 0;
    for (Node3D *node in nodes) {
        // make placement a bit random, so it looks naturally
        
        // calculate pos
        float posX = startX + (i % columns) * cellW + RAND_MIN_MAX(-kRandomCardLocationMaxOffset, kRandomCardLocationMaxOffset);
        float posY = startY + (i % rows) * cellH + RAND_MIN_MAX(-kRandomCardLocationMaxOffset, kRandomCardLocationMaxOffset);;
        
        // calculate angle
        float randAngle = RAND_MIN_MAX(-kRandomCardLocationMaxAngle, kRandomCardLocationMaxAngle);
        
        // set up Node3D
        [node setPosition:ccp(posX, posY)];
        [node setRotation:randAngle];

        // set it as child of the current layer
        [self addChild:node];
        
        // set rows/columns
        MemoryCard *card = (MemoryCard *)node.userData;
        [card setColumn:i % columns];
        [card setRow:i % rows];
        
        i++;
    }
}

-(NSArray *)getFinishedPairIds {
    NSMutableArray *arr = [NSMutableArray array];
 
    for (MemoryCardPair *pair in pairs) {
        if (pair.matched) {
            [arr addObject:pair.identifier];
        }
    }
    
    return arr;
}

-(void)setFlipSound:(NSString *)sndFile {
    [self unloadSoundForId:flipSndId object:flipSndObj];

    flipSndId = [sndHandler registerSoundToLoad:sndFile looped:NO gain:kFxSoundVolume];
    [sndHandler loadRegisteredSounds];
    flipSndObj = [[sndHandler getSound:flipSndId] retain];
}

-(void)setSuccessSound:(NSString *)sndFile {
    [self unloadSoundForId:successSndId object:successSndObj];

    successSndId = [sndHandler registerSoundToLoad:sndFile looped:NO gain:kFxSoundVolume];
    [sndHandler loadRegisteredSounds];
    successSndObj = [[sndHandler getSound:successSndId] retain];
}

#pragma mark touch handling

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    if (numCardsFlipped >= 2 || gameFinished) return;
    
    for (MemoryCardPair *pair in pairs) {
        if ([self handleTouch:touch onCard:pair.card1 ofPair:pair]
        ||  [self handleTouch:touch onCard:pair.card2 ofPair:pair]) {
        
            [[CoreHolder sharedCoreHolder] setInteractiveObjectWasTouched:YES];
            return;
        }
    }
}

#pragma mark PageElementPersitencyProtocol methods

-(id)saveElementStatus {
    NSMutableDictionary *saveData = [NSMutableDictionary dictionary];

    // data of this object
    [saveData setObject:[NSValue valueWithCGRect:displayRect] forKey:@"displayRect"];
    [saveData setObject:[NSNumber numberWithInt:rows] forKey:@"rows"];
    [saveData setObject:[NSNumber numberWithInt:columns] forKey:@"columns"];
    [saveData setObject:coverImage forKey:@"coverImage"];
    [saveData setObject:[NSNumber numberWithInt:numPairsMatched] forKey:@"numPairsMatched"];
    [saveData setObject:[NSNumber numberWithBool:gameFinished] forKey:@"gameFinished"];
    [saveData setObject:pairs forKey:@"pairs"];

    // remove pairs from layer
    [self removeAllChildrenWithCleanup:YES];

    return saveData;
}

-(void)loadElementStatus:(id)saveData {
    // set data for this object:
    displayRect = [[saveData objectForKey:@"displayRect"] CGRectValue];
    rows = [[saveData objectForKey:@"rows"] intValue];
    columns = [[saveData objectForKey:@"columns"] intValue];
    [coverImage release];
    coverImage = [[saveData objectForKey:@"coverImage"] retain];
    numPairsMatched = [[saveData objectForKey:@"numPairsMatched"] intValue];
    gameFinished = [[saveData objectForKey:@"gameFinished"] boolValue];
    [pairs release];
    pairs = [[saveData objectForKey:@"pairs"] retain];
    
    // add the pairs again to the layer:
    for (MemoryCardPair *pair in pairs) {
        [self addChild:pair.card1.node];
        [self addChild:pair.card2.node];
    }
}

-(NSString *)getIdentifer {
    return @"MemoryGameLayer";  // should be unique enough
}

#pragma mark private methods

-(void)unloadSoundForId:(int)sndId object:(SoundObject *)obj {
    if (!obj) return;

    [sndHandler unloadSound:sndId];
    [obj release];
    obj = nil;
}

-(BOOL)handleTouch:(UITouch *)touch onCard:(MemoryCard *)card ofPair:(MemoryCardPair *)pair {
    // prevent touching the same card twice
    if (numCardsFlipped == 1 && card.isFlipped) return NO;

    // we touched something interesting...
    [pageLayer cancelHighlightAnimations];

    // get the right sprite
    CCSprite *sprite;
    
    if (!card.isFlipped) {
        sprite = card.backSprite;
    } else {
        sprite = card.frontSprite;
    }

    // check if it's touched
    if ([Tools touch:touch isInNode:sprite] && !card.flipAnimIsRunning) {
        [self flipCard:card ofPair:pair doGameChecks:YES];
        numCardsFlipped++;
        
        return YES;
    }
    
    return NO;
}

-(void)flipCardDelayed:(NSArray *)params {
    [self flipCard:[params objectAtIndex:0]
            ofPair:[params objectAtIndex:1]
      doGameChecks:[[params objectAtIndex:2] boolValue]];
      
    numCardsFlipped = 0;
}

-(void)flipCard:(MemoryCard *)card ofPair:(MemoryCardPair *)pair doGameChecks:(BOOL)gameChecks {
    // play sound
    [flipSndObj play];
    
    // set new status
    [card setFlipAnimIsRunning:YES];
    
    // rotate to 90°
    float rotAngle = 90.0f;
    rotAngle += (columns - card.column - 1) * 10.0f;    // this is because of the 3D-to-2D projection: cards more left flip the sprite later
    CCActionInterval *rotateAction = [Node3DRotateTo actionWithDuration:kFlipAnimDur / 2.0f angle:rotAngle axis:kNode3DAxisY];
    // call swap sprites function
    NSArray *pairAndCard = [[NSArray alloc] initWithObjects:pair, card, [NSNumber numberWithBool:gameChecks], nil];
    CCCallFuncN *swapAction = [CCCallFuncND actionWithTarget:self selector:@selector(swapCardSprites:ofPairAndCard:) data:pairAndCard];
    
    // create the action sequence
    CCSequence *seq = [CCSequence actions:rotateAction, swapAction, nil];
    
    // run the sequence
    [card.node runAction:seq];
}

-(void)swapCardSprites:(CCNode *)cardNode ofPairAndCard:(NSArray *)pairAndCard {
//    NSLog(@"label sprite swapping for %d", labelNode.tag);
    MemoryCard *card = [pairAndCard objectAtIndex:1];

    CCSprite *frontSprite = (CCSprite *)[cardNode getChildByTag:kFrontSpriteTag];      // get the sprite
    CCSprite *backSprite = (CCSprite *)[cardNode getChildByTag:kBackSpriteTag];  // get the sprite back
    
    // swap visibility
    [frontSprite setVisible:!frontSprite.visible];
    [backSprite setVisible:!backSprite.visible];
    
    // rotate by 90°
    float rotAngle = 180.0f;
    if (card.isFlipped) rotAngle = 0.0f;
//    float rotAngle = fabsf(180.0f - fmodf([(Node3D *)labelNode rotationY], 360.0f));
    CCActionInterval *rotateAction = [Node3DRotateTo actionWithDuration:kFlipAnimDur / 2.0f angle:rotAngle axis:kNode3DAxisY];
    // call swap sprites function
    CCCallFuncN *swapAction = [CCCallFuncND actionWithTarget:self selector:@selector(swapCardSpritesFinished:ofPairAndCard:) data:pairAndCard];

    // create the action sequence
    CCSequence *seq = [CCSequence actions:rotateAction, swapAction, nil];

    // run the sequence
    [card.node runAction:seq];
}

-(void)swapCardSpritesFinished:(CCNode *)cardNode ofPairAndCard:(NSArray *)pairAndCard {
    MemoryCardPair *pair = [pairAndCard objectAtIndex:0];
    MemoryCard *card = [pairAndCard objectAtIndex:1];
    BOOL gameChecks = [[pairAndCard objectAtIndex:2] boolValue];
    
    // set new status
    [card setFlipAnimIsRunning:NO];
    [card setIsFlipped:!card.isFlipped];
    
    // check if a pair is already flipped
    if (gameChecks) {
        if (curFlippedPair) {
            // check if this card belongs to the currently flipped pair
            if (curFlippedPair == pair) {
                NSLog(@"found pair: %@", pair.identifier);
                
                // set matched
                [pair setMatched:YES];
                
                // play sound
                [successSndObj play];
                
                // start success action after delay
                [pair.successObject performSelector:pair.successAction withObject:pair.identifier afterDelay:matchSuccessActionCallDelay];
                
                // reset
                numCardsFlipped = 0;
                numPairsMatched++;
                
                if (numPairsMatched >= [pairs count]) {
                    // we're done!
                    [gameFinishedObject performSelector:gameFinishedAction withObject:nil afterDelay:matchSuccessActionCallDelay];
                    
                    gameFinished = YES;
                }
            } else {
                // flip back the current card
                [self performSelector:@selector(flipCardDelayed:)
                           withObject:[NSArray arrayWithObjects:card, pair, [NSNumber numberWithBool:NO], nil]
                           afterDelay:kFlipBackDelay];
                
                
                // flip back the previous card
                if (curFlippedPair.card1.isFlipped) {
                    [self performSelector:@selector(flipCardDelayed:)
                               withObject:[NSArray arrayWithObjects:curFlippedPair.card1, curFlippedPair, [NSNumber numberWithBool:NO], nil]
                               afterDelay:kFlipBackDelay];
                } else if (curFlippedPair.card2.isFlipped) {
                    [self performSelector:@selector(flipCardDelayed:)
                               withObject:[NSArray arrayWithObjects:curFlippedPair.card2, curFlippedPair, [NSNumber numberWithBool:NO], nil]
                               afterDelay:kFlipBackDelay];
                }
            }
            
            // reset
            curFlippedPair = nil;
        } else {    // no card flipped yet
            curFlippedPair = pair;
        }
    }
    
    [pairAndCard release];
}


@end
