//
//  String+Extensions.swift
//  
//
//  Created by d.pashchenko on 16/07/2021.
//

import Foundation

extension String {
    
    func preparedForCompare() -> String {
        return self
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .sorted()
            .reduce("", { $0 + String($1) })
    }
    
}
