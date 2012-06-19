//
//  PageElementPersistency.h
//  iDiary2
//
//  Created by Markus Konrad on 13.07.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PageElementPersistencyProtocol <NSObject>
-(id)saveElementStatus;
-(void)loadElementStatus:(id)saveData;
-(NSString *)getIdentifer;
@end

@interface PersistentPageElement : NSObject {
    NSString *identifier;
    id<PageElementPersistencyProtocol> element; // the element that handles loading / saving. retained
    NSObject *data;    // the saved data or nil. retained
}

@property (nonatomic,readonly) NSString *identifier;
@property (nonatomic,readonly) id<PageElementPersistencyProtocol> element;
@property (nonatomic,readonly) id data;

-(id)initElement:(id<PageElementPersistencyProtocol>) pElement withIdentifier:(NSString *)ident;

-(void)save;

-(void)load;

-(void)clear;

@end
