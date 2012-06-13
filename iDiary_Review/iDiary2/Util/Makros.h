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