//
//  matrix_math.c
//  LaTAR iOS
//
//  Created by Michael Votaw on 5/14/20.
//  Copyright © 2020 healthyMedium. All rights reserved.
//

#include "matrix_math.h"
#include <stdlib.h>

mat_params init_matrix(int N)
{
    mat_params p;
    p.N = N;
    
    p.A = malloc(sizeof(MAT_TYPE) * N * N);
    p.B = malloc(sizeof(MAT_TYPE) * N * N);
    p.C = malloc(sizeof(MAT_TYPE) * N * N);
    p.vector = malloc(sizeof(MAT_TYPE) * N);
    
    for (int i=0; i<N; i++)
    {
        for (int j=0; j<N; j++)
        {
            p.A[i*N+j] = 0;
            p.B[i*N+j] = i * j;
            p.C[i*N+j] = 3.14159;
        }
        p.vector[i] = N - i;
    }
    
    return p;
}

void deinit_matrix(mat_params p)
{
    free(p.A);
    free(p.B);
    free(p.C);
    free(p.vector);
}

void reset_matrix(int N, MAT_TYPE * mat)
{
    for(int i = 0; i < N; i++)
    {
        for (int j = 0; j < N; j++)
        {
            mat[i*N + j] = 0;
        }
    }
}

void matrix_test(mat_params p)
{
    int N = p.N;
    MAT_TYPE *A = p.A;
    MAT_TYPE *B = p.B;
    MAT_TYPE *C = p.C;
    
    reset_matrix(N, A);
    matrix_add_matrix(N, A, C);
    
    matrix_mul_const(N,A,13.2);
    matrix_mul_vect(N,A,p.vector);
    matrix_mul_matrix(N,A,B);
    matrix_add_matrix(N, A, C);
    matrix_add_const(N,A,-3.14159);
}


void matrix_mul_const(int N, MAT_TYPE *A, int val) {
    int i,j;
    for (i=0; i<N; i++) {
        for (j=0; j<N; j++) {
            A[i*N+j] = A[i*N+j] * (MAT_TYPE)val;
        }
    }
}

void matrix_add_const(int N, MAT_TYPE *A, int val) {
    int i,j;
    for (i=0; i<N; i++) {
        for (j=0; j<N; j++) {
            A[i*N+j] += val;
        }
    }
}

void matrix_mul_vect(int N, MAT_TYPE *A, MAT_TYPE *vector) {
    int i,j;
    for (i=0; i<N; i++) {
        for (j=0; j<N; j++) {
            A[i*N+j] = A[i*N+j] * (MAT_TYPE)vector[j];
        }
    }
}

void matrix_mul_matrix(int N, MAT_TYPE *A, MAT_TYPE *B) {
    
    MAT_TYPE d = 0;
    for (int i=0; i<N; i++) {
        for (int j=0; j<N; j++) {
            d = 0;
            for(int k=0;k<N;k++)
            {
                d+=(MAT_TYPE)A[i*N+k] * B[k*N+j];
            }
        }
    }
}

void matrix_add_matrix(int N, MAT_TYPE *A, MAT_TYPE *C)
{
    for(int i = 0; i < N; i++)
    {
        for (int j = 0; j < N; j++)
        {
            A[i*N + j] += C[i*N + j];
        }
    }
}

