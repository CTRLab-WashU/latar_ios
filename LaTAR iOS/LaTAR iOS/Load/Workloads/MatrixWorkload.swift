//
// MatrixWorkload.swift
//
// Copyright (c) 2021 Cognitive Technology Research Laboratory (CTRLab)

import Foundation

public class MatrixWorkload: Workload
{
    private var size:Int32 = 200;
    private var p:mat_params!;
    
    override func setup() {
        self.p = init_matrix(self.size);
    }
    
    override func run() {
        
        matrix_test(self.p);
    }
    
    override func teardown()
    {
        deinit_matrix(self.p);
    }
    
}
