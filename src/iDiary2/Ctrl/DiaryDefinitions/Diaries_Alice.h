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
//  Diaries_Alice.h
//  iDiary2
//
//  Created by Markus Konrad on 06.06.12
//  Copyright 2012 INKA Forschungsgruppe. All rights reserved.
//

// These Arrays define the pages
static NSArray *diaryAlice = [[NSArray arrayWithObjects:
    @"Intro",            // 0
    @"Example2",         // 1
    @"Example3",         // 2
    @"Example4",         // 3
    @"Example5",         // 4
    @"Example6",         // 5
    @"Example7",         // 6
    @"Example8",         // 7
    @"Example9",         // 7
    nil] retain];
   
// This dictionary associates the diary-arrays with the persons
static NSDictionary *diaryPages = [[NSDictionary dictionaryWithObjectsAndKeys:
    diaryAlice, @"Alice",
    nil] retain];

// These Arrays define meta data for diaries, such as the position of the diary in the startscreen, page offset, anim corner size
static NSArray *metaDataAlice = [[NSArray arrayWithObjects:
    [NSValue valueWithCGPoint:ccp(395, 768-417)],       // position of the diary in the startscreen
    [NSValue valueWithCGPoint:ccp(-1.5, 0)],            // page offset
    [NSValue valueWithCGSize:CGSizeMake(242, 200)],     // page corner animation size
    [NSValue valueWithCGPoint:ccp(-1, 1)],              // page corner offset
    [NSValue valueWithCGPoint:ccp(0, 0)],       // disclamer coordinates
    nil] retain];

// This dictionary associates the diary-metadata-arrays with the persons    
static NSDictionary *diaryMetaData = [[NSDictionary dictionaryWithObjectsAndKeys:
    metaDataAlice, @"Alice",
    nil] retain];
