//
//  PageElementPersistency.m
//  iDiary2
//
//  Created by Markus Konrad on 13.07.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "PageElementPersistency.h"


@implementation PersistentPageElement

@synthesize identifier;
@synthesize element;
@synthesize data;

-(id)initElement:(id<PageElementPersistencyProtocol>) pElement withIdentifier:(NSString *)ident {
    if ((self = [super self])) {
        identifier = [ident retain];
        element = [pElement retain];
        data = nil;
    }
    
    return self;
}

-(void)dealloc {
    [identifier release];
    [element release];
    [data release];
    
    [super dealloc];
}

-(void)save {
    [self clear];
    data = [[element saveElementStatus] retain];
}

-(void)load {
    return [element loadElementStatus:data];
}

-(void)clear {
    [data release];
    data = nil;
}

@end
