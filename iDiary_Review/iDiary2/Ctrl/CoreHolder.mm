//
//  CoreHolder.m
//  InterviewStation
//
//  Created by Markus Konrad on 23.03.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "CoreHolder.h"

#import "Tools.h"
#import "Makros.h"
#import "Config.h"
#import "SoundHandler.h"
#import "CommonActions.h"

#ifdef DIARY_LAUNCHER
#import "LauncherLayer.h"
#endif

// Private methods
@interface CoreHolder(PrivateMethods)
#ifndef DIARY_LAUNCHER
// show to an app state with some parameters using a turn direction: -1 is back, +1 is forward, 0 is "no page turn"
- (void)switchToAppState:(appStateType)state usingParameters:(id)params andPageTurn:(int)turnDir;
#endif
@end

@implementation CoreHolder

@synthesize currentPerson;
@synthesize currentPageName;
@synthesize currentPageNum;
@synthesize maxPageNum;
@synthesize currentMainLayer;
@synthesize screenW;
@synthesize screenH;
@synthesize screenCenter;
@synthesize allowPageTurn;
@synthesize curPersonMetaData;
@synthesize interactiveObjectWasTouched;
@synthesize startedFromLauncher;

#pragma mark other NSObject methods

- (id)init {
    self = [super init];
    
    if (self) {
        // init random
        srand(time(NULL));
    
        // set app state
        appState = kAppStateUninitialized;
        
        // show platform
        NSLog(@"Device is iPad2: %d", IS_IPAD_2);
        
        // must be called before any other call to the director
        if( ![CCDirector setDirectorType:kCCDirectorTypeDisplayLink] ) {
            [CCDirector setDirectorType:kCCDirectorTypeMainLoop];
        }
        
        // initialize sound
        [SoundHandler shared];
        
        // set defaults
        director = [CCDirector sharedDirector];
        screenW = [director winSize].width;
        screenH = [director winSize].height;
        screenCenter = ccp(screenW / 2, screenH / 2);
        
        [director setDepthTest:YES];
        
        currentScene = [[CCScene node] retain];
        
        currentPerson = nil;
        currentPageName = nil;
        currentPageNum = 0;
        
        allowPageTurn = YES;
        
        interactiveObjectWasTouched = NO;
        
        scheduledPerson = nil;
        scheduledPageNum = 0;
    }
    
    return self;
}

- (void)dealloc {
    [currentPerson release];
    [currentPageName release];
    
    [currentPageLayer release];
    [otherPageLayer release];

    [currentMainLayer release];
    [currentScene release];
    
    [super dealloc];
}

#pragma mark public messages

- (void)showModalOverlay:(NSString *)overlayFile background:(NSString *)backgroundFile {
    if (currentModalOverlay) return;

    float fadeColor = 255.0f * 0.75f;

    currentModalOverlay = [[ModalOverlay alloc] initWithColor:ccc4(0, 0, 0, fadeColor) width:screenW height:screenH];
    
    [currentModalOverlay setBackgroundImage:backgroundFile];
    [currentModalOverlay setContentImage:overlayFile];
    
    [currentModalOverlay setOpacity:0];
    
    [currentMainLayer addChild:currentModalOverlay];
    [currentMainLayer setIsTouchEnabled:NO];
    
    [CommonActions fadeElement:currentModalOverlay to:fadeColor];
}

- (void)closeModalOverlay {
    CCFiniteTimeAction *fade = [CommonActions fadeActionForElement:currentModalOverlay to:0];
    
    CCCallBlockN *finalAction = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [currentModalOverlay removeFromParentAndCleanup:YES];
        [currentModalOverlay release];
        currentModalOverlay = nil;
        
        [currentMainLayer setIsTouchEnabled:YES];
    }];
    
    [currentModalOverlay runAction:[CCSequence actions:fade, finalAction, nil]];
}


#ifdef DIARY_LAUNCHER

- (void)firstStart {
    NSLog(@"*** Started as Diary Launcher ***");
    
    // create launcher layer as main layer
    LauncherLayer *launcher = [LauncherLayer node];
    currentMainLayer = [launcher retain];
    
    // show the items on the launcher layer
    [launcher show];
    
    // create an empty scene as current scene and at the launcher layer
    currentScene = [[CCScene node] retain];
    [currentScene addChild:launcher];
    
    // run with this scene
    [director runWithScene:currentScene];
}

#else

- (void)switchToDiaryLauncher {
    // go back to the launcher
    NSURL *url = [NSURL URLWithString:@"idiaryLauncher://"];
    [[UIApplication sharedApplication] openURL:url];    
}

- (void)firstStart {
    [self selectedPerson:[[diaryPages allKeys] objectAtIndex:0]];

#ifndef kDbgStartWithPageNum
    NSArray *pageParams = [NSArray arrayWithObject:currentPerson];
    [self switchToAppState:kAppStateStartscreenShowing usingParameters:pageParams andPageTurn:0];
#else
    NSArray *pageParams = [NSArray arrayWithObjects:currentPerson, [NSNumber numberWithInt:kDbgStartWithPageNum] , nil];
    curPersonMetaData = [diaryMetaData objectForKey:currentPerson];
    [self switchToAppState:kAppStatePageShowing usingParameters:pageParams andPageTurn:0];    
#endif
}


