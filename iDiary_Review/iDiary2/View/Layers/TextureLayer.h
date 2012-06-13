//
//  TextureLayer.h
//  iDiary2
//
//  Created by Markus Konrad on 16.05.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"

@interface TextureLayer : CCLayer {
    CGPoint texPoint;
    CGPoint texOffset;
    CGSize texSize;
    CGSize drawSize;
    ccColor4B texColor;
    
    CCTexture2D *texture; // the texture
}

@property (nonatomic) CGPoint texPoint;
@property (nonatomic) CGPoint texOffset;
@property (nonatomic) CGSize texSize;
@property (nonatomic) ccColor4B texColor;

-(void)setupWithTextureFile:(NSString *)file andDrawSize:(CGSize)s;

@end
