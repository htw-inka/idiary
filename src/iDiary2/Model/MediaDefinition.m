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
//  MediaDefinition.m
//  iPadPresenter
//
//  Created by Markus Konrad on 22.11.10.
//  Copyright 2010 INKA Forschungsgruppe. All rights reserved.
//

#import "MediaDefinition.h"

#import "Constants.h"

@implementation MediaDefinition

@synthesize type;
@synthesize value;
@synthesize attributes;


+(MediaDefinition *)mediaDefinitionWithProgress:(NSString *)pValue inRect:(CGRect)rect duration:(NSNumber*)duration direction:(NSNumber*)direction startTime:(NSNumber*)startTime {
    MediaDefinition *m = [MediaDefinition mediaDefinitionOfType:MEDIA_TYPE_PICTURE withValue:pValue inRect:rect interactive:NO movable:NO];

    [[m attributes] setValue:duration forKey:@"duration"];
    [[m attributes] setValue:direction forKey:@"progressDirection"];
    [[m attributes] setValue:startTime forKey:@"startTime"];
    return m;
}

+(MediaDefinition *)mediaDefinitionWithProgressWithImage:(NSString *)pValue inRect:(CGRect)rect duration:(float)duration direction:(ProgressDirection)direction startTime:(float)startTime {
    return [MediaDefinition mediaDefinitionWithProgress:pValue inRect:rect duration:[NSNumber numberWithFloat:duration] direction:[NSNumber numberWithInt:direction] startTime:[NSNumber numberWithFloat:startTime]];
}

+(MediaDefinition *)mediaDefinitionWithAnimation:(NSString *)pValue numberOfPlistFiles:(NSInteger)number inRect:(CGRect)rect loop:(BOOL)sLoop {
    MediaDefinition *m = [MediaDefinition mediaDefinitionWithAnimation:pValue numberOfPlistFiles:number inRect:rect];
    
    [[m attributes] setValue:[NSNumber numberWithBool:sLoop] forKey:@"loop"];
    
    return m;
}

+(MediaDefinition *)mediaDefinitionWithAnimation:(NSString *)pValue numberOfPlistFiles:(NSInteger)number inRect:(CGRect)rect loop:(BOOL)sLoop delay:(int)pDelay {
    MediaDefinition *m = [MediaDefinition mediaDefinitionWithAnimation:pValue numberOfPlistFiles:number inRect:rect loop:sLoop];
    
    [[m attributes] setValue:[NSNumber numberWithInt:pDelay] forKey:@"startDelay"];
    
    return m;
}

+(MediaDefinition *)mediaDefinitionWithAnimation:(NSString *)pValue numberOfPlistFiles:(NSInteger)number inRect:(CGRect)rect {
    return [MediaDefinition mediaDefinitionOfType:MEDIA_TYPE_ANIM withValue:pValue numberOfPlistFiles:number inRect:rect interactive:NO movable:NO];
}

+(MediaDefinition *)mediaDefinitionOfType:(int)pType withValue:(NSString *)pValue inRect:(CGRect)rect {
    return [MediaDefinition mediaDefinitionOfType:pType withValue:pValue inRect:rect interactive:NO movable:NO];
}

+(MediaDefinition *)mediaDefinitionWithVideo:(NSString *)pValue andButton:(NSString *)pBtnValue inRect:(CGRect)rect {
    MediaDefinition *m = [MediaDefinition mediaDefinitionOfType:MEDIA_TYPE_VIDEO withValue:pValue inRect:rect interactive:YES movable:NO];;
    
    [m.attributes setObject:pBtnValue forKey:@"thumbnail"];
    
    return m;
}

+(MediaDefinition *)mediaDefinitionWithSound:(NSString *)pValue andThumbnail:(NSString *)pThumbValue inRect:(CGRect)rect {
    MediaDefinition *m = [MediaDefinition mediaDefinitionOfType:MEDIA_TYPE_AUDIO withValue:pValue inRect:rect interactive:YES movable:NO];;
    
    [m.attributes setObject:pThumbValue forKey:@"thumbnail"];
    
    return m;
}

+(MediaDefinition *)mediaDefinitionWithText:(NSString *)pValue font:(NSString *)font fontSize:(float)fontSize color:(ccColor3B)fontColor inRect:(CGRect)rect {
    MediaDefinition *m = [MediaDefinition mediaDefinitionOfType:MEDIA_TYPE_TEXT withValue:pValue inRect:rect interactive:NO movable:NO];
    
    ccColor3B *c = (ccColor3B *)malloc(sizeof(ccColor3B));
    c->r = fontColor.r;
    c->g = fontColor.g;
    c->b = fontColor.b;
    
    [m.attributes setObject:font forKey:@"fontFamily"];
    [m.attributes setObject:[NSNumber numberWithFloat:fontSize] forKey:@"fontSize"];
    [m.attributes setObject:[NSValue valueWithPointer:c] forKey:@"fontColor"];
    
    return m;
}

