//
//  MemoryGameLayer.h
//  iDiary2
//
//  Created by Markus Konrad on 05.10.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "cocos2d.h"

#import "Node3D.h"
#import "PageLayer.h"
#import "SoundHandler.h"
#import "PageElementPersistency.h"

// A MemoryCard is a single card for the memory game that has a front and a back side
// These sprites are connected to a Node3D so that the card can be flipped
@interface MemoryCard : NSObject {
    Node3D *node;           // node which can be turned around in 3D space
    CCSprite *backSprite;   // back sprite is usually a sprite with the coverImage of the MemoryGameLayer
    CCSprite *frontSprite;  // individual front sprite
    BOOL isFlipped;         // is YES when it lies with the front side visible
    BOOL flipAnimIsRunning; // is YES while the "flip" animation is running
    int column;             // location x
    int row;                // location y
}

@property (nonatomic,retain) Node3D *node;
@property (nonatomic,retain) CCSprite *backSprite;
@property (nonatomic,retain) CCSprite *frontSprite;
@property (nonatomic,assign) BOOL isFlipped;
@property (nonatomic,assign) BOOL flipAnimIsRunning;
@property (nonatomic,assign) int column;
@property (nonatomic,assign) int row;

@end

// A MemoryCardPair consists of an identifier (usually the image file name of the card front side)
// and two cards that form the pair.
@interface MemoryCardPair : NSObject {
    NSString *identifier;   // unique identifier for this pair
    MemoryCard *card1;      // card #1
    MemoryCard *card2;      // card #2 with same image as card #1
    BOOL matched;       // is YES when the pair has been successfully matched
    id successObject;   // successAction is called on that object when the pair was matched
    SEL successAction;  // this action is called on successObject when the pair was matched
}

@property (nonatomic,retain) NSString *identifier;
@property (nonatomic,retain) MemoryCard *card1;
@property (nonatomic,retain) MemoryCard *card2;
@property (nonatomic,assign) BOOL matched;
@property (nonatomic,assign) id successObject;
@property (nonatomic,assign) SEL successAction;

@end

// The memory game layer displays all memory cards in rows and columns in the displayRect
// and handles all the interactions.
@interface MemoryGameLayer : CCLayer<PageElementPersistencyProtocol> {
    PageLayer *pageLayer;   // parent PageLayer object (weak ref)

    CGRect displayRect; // rectangle in which the memory game layer is shown
    int rows;           // number of card rows
    int columns;        // number of card columns
    
    NSString *coverImage;   // cover image file for each card
    
    NSMutableArray *pairs;  // array with MemoryCardPair objects
    
    MemoryCardPair *curFlippedPair; // the currently flipped pair or nil
    
    int numCardsFlipped;    // number of cards that are currently flipped (cannot exceed 2)
    int numPairsMatched;    // number of successfully matched pairs
    
    BOOL gameFinished;      // is YES if all pairs have been matched
    
    // sounds:
    SoundHandler *sndHandler;
    
    int flipSndId;
    SoundObject *flipSndObj;
    int successSndId;
    SoundObject *successSndObj;
}

// the time after which a successAction will be called after a successfull match of a card pair
@property (nonatomic,assign) NSTimeInterval matchSuccessActionCallDelay;

// action to be called after game has finished
@property (nonatomic,assign) id gameFinishedObject;
@property (nonatomic,assign) SEL gameFinishedAction;

// readonly access to array with MemoryCardPair objects
@property (nonatomic,readonly) NSArray *pairs;

// init the MemoryGameLayer with the display rectangle, rows, columns and the cover image for all cards
-(id)initOnPageLayer:(PageLayer *)page inRect:(CGRect)rect rows:(int)r columns:(int)c coverImage:(NSString *)cover;

// Add a pair of cards.
// "generateGame" needs to be called after all pairs were added!
// When the pair was correctly matched, successAction will be called on successObject
-(void)addPair:(NSString *)img successObject:(id)successObj successAction:(SEL)successAction;

// creates an array with NSStrings with ids of already finished MemoryCard pairs
-(NSArray *)getFinishedPairIds;

// Randomly places the cards.
-(void)generateGame;

// set flip sound
-(void)setFlipSound:(NSString *)sndFile;

// set success sound
-(void)setSuccessSound:(NSString *)sndFile;

@end
