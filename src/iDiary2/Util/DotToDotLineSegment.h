//
//  DotToDotLineSegment.h
//  iDiary2
//
//  Created by Markus Konrad on 30.01.12.
//  Copyright (c) 2012 INKA Forschungsgruppe. All rights reserved.
//

#import "cocos2d.h"

static const float kDotToDotLineDrawTime = 0.5f;

// Line segment for dot-to-dot game
@interface DotToDotLineSegment : NSObject {}

@property (nonatomic,assign) int num;
@property (nonatomic,readonly) CCProgressTimer *line;
@property (nonatomic,readonly) CCSprite *point;
@property (nonatomic,readonly) BOOL lineDrawn;

-(id)initLineSegmentWithNum:(int)n lineSpriteFile:(NSString *)f pointSprite:(CCSprite *)p progressDirection:(CCProgressTimerType)dir;

-(void)drawLine;

@end
