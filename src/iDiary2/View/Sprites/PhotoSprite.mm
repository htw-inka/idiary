//
//  PhotoSprite.mm
//  iDiary2
//
//  Created by Markus Konrad on 15.07.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "PhotoSprite.h"


@implementation PhotoSprite

#pragma mark public methods

- (id)initWithFile:(NSString *)file atPos:(CGPoint)pos inWorld:(b2World *)w {
    if ((self = [super initWithFile:file])) {        
        // set the file as identifier    
        photoFile = [file retain];
        
        // let PhySprite do the rest
        [super setupWithPos:pos andBehaviour:kPhysicalBehaviorPhoto inWorld:w];
    }
    
    return self;
}

- (void)dealloc {
    [photoFile release];
    
    [super dealloc];
}

#pragma mark PageElementPersistencyProtocol methods

-(id)saveElementStatus {
    return [NSValue valueWithCGPoint:self.position];
}

-(void)loadElementStatus:(id)saveData {    
    [self setPhyPosition:[saveData CGPointValue]];
}

-(NSString *)getIdentifer {
    return photoFile;
}

@end
