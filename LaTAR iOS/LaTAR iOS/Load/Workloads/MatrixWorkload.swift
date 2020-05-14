//
//  MatrixWorkload.swift
//  LaTAR iOS
//
//  Created by Michael Votaw on 5/13/20.
//  Copyright © 2020 healthyMedium. All rights reserved.
//

import Foundation

public class MatrixWorkload: Workload
{
    private var size:Int = 200;
    private var seed:Int = 0;
    private var val:Int = 0;
    private var A:Array<Int> = [];
    private var B:Array<Int> = [];
    private var C:Array<Int> = [];
    
    override func setup() {
        self.build_matrices();
        self.seed = Int(arc4random());
        self.val = Int(arc4random() % 512);
        self.core_init_matrix(N: size, seed: seed, A: &A, B: &B);
    }
    
    override func run() {
        self.matrix_test(N: size, C: &C, A: &A, B: &B, val: val)
    }
    
    func build_matrices()
    {
        self.A = Array(repeating: 0, count: size * size);
        self.B = Array(repeating: 0, count: size * size);
        self.C = Array(repeating: 0, count: size * size);
    }
    
   func core_init_matrix(N:Int, seed:Int, A: inout Array<Int>,  B: inout Array<Int>) {
        
        var order:Int = 0;
        var val:Int = 0;
        var seed:Int = seed;
        
        for i in 0..<N {
            for j in 0..<N {
                seed = ( ( order * seed ) % 65536 );
                val = (seed + order);
                B[i*N+j] = val;
                val =  (val + order);
                A[i*N+j] = val;
                order += 1;
            }
        }
    }
    
    func matrix_test(N:Int, C:inout Array<Int>, A:inout Array<Int>, B:inout Array<Int>, val:Int) {

        matrix_add_const(N: N,A: &A,val: val); /* make sure data changes  */
        matrix_mul_const(N: N,C: &C,A: &A,val: val);
        matrix_mul_vect(N: N,C: &C,A: &A,B: &B);
        matrix_mul_matrix(N: N,C: &C,A: &A,B: &B);
        matrix_add_const(N: N,A: &A,val: -val); /* return matrix to initial value */
    }

    func matrix_mul_const(N:Int, C:inout Array<Int>, A:inout Array<Int>, val:Int) {
        
        for i in 0..<N {
            for j in 0..<N {
                C[i*N+j] = A[i*N+j] * val;
            }
        }
    }

    func matrix_add_const(N:Int, A:inout Array<Int>, val:Int) {
        
        for i in 0..<N {
            for j in 0..<N {
                A[i*N+j] += val;
            }
        }
    }

    func matrix_mul_vect(N:Int, C:inout Array<Int>, A:inout Array<Int>, B:inout Array<Int>) {

        
        for i in 0..<N {
            C[i]=0;
            for j in 0..<N {
                C[i] += A[i*N+j] * B[j];
            }
        }
    }

    func matrix_mul_matrix(N:Int, C:inout Array<Int>, A:inout Array<Int>, B:inout Array<Int>) {

        for i in 0..<N {
            for j in 0..<N {
                C[i*N+j]=0;
                for k in 0..<N {
                    C[i*N+j] += A[i*N+k] * B[k*N+j];
                }
            }
        }
    }

}