- (void)showOverview:(id)sender {
    if (startedFromLauncher) {
        // go back to diary launcher
        [self switchToDiaryLauncher];
    } else {
        // show the desk again
        [self showStartscreen:nil];
    }
}

- (void)showStartscreen:(id)sender {
    // show the desk again
    NSArray *pageParams = [NSArray arrayWithObject:currentPerson];
    [self switchToAppState:kAppStateStartscreenShowing usingParameters:pageParams andPageTurn:0];
}

- (void)showVideo:(NSString *)file {
    if (appState == kAppStatePageShowing) {
        [(PageMainLayer *)currentMainLayer savePageStatus];
    }

    [self switchToAppState:kAppStateVideoPlaying usingParameters:file andPageTurn:0];
}

- (void)showPrevPage:(id)sender {
    if (!allowPageTurn) return;
    
    if (currentPageNum == 0) {
        [self showStartscreen:nil];
        return;
    }
    
    // prevent from turning more than 1 page at a time
    allowPageTurn = NO;   
        
    NSArray *pageParams = [NSArray arrayWithObjects:currentPerson, [NSNumber numberWithInt:(currentPageNum - 1)] , nil];
    [self switchToAppState:kAppStatePageShowing usingParameters:pageParams andPageTurn:-1];
}

- (void)showNextPage:(id)sender {
    if (!allowPageTurn) return;

    if (currentPageNum == maxPageNum) {
        // do nothing
        return;
    }

    // prevent from turning more than 1 page at a time
    allowPageTurn = NO;   

    // border checking for currentPageNum needs to be done in PageLayer
    NSArray *pageParams = [NSArray arrayWithObjects:currentPerson, [NSNumber numberWithInt:(currentPageNum + 1)] , nil];
    [self switchToAppState:kAppStatePageShowing usingParameters:pageParams andPageTurn:1];
}

- (void)selectedPerson:(NSString *)pPerson {
    NSLog(@"Selected person: %@", pPerson);
    
    if (currentPerson != pPerson) {
        [currentPerson release];
        currentPerson = [pPerson retain];
        curPersonMetaData = [diaryMetaData objectForKey:currentPerson];
    }

//    [self switchToAppState:kAppStateStartscreenShowing usingParameters:nil andPageTurn:0];
}

- (void)enterCurrentPersonsDiary {
    currentPageNum = -1;    // will be increased in showNextPage
    [self showNextPage:nil];
}

// return a page name from the diary page at pageNum for the person
- (NSString *)getPageNameAtIndex:(int)pageNum forPerson:(NSString *)person {
    NSArray *personDiary = [diaryPages objectForKey:person];
    NSAssert(personDiary != nil, ([NSString stringWithFormat:@"No diary for person %@ found", person]));
    NSAssert(pageNum >= 0 && pageNum < [personDiary count], @"Invalid pageNum");
    
    return [personDiary objectAtIndex:pageNum];
}

// schedules an action that will be performed after a video has been showed: show this same diary again
- (void)scheduleAfterVideoPlaybackReturnToSameDiary {
    [self scheduleAfterVideoPlaybackPerson:currentPerson andPage:currentPageNum];
}

// schedules an action that will be performed after a video has been showed: show this person on this page
- (void)scheduleAfterVideoPlaybackPerson:(NSString *)pPerson andPage:(int)page {
    scheduledPerson = pPerson;
    scheduledPageNum = page;
}

- (void)videoLayerFinishedPlayback:(NSNotification *)notification { // Apple's MPMoviePlayer somehow sends this notification several times!    
    if (appState == kAppStateVideoPlaying) {
        appState = kAppStateStartscreenShowing;    // Important, because otherwise all this will be called twice which results in a BAD_ACCESS
        
        [(VideoLayer *)currentMainLayer stop];
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
        if (scheduledPerson == nil) {
            [self showOverview:nil];
        } else {
            NSArray *pageParams = [NSArray arrayWithObjects:scheduledPerson, [NSNumber numberWithInt:scheduledPageNum], [NSNumber numberWithBool:YES], nil];
            [self switchToAppState:kAppStatePageShowing usingParameters:pageParams andPageTurn:0];
        }
    }
}

- (void)pageTurnCompleted {
    // check if cache needs to be cleared
    double mem = [CCDirector getAvailableMegaBytes];
    if (mem <= kClearCacheThreshold) {
        NSLog(@"*** OH NO! Only %f MB of memory available -> Clearing Cache!", mem);
        [director purgeCachedData];
    }
    
    // no object touched for now
    interactiveObjectWasTouched = NO;
    
    // re-enable page turn
    allowPageTurn = YES;
}

#pragma mark private messages

