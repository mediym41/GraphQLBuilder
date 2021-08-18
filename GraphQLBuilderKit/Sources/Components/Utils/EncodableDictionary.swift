//
//  EncodableDicitonary.swift
//  
//
//  Created by Дмитрий Пащенко on 19.04.2021.
//

public struct EncodableDictionary: Encodable {
    
    var data: [String: Encodable]
    
    public init(data: [String: Encodable] = [:]) {
        self.data = data
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: FlexibleCodingKey.self)
        
        for (key, value) in data {
            let superEncoder = container.superEncoder(forKey: .init(key: key))
            try value.encode(to: superEncoder)
        }
    }
}

extension EncodableDictionary: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, Encodable)...) {
        self = .init()
        
        for (key, value) in elements {
            data[key] = value
        }
    }
}

extension Dictionary where Key == String, Value == Encodable {
    
    public var asEncodable: EncodableDictionary {
        return .init(data: self)
    }
    
}
