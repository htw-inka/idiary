//
//  Box2DWorldHolder.m
//  iDiary2
//
//  Created by Markus Konrad on 02.05.11.
//  Copyright 2011 INKA Forschungsgruppe. All rights reserved.
//

#import "Box2DWorldHolder.h"

@interface Box2DWorldHolder(PrivateMethods)
- (b2dWorldAttributes *)createWorldAttribsForType:(b2dWorldType)worldType;
- (b2World *)initWorldOfType:(b2dWorldType)worldType withGravity:(float)gravVal andSetDebugDraw:(GLESDebugDraw **)dbgDraw;
- (b2dWorldAttributes *)getWorldAttribsForType:(b2dWorldType)type;
@end

@implementation Box2DWorldHolder

@synthesize delegate;

#pragma mark init/dealloc

- (id)init {
    self = [super init];
    
    if (self) {
        worlds = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [worlds release];
    
    [super dealloc];
}

#pragma mark public methods

-(void)destroyWorldOfType:(b2dWorldType)worldType {
    b2dWorldAttributes *w = [self getWorldAttribsForType:worldType];
    
    if (w == NULL) {
        return;
    }
    
    if (w->dbgDraw != NULL) {
        delete w->dbgDraw;    // produces EXC_BAD_ACCESS somehow...
        w->dbgDraw = NULL;
    }
    
    if (w->world != NULL) {
        delete w->world;
        w->world = NULL;
    }
    
    [worlds removeObjectForKey:[NSNumber numberWithInt:worldType]];
    
    delete w;
    w = NULL;
}

-(b2dWorldAttributes *)worldAttribsForType:(b2dWorldType)worldType {
    b2dWorldAttributes *w = [self getWorldAttribsForType:worldType];
    
    // return these attributes if we already have an existing world
    if (w != NULL) {
        return w;
    }
    
    // else create the world, save it to the dictionary and return it
    w = [self createWorldAttribsForType:worldType];
    
    [worlds setObject:[NSValue valueWithPointer:w] forKey:[NSNumber numberWithInt:worldType]];
    
    return w;
}

-(void)drawDebugViewForType:(b2dWorldType)worldType {
    b2dWorldAttributes *w = [self getWorldAttribsForType:worldType];
    NSAssert(w != NULL, @"Ups! The b2dWorldAttributes for this type is NULL.");
    
    [self drawDebugViewForAttributes:w];
}

-(void)drawDebugViewForAttributes:(b2dWorldAttributes *)w {
    if (!w) return;

    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
//    glPushMatrix();    
//    
//    glTranslatef(0, 0, 10);
            	
    w->world->DrawDebugData();
    
//    glPopMatrix();
    	
    // restore default GL states
    glEnable(GL_TEXTURE_2D);
    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}

-(void)updateWorldForType:(b2dWorldType)worldType withDeltaTime:(ccTime)dt {
    b2dWorldAttributes *w = [self getWorldAttribsForType:worldType];
    NSAssert(w != NULL, @"Ups! The b2dWorldAttributes for this type is NULL.");
    
    [self updateWorldForAttributes:w withDeltaTime:dt];
}

-(void)updateWorldForAttributes:(b2dWorldAttributes *)w withDeltaTime:(ccTime)dt {
    if (!w) return;

	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
    
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	w->world->Step(dt, velocityIterations, positionIterations);
	
	//Iterate over the bodies in the physics world
	for (b2Body* b = w->world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCNode *myActor = (CCNode*)b->GetUserData();
            
            // pass it to the delegate. the delegate might alter the position value
            CGPoint updatedPos = ccp(b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
            [delegate willUpdateNode:myActor withNewPosition:&updatedPos];
            
            // update the body
            b2Vec2 vec(updatedPos.x/PTM_RATIO, updatedPos.y/PTM_RATIO);
            b->SetTransform(vec, b->GetAngle());
            
            // update the node
			myActor.position = updatedPos;
			myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}	
	}
}

// updates the gravity vector for a world
-(void)updateGravityForType:(b2dWorldType)worldType withX:(float)x andY:(float)y {
    b2dWorldAttributes *w = [self getWorldAttribsForType:worldType];
    NSAssert(w != NULL, @"Ups! The b2dWorldAttributes for this type is NULL.");
    
    if (w->fixedGravity) return;
    
    [self updateGravityForAttributes:w withX:x andY:y];
}

-(void)updateGravityForAttributes:(b2dWorldAttributes *)w withX:(float)x andY:(float)y {
    if (!w) return;

    if (w->gravity == 0.0f || w->fixedGravity) {
        return;
    }

	// accelerometer values are in "Portrait" mode. Change them to Landscape left
    b2Vec2 gravity( -y * w->gravity, x * w->gravity);
    w->world->SetGravity(gravity);
}

#pragma mark private methods
- (b2dWorldAttributes *)getWorldAttribsForType:(b2dWorldType)type {
    NSValue *worldAttribValue = [worlds objectForKey:[NSNumber numberWithInt:type]];
    
    b2dWorldAttributes *worldAttribs;
    
    if (worldAttribValue != nil) {
        worldAttribs = (b2dWorldAttributes *)[worldAttribValue pointerValue];
        return worldAttribs;
    }
    
    return NULL;
}

- (b2dWorldAttributes *)createWorldAttribsForType:(b2dWorldType)worldType {
    b2dWorldAttributes *worldAttribs = new b2dWorldAttributes;
    worldAttribs->dbgDraw = NULL;
    worldAttribs->world = NULL;
    worldAttribs->fixedGravity = NO;
    worldAttribs->worldType = worldType;
    
    // set correct gravity
    switch (worldType) {
        case kB2dWorldTypeTable: {
            worldAttribs->gravity = 0.0f;
            
            break;
        }

        case kB2dWorldTypeDefault:
        default: {
            worldAttribs->gravity = 10.0f;
            
            break;
        }
    }
    
    // create world and debug draw
    worldAttribs->world = [self initWorldOfType:worldType withGravity:worldAttribs->gravity andSetDebugDraw:&worldAttribs->dbgDraw];
    
    // return the complete struct
    return worldAttribs;
}

- (b2World *)initWorldOfType:(b2dWorldType)worldType withGravity:(float)gravVal andSetDebugDraw:(GLESDebugDraw **)dbgDraw {
    CGSize screenSize = [CCDirector sharedDirector].winSize; 
    
    // Define the gravity vector.
    b2Vec2 gravity;
    gravity.Set(0.0f, -gravVal);
    
    // Construct a world object, which will hold and simulate the rigid bodies.
    b2World *world = new b2World(gravity, false);
    
    world->SetContinuousPhysics(true);
    
    // Debug Draw functions
    *dbgDraw = new GLESDebugDraw(PTM_RATIO);
    world->SetDebugDraw(*dbgDraw);
    
    uint32 flags = 0;
    flags += b2Draw::e_shapeBit;
    		flags += b2Draw::e_jointBit;
    		flags += b2Draw::e_aabbBit;
    		flags += b2Draw::e_pairBit;
    		flags += b2Draw::e_centerOfMassBit;
    (*dbgDraw)->SetFlags(flags);		
    
    if (worldType != kB2dWorldTypeNoBorders) {
        // Define the ground body.
        b2BodyDef groundBodyDef;
        groundBodyDef.position.Set(0, 0); // bottom-left corner
        
        // Call the body factory which allocates memory for the ground body
        // from a pool and creates the ground box shape (also from a pool).
        // The body is also added to the world.
        b2Body* groundBody = world->CreateBody(&groundBodyDef);
        
        // Define the ground box shape.
        b2EdgeShape groundBox;		
        
        float yBorderTop = screenSize.height/PTM_RATIO;
        float yBorderBottom = 0;
        
        if (worldType == kB2dWorldTypeBoxing) {
            yBorderTop += screenSize.height/PTM_RATIO;
            yBorderBottom -= screenSize.height/PTM_RATIO;
        }
        
        // bottom
        groundBox.Set(b2Vec2(0,yBorderBottom), b2Vec2(screenSize.width/PTM_RATIO, yBorderBottom));
        groundBody->CreateFixture(&groundBox,0);
        
        // top
        groundBox.Set(b2Vec2(0, yBorderTop), b2Vec2(screenSize.width/PTM_RATIO, yBorderTop));
        groundBody->CreateFixture(&groundBox,0);
        
        // left
        groundBox.Set(b2Vec2(0, yBorderTop), b2Vec2(0, yBorderBottom));
        groundBody->CreateFixture(&groundBox,0);
        
        // right
        groundBox.Set(b2Vec2(screenSize.width/PTM_RATIO, yBorderTop), b2Vec2(screenSize.width/PTM_RATIO, yBorderBottom));
        groundBody->CreateFixture(&groundBox,0);
    }
    
    return world;
}

#pragma mark singleton stuff

static Box2DWorldHolder* sharedObject;

+ (Box2DWorldHolder*)shared {
    if (sharedObject == nil) {
        sharedObject = [[super allocWithZone:NULL] init];
    }
    return sharedObject;    
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self shared] retain];
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

