//
//  CountryQuiz.h
//  iDiary2
//
//  Created by Markus Konrad on 09.08.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "cocos2d.h"

#import "ArrangeGameLayer.h"
#import "SoundHandler.h"

enum {
//    kCountrySpriteSetNote = 0,
//    kCountrySpriteSetBackground = 0,
    kCountrySpriteSetOutline = 0,
    kCountrySpriteSetArea
};

@interface CountryQuiz : ArrangeGameLayer {
    NSMutableDictionary *sprites;   // dictionary with NSString country -> NSArray sprite set mapping. see kCountrySpriteSet* enums for array contents
    NSString *imgFilePrefix;        // prefix for each image file
    
    int scribbleSndId;
    SoundObject *scribbleSnd;
}

// init the country quiz game
-(id)initOnPageLayer:(PageLayer *)layer withImageFilePrefix:(NSString *)prefix;

// add a new country with the country note's initial position and the target country position
-(void)addCountry:(NSString *)country notePos:(CGPoint)notePos countryPos:(CGPoint)countryPos;
-(void)addCountry:(NSString *)country notePos:(CGPoint)notePos countryPos:(CGPoint)countryPos useDivergentTargetPos:(CGPoint)targetPos;

@end