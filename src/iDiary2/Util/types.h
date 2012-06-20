// Copyright (c) 2012, HTW Berlin / Project HardMut
// (http://www.hardmut-projekt.de)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//
// * Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright
//   notice, this list of conditions and the following disclaimer in the
//   documentation and/or other materials provided with the distribution.
// * Neither the name of the HTW Berlin / INKA Research Group nor the names
//   of its contributors may be used to endorse or promote products derived
//   from this software without specific prior written permission.

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
// IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
// THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
/*
 *  types.h
 *  OBJPresenter
 *
 *  Created by Michael Witt on 09.10.10.
 *  Copyright 2010 Hello IT GbR. All rights reserved.
 *
 */

#pragma mark Mathematical helper functions

#define DEG_TO_RAD(x) (x * 0.017453292519943295)
#define RAD_TO_DEG(x) (x * 57.295779513082323)

/**
 * Calculate the inverse square root by famous Quake fast inverse square root algorithm
 * @param x Value to calculate sqrt for
 * @return result
 */
static inline float fastInverseSqrt(float x) {
	float xhalf = 0.5f * x;
	int i = *(int*)&x;			// store floating-point bits in integer
	i = 0x5f3759d5 - (i >> 1);		// initial guess for Newton's method
	x = *(float*)&i;				// convert new bits into float
	x = x*(1.5f - xhalf*x*x);		// One round of Newton's method
	
	return x;
}

/**
 * Calculate the square root by famous Quake fast inverse square root algorithm
 * @param x Value to calculate sqrt for
 * @return result
 */
static inline float fastSqrt(float x) {
	float invSqrt = fastInverseSqrt(x);
	return (invSqrt == 0.0f) ? 0.0 : 1.0f / invSqrt;
}


#pragma mark RGBA color utils

// Main struct holding color information for each channel as float
typedef struct _ColorRGBA {
	float	r;
	float	g;
	float	b;
	float a;
} ColorRGBA;

/**
 * Helper function to create a rgba color struct
 * @param r, g, b, a Color values
 * @return New color struct
 */
static inline ColorRGBA ColorRGBAMake(float r, float g, float b, float a) {
	// Assign result
    ColorRGBA result = { r, g, b, a };
    return result;
}

#pragma mark 2 dimensional texture utils

// Main struct holding position information of the texture coordinate
typedef struct _TexCoord2D {
	float u;
	float v;
} TexCoord2D;

/**
 * Helper function to create a texture coordinate struct
 * @param u, v coordinate values
 * @return New texture struct
 */
static inline TexCoord2D TexCoord2DMake(float u, float v) {
	// Assign result
    TexCoord2D result = { u, v };
    return result;
}

#pragma mark 3 dimensional vector utils

// Main struct holding position information of the vector
typedef struct _Vector3D {
	float x;
	float y;
	float z;
} Vector3D;

/**
 * Helper function to create a vector struct
 * @param x, y, z coordinate values
 * @return New vector struct
 */
static inline Vector3D Vector3DMake(float x, float y, float z) {
	// Assign result
    Vector3D result = { x, y, z };
    return result;
}

/**
 * Return the length of the specified vector
 * @param v Vector to determine the length for
 * @return Vector length
 */
static inline float Vector3DLength(const Vector3D* v) {
	return fastSqrt(v->x * v->x + v->y * v->y + v->z * v->z);
}

/**
 * Normalize the specified vector (length of 1.0)
 * @param v Vector to normalize
 * @return Pointer to v
 */
static inline Vector3D* Vector3DNormalize(Vector3D* v) {
	// Get the vector length
	float length = fastInverseSqrt(v->x * v->x + v->y * v->y + v->z * v->z);
	
	// If v is of length zero, the normalized version will be the x unit vector
	if (length == 0.0) {
		v->x = 1.0;
		v->y = 0.0;
		v->z = 0.0;
	} else {
		v->x *= length;
		v->y *= length;
		v->z *= length;
	}
	
	return v;
}

/**
 * Invert the specified vector
 * @param v Vector to invert
 * @return Pointer to v
 */
static inline Vector3D* Vector3DInvert(Vector3D* v) {
	v->x = -v->x;
	v->y = -v->y;
	v->z = -v->z;
	
	return v;
}

/**
 * Calculate the addition result of two 3d vectors
 * @param v1, v2 Vectors to add with each other
 * @return result vector
 */
