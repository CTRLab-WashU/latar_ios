//
// Data+Hex.swift
//
// Copyright (c) 2021 Cognitive Technology Research Laboratory (CTRLab)

import Foundation

extension Data {

    func hexEncodedString() -> String {
        let format = "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}
