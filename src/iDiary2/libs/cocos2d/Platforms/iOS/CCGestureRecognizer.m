//
//  CCGestureRecognizer.m
//  cocos
//
//  Created by Joe Allen on 7/11/10.
//  Copyright 2010 Glaiveware LLC. All rights reserved.
//

#import "CCGestureRecognizer.h"
#import "CCDirector.h"
#import "ccMacros.h"
#import "CGPointExtension.h"

@implementation CCGestureRecognizer

-(void)dealloc
{
      CCLOGINFO( @"cocos2d: deallocing %@", self); 
      [gestureRecognizer_ release];
      [super dealloc];
    }

- (UIGestureRecognizer*)gestureRecognizer
{
      return gestureRecognizer_;
    }

- (CCNode*)node
{
      return node_;
    }

- (void)setNode:(CCNode*)node
{
      node_ = node;
    }

- (id<UIGestureRecognizerDelegate>)delegate
{
      return delegate_;
    }

- (void) setDelegate:(id<UIGestureRecognizerDelegate>)delegate
{
      delegate_ = delegate;
    }

- (id)target
{
      return target_;
    }

- (void)setTarget:(id)target
{
      target_ = target;
    }

- (SEL)callback
{
      return callback_;
    }

- (void)setCallback:(SEL)callback
{
      callback_ = callback;
    }

- (id)initWithRecognizerTargetAction:(UIGestureRecognizer*)gestureRecognizer target:(id)target action:(SEL)action
{
      if( (self=[super init]) )
          {
                assert(gestureRecognizer != NULL && "gesture recognizer must not be null");
                gestureRecognizer_ = gestureRecognizer;
                [gestureRecognizer_ retain];
                [gestureRecognizer_ addTarget:self action:@selector(callback:)];
                
                // setup our new delegate
                delegate_ = gestureRecognizer_.delegate;
                gestureRecognizer_.delegate = self;
                
                target_ = target; // weak ref
                callback_ = action;
              }
      return self;
    }

+ (id)CCRecognizerWithRecognizerTargetAction:(UIGestureRecognizer*)gestureRecognizer target:(id)target action:(SEL)action
{
      return [[[self alloc] initWithRecognizerTargetAction:gestureRecognizer target:target action:action] autorelease];
    }

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
      assert( node_ != NULL && "gesture recognizer must have a node" );
        
      CGPoint pt = [[CCDirector sharedDirector] convertToGL:[touch locationInView: [touch view]]];
      /* do a rotation opposite of the node to see if the point is in it
             it should make it easier to check against an aligned object */
      
      BOOL rslt = [node_ isPointInArea:pt];
      // TODO: we might want to think about adding this first check back in.
     
      // leaving this out lets a node and its children share a touch if the
      // touch are overlaps. two nodes overlapping on a scene though would
      // not both get the touch.
      
      
      if( rslt )
          {
                /*  ok we know this node was touched, but now we need to make sure
                          no other node above this one was touched -- this check only includes
                          nodes that receive touches */
                
                // first is to check children
                CCNode* n;
                /*CCARRAY_FOREACH(node_.children, node)
                      {
                        if( [node isNodeInTreeTouched:pt] )
                        {
                          rslt = NO;
                          break;
                        }
                      }*/
                
                // ok, still ok, now check children of parents after this node
                n = node_;
                CCNode* parent = node_.parent;
                while( n != nil && rslt)
                    {
                          CCNode* child;
                          BOOL nodeFound = NO;
                          CCARRAY_FOREACH(parent.children, child)
                          {
                                if( !nodeFound )
                                {
                                    if( !nodeFound && n == child )
                                        nodeFound = YES;  // we need to keep track of until we hit our node, any past it have a higher z value
                                    continue;
                                }
                                
                                if( [child isNodeInTreeTouched:pt] )
                                {
                                    rslt = NO;
                                    break;
                                }
                              }
                          
                          n = parent;
                          parent = n.parent;
                        }    
              }
      
      if( rslt && delegate_ && [delegate_ respondsToSelector:@selector(gestureRecognizer:shouldReceiveTouch:)] )
            rslt = [delegate_ gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
      
      return rslt;
    }

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
      if( delegate_ && [delegate_ respondsToSelector:@selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)] )
            return [delegate_ gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
      return YES;
    }

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
      if( delegate_ && [delegate_ respondsToSelector:@selector(gestureRecognizerShouldBegin:)] )
            return [delegate_ gestureRecognizerShouldBegin:gestureRecognizer];
      return YES;
    }

- (void)callback:(UIGestureRecognizer*)recognizer
{
      if( target_ )
            [target_ performSelector:callback_ withObject:recognizer withObject:node_];
    }

- (void)encodeWithCoder:(NSCoder *)coder 
{
      [coder encodeObject:gestureRecognizer_ forKey:@"gestureRecognizer"];
      [coder encodeObject:node_ forKey:@"node"];
      [coder encodeObject:delegate_ forKey:@"delegate"];
      [coder encodeObject:target_ forKey:@"target"];
      // TODO: callback_
      [coder encodeBytes:(uint8_t*)&callback_ length:sizeof(callback_) forKey:@"callback"];
    }