+(MediaDefinition *)mediaDefinitionOfType:(int)pType withValue:(NSString *)pValue inRect:(CGRect)rect interactive:(BOOL)interactive {
    return [MediaDefinition mediaDefinitionOfType:pType withValue:pValue inRect:rect interactive:interactive movable:NO];
}

+(MediaDefinition *)mediaDefinitionOfType:(int)pType withValue:(NSString *)pValue inRect:(CGRect)rect movable:(BOOL)movable {
    return [MediaDefinition mediaDefinitionOfType:pType withValue:pValue inRect:rect interactive:movable movable:movable];
}

+(MediaDefinition *)mediaDefinitionOfType:(int)pType withValue:(NSString *)pValue numberOfPlistFiles:(NSInteger)number inRect:(CGRect)rect interactive:(BOOL)interactive movable:(BOOL)movable {
    MediaDefinition *m = [[MediaDefinition alloc] init];
    
    [m setType:[NSNumber numberWithInt:pType]];
    [m setValue:pValue];
    
    NSMutableDictionary *attrib = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithFloat:rect.origin.x], @"posX",
                                   [NSNumber numberWithFloat:rect.origin.y], @"posY",        
                                   [NSNumber numberWithFloat:rect.size.width], @"sizeW",
                                   [NSNumber numberWithFloat:rect.size.height], @"sizeH",
                                   [NSNumber numberWithInt:number], @"numberOfPlistFiles",
                                   [NSNumber numberWithBool:interactive], @"isInteractive",
                                   [NSNumber numberWithBool:movable], @"isMovable",
                                   nil];
    
    [m setAttributes:attrib];
    
    return [m autorelease];    
}

+(MediaDefinition *)mediaDefinitionOfType:(int)pType withValue:(NSString *)pValue inRect:(CGRect)rect interactive:(BOOL)interactive movable:(BOOL)movable {
    return [MediaDefinition mediaDefinitionOfType:pType withValue:pValue numberOfPlistFiles:0 inRect:rect interactive:interactive movable:movable];
}

-(id) initWithDictionary: (NSMutableDictionary *)mediaObj {
    if (mediaObj == nil) {
        return nil;
    }

    if ((self = [super init])) {
        self.type = [mediaObj objectForKey:@"type"];
        self.value = [mediaObj objectForKey:@"value"];
        self.attributes = [mediaObj objectForKey:@"attributes"];
        
        if (!self.type || !self.value || !self.attributes) {
            return nil;
        }
    }
    
    return self;
}

-(void)dealloc {
    [type release];
    [value release];
    
    NSValue *colorObj = [attributes objectForKey:@"fontColor"];
    if (colorObj && [colorObj pointerValue] != NULL) {
        free([colorObj pointerValue]);
    }
    
    [attributes release];
    
    [super dealloc];
}

- (CGRect)rectFromAttrib {
    const CGFloat x = [[attributes objectForKey:@"posX"] floatValue];
    const CGFloat y = [[attributes objectForKey:@"posY"] floatValue];
    const CGFloat w = [[attributes objectForKey:@"sizeW"] floatValue];
    const CGFloat h = [[attributes objectForKey:@"sizeH"] floatValue];

    return CGRectMake(x, y, w, h);
}

- (void)setZIndex:(int)z {
    [attributes setObject:[NSNumber numberWithInt:z] forKey:@"zIndex"];
}

- (void)setTag:(int)tag {
    [attributes setObject:[NSNumber numberWithInt:tag] forKey:@"tag"];
}

- (void)setStartDelay:(NSTimeInterval)startDelay {
    [attributes setObject:[NSNumber numberWithDouble:startDelay] forKey:@"startDelay"];
}

- (void)setSoundPlayAloneOnly:(BOOL)playAlone {
    [attributes setObject:[NSNumber numberWithBool:playAlone] forKey:@"playAlone"];
}

-(NSString *)description {
   return [NSString stringWithFormat:
                      @"Media: \n      -type: %@\n      -value: %@\n      -attributes: %@\n\n",
                      self.type,
                      self.value,
                      self.attributes];
}

@end
