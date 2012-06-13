//
//  Diaries_Alice.h
//  iDiary2
//
//  Created by Markus Konrad on 06.06.12
//  Copyright 2012 INKA Forschungsgruppe. All rights reserved.
//

// These Arrays define the pages
static NSArray *diaryAlice = [NSArray arrayWithObjects:
    @"Intro",            // 0
    @"Example2",         // 1
    @"Example3",         // 2
    @"Example4",         // 3
    @"Example5",         // 4
    @"Example6",         // 5
    @"Example7",         // 6
    @"Example8",         // 7
    nil];
   
// This dictionary associates the diary-arrays with the persons
static NSDictionary *diaryPages = [NSDictionary dictionaryWithObjectsAndKeys:
    diaryAlice, @"Alice",
    nil];

// These Arrays define meta data for diaries, such as the position of the diary in the startscreen, page offset, anim corner size
static NSArray *metaDataAlice = [NSArray arrayWithObjects:
    [NSValue valueWithCGPoint:ccp(395, 768-417)],       // position of the diary in the startscreen
    [NSValue valueWithCGPoint:ccp(-1.5, 0)],            // page offset
    [NSValue valueWithCGSize:CGSizeMake(242, 200)],     // page corner animation size
    [NSValue valueWithCGPoint:ccp(-1, 1)],              // page corner offset
    [NSValue valueWithCGPoint:ccp(945, 768-725)],       // disclamer coordinates
    nil];

// This dictionary associates the diary-metadata-arrays with the persons    
static NSDictionary *diaryMetaData = [NSDictionary dictionaryWithObjectsAndKeys:
    metaDataAlice, @"Alice",
    nil];    

// global settings
static NSMutableDictionary *globalSettings = [NSMutableDictionary dictionaryWithObjectsAndKeys:
    [NSNumber numberWithBool:NO], @"controlElemShown",
    nil]; 
