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
/*
 *  Makros.h
 *  iDiary
 *
 *  Created by Markus Konrad on 12.01.11.
 *  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

#import "Tools.h"

#ifndef __MAKROS_H
#define __MAKROS_H

// check if this is ipad2
#define IS_IPAD_2 ([[UIDevice currentDevice].model isEqualToString:@"iPad"] && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])

// random float between x and y
#define RAND_MIN_MAX(x, y) (x + CCRANDOM_0_1() * (y - x))

// Shortcut makro to get a full filepath either from the Document Storage or the AppBundle
#define GET_FILE(x) [Tools getContentFile:(x)]

// free a C++-object
#define FREE_OBJ(x) delete (x); x = NULL;

// free a C++-array of objects
#define FREE_ARRAY(x) delete[] (x); x = NULL;

#endif