static inline Vector3D Vector3DAdd(const Vector3D* v1, const Vector3D* v2) {
	return Vector3DMake(v1->x + v2->x, v1->y + v2->y, v1->z + v2->z);
}

/**
 * Calculate the substraction result of two 3d vectors
 * @param v1, v2 Vectors to substract with each other
 * @return result vector
 */
static inline Vector3D Vector3DSubstract(const Vector3D* v1, const Vector3D* v2) {
	return Vector3DMake(v1->x - v2->x, v1->y - v2->y, v1->z - v2->z);
}

/**
 * Calculate the dot product for a vector and a scalar value
 * @param v Vector to multiply
 * @param c Scalar value
 * @return Resulting vector
 */
static inline Vector3D Vector3DScalarMultiply(const Vector3D* v, float c) {
	return Vector3DMake(v->x * c, v->y * c, v->z * c);
}

/**
 * Calculate the dot product for two vectors
 * @param v1, v2 Vectors to dot multiply with each other
 * @return Vector dot product
 */
static inline float Vector3DDotProduct(const Vector3D* v1, const Vector3D* v2) {		
	return v1->x * v2->x + v1->y * v2->y + v1->z * v2->z;
}

/**
 * Calculate the cross product for two vectors
 * @param v1, v2 Vectors to build the cross product for
 * @return Vector cross product
 */
static inline Vector3D Vector3DCrossProduct(const Vector3D* v1, const Vector3D* v2) {
	return Vector3DMake(
		(v1->y * v2->z) - (v1->z * v2->y),
		(v1->z * v2->x) - (v1->x * v2->z),
		(v1->x * v2->y) - (v1->y * v2->x) );
}

// Multiply the matrix with a 3D vector
static inline Vector3D Vector3DMultiplyMatrix4x4(const Vector3D* v, const float* m) {
	return Vector3DMake(
		v->x * m[0] + v->y * m[1] + v->z * m[2],
		v->x * m[4] + v->y * m[5] + v->z * m[6],
		v->x * m[8] + v->y * m[9] + v->z * m[10] );
}

#pragma mark 3 dimensional point utils

// The Vertex3D structure will be pulled down to the Vector3D type
typedef Vector3D Vertex3D;
#define Vertex3DMake(x, y, z) (Vertex3D) Vector3DMake(x, y, z)

/**
 * Create a vector the reaches from the specified start point to the 
 * specified end point
 * @param start, end Start and end point
 * @return result vector
 */
static inline Vector3D Vector3DMakeWithStartAndEndPoints(const Vertex3D* start, const Vertex3D* end) {
	return Vector3DSubstract(end, start);
}

#pragma mark 3 dimensional rotation utils

// The Rotation3D structure will be pulled down to the Vector3D type
typedef Vector3D Rotation3D;
#define Rotation3DMake(x, y, z) (Rotation3D) Vector3DMake(x, y, z)

#pragma mark 3 dimensional triangle utils

// Main struct holding information for each vertex of the triangle
typedef struct _Triangle3D {
	Vertex3D v1;
	Vertex3D v2;
	Vertex3D v3;
} Triangle3D;

/**
 * Helper function to create a triangle struct
 * @param v1, v2, v3 Vertex coordinates of the triangle
 * @return New triangle struct
 */
static inline Triangle3D Triangle3DMake(Vertex3D v1, Vertex3D v2, Vertex3D v3) {
	Triangle3D result = { v1, v2, v3 };
	return result;
}
										
/**
 * Calculate the surface normal for the specified triangle
 * @param triangle Triangle to calculate the surface normal for
 * @return Vector representing the surface normal
 */
static inline Vector3D Triangle3DSurfaceNormal(const Triangle3D* triangle){
	Vector3D u = Vector3DMakeWithStartAndEndPoints(&(triangle->v2), &(triangle->v1));
	Vector3D v = Vector3DMakeWithStartAndEndPoints(&(triangle->v3), &(triangle->v1));
			
	return Vector3DCrossProduct(Vector3DNormalize(&u), Vector3DNormalize(&v));
}

#pragma mark Frustum struct

// Main struct holding information for each the view frustum
typedef struct _Frustum3D {
	float zNear;
	float zFar;
	float xLeft;
	float xRight;
	float yUp;
	float yDown;
} Frustum3D;