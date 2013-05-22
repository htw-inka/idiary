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
//  Page_Alice_Example9.mm
//  iDiary2
//
//  Created by Markus Konrad on 21.05.13
//  Copyright 2013 INKA Forschungsgruppe. All rights reserved.
//

#import "Page_Alice_Example9.h"

#import "Makros.h"

@interface Page_Alice_Example9 ()
// Scheduled callback that checks if the words are in the right order
-(void)checkWords:(float)dt;
@end


@implementation Page_Alice_Example9

- (id)init {
    self = [super init];
    if (self) {
        srand(time(NULL));
        
        // set defaults
        success = NO;
        words = [[NSArray alloc] initWithObjects:@"Bring", @"these", @"words", @"in", @"order", nil];        // the words to display
        
        // schedule our callback. it will be called each 0.5 seconds
        [self schedule:@selector(checkWords:) interval:0.5f];
    }
    return self;
}

- (void)dealloc {
    [words release];
    
    [super dealloc];
}

- (void)loadPageContents {
    // set individual properties
    pageBackgroundImg = @"alice_seiten_hintergrund.png";
      
    // add individual media objects for this page here
    MediaDefinition *mDefWelcomeText = [MediaDefinition mediaDefinitionWithText:@"Example 9" font:@"Courier New" fontSize:22 color:ccBLACK inRect:CGRectMake(60, 700, 350, 100)];
    [mediaObjects addObject:mDefWelcomeText];

    // place the words randomly on the screen
    for (NSString *word in words) {
        CGFloat x = RAND_MIN_MAX(150, 1024 - 150);  // 150px border
        CGFloat y = RAND_MIN_MAX(150, 768 - 150);   // ~
        CGRect rect = CGRectMake(x, y, 100, 40);
        
        // create the media definition for each word
        MediaDefinition *wordDef = [MediaDefinition mediaDefinitionWithText:word font:@"Courier New" fontSize:22 color:ccBLACK inRect:rect];
        
        // make it movable and interactive
        [wordDef.attributes setObject:[NSNumber numberWithBool:YES] forKey:@"isMovable"];
        [wordDef.attributes setObject:[NSNumber numberWithBool:YES] forKey:@"isInteractive"];
        
        // add it to the media objects to let them appear on screen
        [mediaObjects addObject:wordDef];
    }

    // common media objects will be loaded in the PageLayer
    [super loadPageContents];
}

#pragma mark private methods

-(void)checkWords:(float)dt {
    CGPoint prevPos = CGPointZero;
    
    // dictionary to order the words later according to their x-coordinate
    NSMutableDictionary *order = [NSMutableDictionary dictionary];
    
    // go through all interactive elements on the page
    for (CCNode *elem in interactiveElements) {
        if (![elem isKindOfClass:[CCLabelTTF class]]) continue; // dismiss if this is not a word
        if (!CGPointEqualToPoint(prevPos, CGPointZero)
            && fabsf(prevPos.y - elem.position.y) > 20) return;  // dismiss if the word is not in row with the order words (20px tolerance)
        
        // our element must be label
        CCLabelTTF *label = (CCLabelTTF *)elem;
        
        // add it to the dictionary. the x-coordinate is the object that will later be used for sorting
        [order setObject:[NSNumber numberWithFloat:elem.position.x] forKey:label.string];
        
        // save as previous position
        prevPos = elem.position;
    }
    
    // now order the words using the x-coordinate saved in the dictionary's objects
    // this method uses objective-c blocks
    NSArray *orderedKeys = [order keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSNumber *)obj1 compare:(NSNumber *)obj2];
    }];
    
    // check the order: if the indexes of the "words" array and the "orderedKeys" array
    // are the same, the order is alright
    NSLog(@"---- Words in order:");
    int currentIdx = 0;
    for (NSString *orderedWord in orderedKeys) {
        NSLog(@"Word: %@", orderedWord);
        int correctIdx = [words indexOfObject:orderedWord];  // uses "isEqual:" and not pointer adress for comparision
        
        if (correctIdx != currentIdx) return;   // dismiss if the order is not ok
        
        currentIdx++;
    }
    
    // if we didn't show the "success" image before, do it now
    if (!success) {
        success = YES;
        
        // show it as progression image
        MediaDefinition *successDef = [MediaDefinition mediaDefinitionWithProgress:@"alice_example2__orden.png"
                                                                            inRect:CGRectMake(820, 220, 315, 325)
                                                                          duration:[NSNumber numberWithDouble:2.0f]
                                                                         direction:[NSNumber numberWithInt:progressDirectionHorizontalLR]
                                                                         startTime:[NSNumber numberWithDouble:0.0f]];
        
        ContentElement *successElem = [ContentElement contentElementOnPageLayer:self forMediaDefintion:successDef];
        [self addChild:successElem.displayNode z:1000];
    }
}

@end
