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
