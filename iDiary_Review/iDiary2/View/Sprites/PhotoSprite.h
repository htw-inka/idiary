//
//  PhotoSprite.h
//  iDiary2
//
//  Created by Markus Konrad on 15.07.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"

#import "PhySprite.h"
#import "PageElementPersistency.h"

// A photo with "physical" behaviour
@interface PhotoSprite : PhySprite <PageElementPersistencyProtocol> {
    NSString *photoFile;
}

// set the initial position in the physical world w
- (id)initWithFile:(NSString *)file atPos:(CGPoint)pos inWorld:(b2World *)w;

@end