- (void)switchToAppState:(appStateType)state usingParameters:(id)params andPageTurn:(int)turnDir {
    // decide whether we really changed the app state
    BOOL switchedState = YES;
    BOOL useFadeTransition = NO;
    
    appStateType previousState = appState;

    if (state == appState) {
        switchedState = NO;
    }

    appState = state;
    
    // do state chance specific actions
    if (state == kAppStateVideoPlaying && previousState == kAppStatePageShowing) {    // switched from page to video -> save the persistent objects
        NSLog(@"switched from page to video -> save the persistent objects");
        persistentPageElements = [((PageMainLayer *)currentMainLayer).persistentPageElements retain];
        [((PageMainLayer *)currentMainLayer).currentPageLayer pageGoneInvisible];
    }
    
    if (switchedState) {
        NSLog(@"Switched AppState, releasing currentMainLayer & removing perform requests for core...");
        [NSObject cancelPreviousPerformRequestsWithTarget:currentMainLayer];
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        
        [currentMainLayer release];
        currentMainLayer = nil;
    }
    
    
    // create new main layer
    switch (state) {
        default:
        case kAppStateUninitialized:
        case kAppStateStartscreenShowing: {
            NSLog(@"Switching to appState: kAppStateStartscreenShowing");
            
            // setup the start screen
            NSArray *meta = [diaryMetaData objectForKey:currentPerson];
            NSAssert(meta != nil, @"No meta data found!");
            CGPoint diaryPos = [[meta objectAtIndex:0] CGPointValue];
            CGPoint disclaimerPos = [[meta objectAtIndex:4] CGPointValue];
            
            currentMainLayer = [StartscreenLayer node];
            [(StartscreenLayer *)currentMainLayer setupForPerson:currentPerson withDiaryPos:diaryPos disclaimerPos:disclaimerPos];
            
            // enable fading
            useFadeTransition = YES;
            
            break;
        }
            
        case kAppStateVideoPlaying: {
            NSLog(@"Switching to appState: kAppStateVideoPlaying");
            
            VideoLayer *videoLayer = [VideoLayer node];
            [videoLayer performSelector:@selector(playVideo:) withObject:params afterDelay:kVideoFadeDuration];
            currentMainLayer = videoLayer;
            
            useFadeTransition = YES;
            
            break;
        }
        
        case kAppStatePageShowing: {
            [currentPerson release];
            
            // get person and page number from param array
            currentPerson = [params objectAtIndex:0];
            currentPageNum = [[params objectAtIndex:1] intValue];
            
            BOOL loadAfterVideoPlayed = NO;
            if ([params count] >= 3) { // optional 3rd param: load page after video was shown?
                loadAfterVideoPlayed = [[params objectAtIndex:2] boolValue];
            }
            
            maxPageNum = [[diaryPages objectForKey:currentPerson] count] - 1;
            NSAssert(maxPageNum >= 0, @"Invalid maxPageNum!");
            
            // get page name from diary
            [currentPageName release];
            currentPageName = [[self getPageNameAtIndex:currentPageNum forPerson:currentPerson] retain];
            
            NSAssert(currentPageName != nil, @"currentPageName could not be set!");
            
            NSLog(@"Switching to appState: kAppStatePageShowing with person %@ on page %d (%@)", currentPerson, currentPageNum, currentPageName);
            
            // load a main layer with a background if this has not been loaded yet
            if (switchedState) {
                useFadeTransition = YES;
                
                currentMainLayer = [PageMainLayer node];
                
                [((PageMainLayer *)currentMainLayer) loadPerson:currentPerson
                                                   withPageName:currentPageName
                                               andOldPageStatus:persistentPageElements];
                
                [((PageMainLayer *)currentMainLayer).currentPageLayer pageTurnComplete];
            } else {
                [((PageMainLayer *)currentMainLayer) navigateInDirection:turnDir];
            }
            
            // switched from video to page -> release the persistent objects
            if (previousState == kAppStateStartscreenShowing && persistentPageElements) {  // video is "kAppStateStartscreenShowing" (see videoLayerFinishedPlayback for explanation)
                NSLog(@"switched from video to page -> load the persistent objects");
                
                [persistentPageElements release];
                persistentPageElements = nil;
            }
                        
            break;
        }
    }
    
    // add the main layer to the main scene
    if (switchedState) {
        [currentScene release];
        currentScene = nil;
    
        currentScene = [[CCScene node] retain];
        [currentScene addChild:currentMainLayer];
        
        [currentMainLayer retain];
            
        // set the new scene
        if ([director runningScene] == nil) {
            [director runWithScene:currentScene];
        } else {
            if (useFadeTransition) {
                CCTransitionFade *sceneTransition = [CCTransitionFade transitionWithDuration:kVideoFadeDuration scene:currentScene withColor:ccBLACK];
                [director replaceScene:sceneTransition];
            } else {
                [director replaceScene:currentScene];
            }
        }
    }
}
#endif


#pragma mark singleton stuff

static CoreHolder* sharedCoreHolder;

+ (CoreHolder*)sharedCoreHolder {
    if (sharedCoreHolder == nil) {
        sharedCoreHolder = [[super allocWithZone:NULL] init];
    }
    return sharedCoreHolder;    
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedCoreHolder] retain];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}


@end
