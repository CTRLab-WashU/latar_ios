//
//  matrix_math.h
//  LaTAR iOS
//
//  Created by Michael Votaw on 5/14/20.
//  Copyright © 2020 healthyMedium. All rights reserved.
//

#ifndef matrix_math_h
#define matrix_math_h

#include <stdio.h>
typedef float MAT_TYPE;

typedef struct MAT_PARAMS_S {
    int N;
    MAT_TYPE *A;
    MAT_TYPE *B;
    MAT_TYPE *C;
    MAT_TYPE *vector;
} mat_params;


mat_params init_matrix(int N);
void deinit_matrix(mat_params p);
void reset_matrix(int N, MAT_TYPE *matrix);
void matrix_test(mat_params p);
void matrix_mul_const( int N, MAT_TYPE *A, int val);
void matrix_mul_vect(int N, MAT_TYPE *A, MAT_TYPE *B);
void matrix_mul_matrix(int N, MAT_TYPE *A, MAT_TYPE *B);
void matrix_add_const(int N, MAT_TYPE *A, int val);
void matrix_add_matrix(int N, MAT_TYPE *A, MAT_TYPE *C);
#endif /* matrix_math_h */
