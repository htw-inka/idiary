//
//  AppDelegate.h
//  iDiary2
//
//  Created by Markus Konrad on 27.04.11.
//  Copyright INKA Forschungsgruppe 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
