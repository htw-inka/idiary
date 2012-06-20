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
//  MediaDefinition.h
//  iPadPresenter
//
//  Created by Markus Konrad on 22.11.10.
//  Copyright 2010 INKA Forschungsgruppe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ProgressLayer.h"

// MediaDefinition
// Implements a MediaDefinition, which holds a description of one media object, belonging to a ContentDefintion of one page
@interface MediaDefinition : NSObject {
    NSNumber *type;                     //see Constants.h: MEDIA_TYPE_*
    NSString *value;                    //value string
    NSMutableDictionary *attributes;    //attributes like position, width, etc.
}

@property (copy, nonatomic) NSNumber *type;
@property (copy, nonatomic) NSString *value;
@property (retain, nonatomic) NSMutableDictionary *attributes;


// Initialize a MediaDefinition object with a media object that is a NSMutableDictionary
-(id)initWithDictionary:(NSMutableDictionary *)mediaObj;

// static initializers
+(MediaDefinition *)mediaDefinitionOfType:(int)pType withValue:(NSString *)pValue inRect:(CGRect)rect;
+(MediaDefinition *)mediaDefinitionOfType:(int)pType withValue:(NSString *)pValue inRect:(CGRect)rect interactive:(BOOL)interactive;
+(MediaDefinition *)mediaDefinitionOfType:(int)pType withValue:(NSString *)pValue inRect:(CGRect)rect movable:(BOOL)movable;
+(MediaDefinition *)mediaDefinitionOfType:(int)pType withValue:(NSString *)pValue inRect:(CGRect)rect interactive:(BOOL)interactive movable:(BOOL)movable;
+(MediaDefinition *)mediaDefinitionOfType:(int)pType withValue:(NSString *)pValue numberOfPlistFiles:(NSInteger)number inRect:(CGRect)rect interactive:(BOOL)interactive movable:(BOOL)movable;

+(MediaDefinition *)mediaDefinitionWithProgress:(NSString *)pValue inRect:(CGRect)rect duration:(NSNumber*)duration direction:(NSNumber*)direction startTime:(NSNumber*)startTime;
+(MediaDefinition *)mediaDefinitionWithProgressWithImage:(NSString *)pValue inRect:(CGRect)rect duration:(float)duration direction:(ProgressDirection)direction startTime:(float)startTime;
+(MediaDefinition *)mediaDefinitionWithAnimation:(NSString *)pValue numberOfPlistFiles:(NSInteger)number inRect:(CGRect)rect;
+(MediaDefinition *)mediaDefinitionWithAnimation:(NSString *)pValue numberOfPlistFiles:(NSInteger)number inRect:(CGRect)rect loop:(BOOL)sLoop;
+(MediaDefinition *)mediaDefinitionWithAnimation:(NSString *)pValue numberOfPlistFiles:(NSInteger)number inRect:(CGRect)rect loop:(BOOL)sLoop delay:(int)pDelay;
+(MediaDefinition *)mediaDefinitionWithVideo:(NSString *)pValue andButton:(NSString *)pBtnValue inRect:(CGRect)rect;
+(MediaDefinition *)mediaDefinitionWithSound:(NSString *)pValue andThumbnail:(NSString *)pThumbValue inRect:(CGRect)rect;
+(MediaDefinition *)mediaDefinitionWithText:(NSString *)pValue font:(NSString *)font fontSize:(float)fontSize color:(ccColor3B)fontColor inRect:(CGRect)rect;

// set a z-order value in the attributes
- (void)setZIndex:(int)z;

// set a tag value in the attributes
- (void)setTag:(int)tag;

// set a start delay value for animations
- (void)setStartDelay:(NSTimeInterval)startDelay;

// set a sound setting: enable/disable playing of this sound alone only
- (void)setSoundPlayAloneOnly:(BOOL)playAlone;

// create a CGRect from the attributes
- (CGRect)rectFromAttrib;

// Returns a string representation of this object.
- (NSString *)description;


@end
