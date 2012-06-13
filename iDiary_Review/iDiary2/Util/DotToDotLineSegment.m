//
//  DotToDotLineSegment.m
//  iDiary2
//
//  Created by Markus Konrad on 30.01.12.
//  Copyright (c) 2012 INKA Forschungsgruppe. All rights reserved.
//

#import "DotToDotLineSegment.h"

@implementation DotToDotLineSegment

@synthesize num;
@synthesize line;
@synthesize point;
@synthesize lineDrawn;

-(id)initLineSegmentWithNum:(int)n lineSpriteFile:(NSString *)f pointSprite:(CCSprite *)p progressDirection:(CCProgressTimerType)dir {
    self = [super init];
    
    if (self) {
        num = n;
        line = [[CCProgressTimer progressWithFile:f] retain];
        [line setType:dir];
        point = [p retain];
        lineDrawn = NO;
    }
    
    return self;
}

-(void)dealloc {
    [line release];
    [point release];

    [super dealloc];
}

-(void)drawLine {
    NSLog(@"drawing line #%d", num);
    CCProgressTo *progressAction = [CCProgressFromTo actionWithDuration:kDotToDotLineDrawTime - ((line.percentage / 100.0f) * kDotToDotLineDrawTime)
                                                                   from:line.percentage to:100.0f];
    [line runAction:progressAction];
    
    lineDrawn = YES;
}

@end
