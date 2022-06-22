//
//  StringWithoutQuotes.swift
//  GraphQLBuilderKit
//
//  Created by Mediym on 1/19/21.
//

@testable
import GraphQLBuilderKit_v2

/// Special type for flexible encoding string literals, used only for tests
public struct StringWithoutQuotes: Encodable {
    
    var value: String?
    
    init(_ value: String?) {
        self.value = value
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeWithoutQuotes(string: value)
    }
    
}
