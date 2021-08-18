//
//  StringWithoutQuotes.swift
//  GraphQLBuilderKit
//
//  Created by Mediym on 1/18/21.
//

import Foundation

public extension SingleValueEncodingContainer {
    
    mutating func encodeWithoutQuotes(string: String?) throws {
        guard let string = string else {
            try self.encodeNil()
            return
        }
        
        if let coreSingleValueContainer = self as? CoreSingleValueEncodingContainer {
            coreSingleValueContainer.data.encode(value: string, useQuotes: false)
        } else {
            try encode(string)
        }
        
    }
}

extension String {
    
    var escapedSpecialCharacters: String {
        return replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\t", with: "\\t")
            .replacingOccurrences(of: "\r", with: "\\r")
    }
    
}
