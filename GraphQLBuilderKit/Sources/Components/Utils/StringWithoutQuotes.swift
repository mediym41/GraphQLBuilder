//
//  StringWithoutQuotes.swift
//  
//
//  Created by Дмитрий Пащенко on 19.04.2021.
//

public struct StringWithoutQuotes: Encodable {
    let value: String
    
    public init(value: String) {
        self.value = value
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeWithoutQuotes(string: value)
    }
}

public extension String {
    
     var withoutQuotes: StringWithoutQuotes {
        return StringWithoutQuotes(value: self)
    }
    
}