- (id)initWithCoder:(NSCoder *)decoder 
{
      self=[self init];
      if (self) 
          {
                // don't retain node, it will retain this
                node_     = [decoder decodeObjectForKey:@"node"];          // weak ref
                delegate_ = [decoder decodeObjectForKey:@"delegate"];  // weak ref
                target_   = [decoder decodeObjectForKey:@"target"];      // weak ref
                // TODO: callback_
                NSUInteger len;
                const uint8_t * buffer = [decoder decodeBytesForKey:@"callback" returnedLength:&len];
                // sanity check to make sure our length is correct
                if( len == sizeof(callback_) )
                      memcpy(&callback_, buffer, len);
               
                gestureRecognizer_ = [decoder decodeObjectForKey:@"gestureRecognizer"];
                [gestureRecognizer_ addTarget:self action:@selector(callback:)];
                
                gestureRecognizer_.delegate = self;
                [gestureRecognizer_ retain];
              }
      return self;
    }

- (NSString*) description
{
    	return [NSString stringWithFormat:@"<%@ = %08X | %@ | Node = %@ >", [self class], self, [gestureRecognizer_ class], node_];
    }

@end
#pragma mark NSCoding of built in recognizers

@implementation UIRotationGestureRecognizer(NSCoder)
- (void)encodeWithCoder:(NSCoder *)coder 
{}

- (id)initWithCoder:(NSCoder *)decoder 
{
      self=[self init];
      if (self) 
          {}
      return self;
    }
@end

@implementation UITapGestureRecognizer(NSCoder)
- (void)encodeWithCoder:(NSCoder *)coder 
{
      [coder encodeInt:self.numberOfTapsRequired forKey:@"numberofTapsRequired"];
      [coder encodeInt:self.numberOfTouchesRequired forKey:@"numberOfTouchesRequired"];
    }

- (id)initWithCoder:(NSCoder *)decoder 
{
      self=[self init];
      if (self) 
          {
                self.numberOfTapsRequired = [decoder decodeIntForKey:@"numberOfTapsRequired"];
                self.numberOfTouchesRequired = [decoder decodeIntForKey:@"numberOfTouchesRequired"];
              }
      return self;
    }
@end

@implementation UIPanGestureRecognizer(NSCoder)
- (void)encodeWithCoder:(NSCoder *)coder 
{
      [coder encodeInt:self.minimumNumberOfTouches forKey:@"minimumNumberOfTouches"];
      [coder encodeInt:self.maximumNumberOfTouches forKey:@"maximumNumberOfTouches"];
    }

- (id)initWithCoder:(NSCoder *)decoder 
{
      self=[self init];
      if (self) 
          {
                self.minimumNumberOfTouches = [decoder decodeIntForKey:@"minimumNumberOfTouches"];
                self.maximumNumberOfTouches = [decoder decodeIntForKey:@"maximumNumberOfTouches"];
              }
      return self;
    }
@end

@implementation UILongPressGestureRecognizer(NSCoder)
- (void)encodeWithCoder:(NSCoder *)coder 
{
      [coder encodeInt:self.numberOfTapsRequired forKey:@"numberOfTapsRequired"];
      [coder encodeInt:self.numberOfTouchesRequired forKey:@"numberOfTouchesRequired"];
      [coder encodeDouble:self.minimumPressDuration forKey:@"minimumPressDuration"];
      [coder encodeFloat:self.allowableMovement forKey:@"allowableMovement"];
    }

- (id)initWithCoder:(NSCoder *)decoder 
{
      self=[self init];
      if (self) 
          {
                self.numberOfTapsRequired = [decoder decodeIntForKey:@"numberOfTapsRequired"];
                self.numberOfTouchesRequired = [decoder decodeIntForKey:@"numberOfTouchesRequired"];
                self.minimumPressDuration = [decoder decodeDoubleForKey:@"minimumPressDuration"];
                self.allowableMovement = [decoder decodeFloatForKey:@"allowableMovement"];
              }
      return self;
    }
@end

@implementation UISwipeGestureRecognizer(NSCoder)
- (void)encodeWithCoder:(NSCoder *)coder 
{
      [coder encodeInt:self.numberOfTouchesRequired forKey:@"numberOfTouchesRequired"];
      [coder encodeInt:self.direction forKey:@"direction"];
    }

- (id)initWithCoder:(NSCoder *)decoder 
{
      self=[self init];
      if (self) 
          {
                self.numberOfTouchesRequired = [decoder decodeIntForKey:@"numberOfTouchesRequired"];
                self.direction = (UISwipeGestureRecognizerDirection)[decoder decodeIntForKey:@"direction"];
              }
      return self;
    }
@end

@implementation UIPinchGestureRecognizer(NSCoder)
- (void)encodeWithCoder:(NSCoder *)coder 
{
    }

- (id)initWithCoder:(NSCoder *)decoder 
{
      self=[self init];
      if (self) 
          {
              }
      return self;
    }
@end