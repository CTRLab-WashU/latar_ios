//
//  Data+Hex.swift
//  LaTAR iOS
//
//  Created by Michael Votaw on 1/20/20.
//  Copyright © 2020 healthyMedium. All rights reserved.
//

import Foundation

extension Data {

    func hexEncodedString() -> String {
        let format = "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}
