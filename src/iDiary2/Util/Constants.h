/*
 *  Constants.h
 *  iDiary
 *
 *  Created by Markus Konrad on 22.11.10.
 *  Copyright 2010 INKA Forschungsgruppe. All rights reserved.
 *
 */

// media types:
#define MEDIA_TYPE_PICTURE  0
#define MEDIA_TYPE_AUDIO  1
#define MEDIA_TYPE_VIDEO  2
#define MEDIA_TYPE_TEXT  3
#define MEDIA_TYPE_ANIM  4

// position and size types:
#define POS_TYPE_ABSOLUTE 0
#define POS_TYPE_PERCENT 1

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32