//
//  Node3DRotateActions.h
//  iDiary2
//
//  Created by Markus Konrad on 01.09.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "CCActionInterval.h"

#import "Node3D.h"

typedef enum {
    kNode3DAxisX = 0,
    kNode3DAxisY,
    kNode3DAxisZ
} Node3DAxis;

@interface Node3DRotateTo : CCRotateTo <NSCopying> {
    Node3DAxis axis;
}

+(id)actionWithDuration: (ccTime) t angle:(float) a axis:(Node3DAxis)pAxis;
-(id)initWithDuration: (ccTime) t angle:(float) a axis:(Node3DAxis)pAxis;

@end

@interface Node3DRotateBy : CCRotateBy <NSCopying> {
    Node3DAxis axis;
}

+(id)actionWithDuration: (ccTime) t angle:(float) a axis:(Node3DAxis)pAxis;
-(id)initWithDuration: (ccTime) t angle:(float) a axis:(Node3DAxis)pAxis;

@end
