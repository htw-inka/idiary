//
//  CCGestureRecognizer.h
//  cocos
//
//  Created by Joe Allen on 7/11/10.
//  Copyright 2010 Glaiveware LLC. All rights reserved.
//

#import "ccTypes.h"
#import "CCNode.h"
#import <UIKit/UIKit.h>

#ifndef __CCGestureRecognizer_H__
#define __CCGestureRecognizer_H__

@class CCNode;

@interface CCGestureRecognizer : NSObject <UIGestureRecognizerDelegate,NSCoding>
{
      UIGestureRecognizer* gestureRecognizer_;
      CCNode* node_;
      
      id<UIGestureRecognizerDelegate> delegate_;
      
      id target_;
      SEL callback_;
    }

@property(nonatomic,readonly) UIGestureRecognizer* gestureRecognizer;
@property(nonatomic,assign) CCNode* node;
@property(nonatomic,assign) id<UIGestureRecognizerDelegate> delegate;
@property(nonatomic,assign) id target;
@property(nonatomic,assign) SEL callback;

- (id) initWithRecognizerTargetAction:(UIGestureRecognizer*)gestureRecognizer target:(id)target action:(SEL)action;
+ (id) CCRecognizerWithRecognizerTargetAction:(UIGestureRecognizer*)gestureRecognizer target:(id)target action:(SEL)action;

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;

// this is the function the gesture recognizer will callback and we will add our info onto it
- (void) callback:(UIGestureRecognizer*)recognizer;
@end

#endif  // end of __CCGestureRecognizer_H__