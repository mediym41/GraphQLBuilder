//
//  BuilderQueryParameter.swift
//  GraphQLBuilder
//
//  Created by Vitalii Vasylyda on 21.05.2020.
//  Copyright © 2020 Vitalii Vasylyda. All rights reserved.
//

import Foundation

// In GraphQLOperation declaration `query GraphQLOperation.name($this.key: this.rawType, ...) { ... }`
// In GraphQLField declaration `GraphQLField.name(GraphQLField.variables.key: this.key)`
// In GraphQLBuilder variables declaration `variables: { this.key: this.value }`

public struct GraphQLVariable: Encodable {
    
    public let key: String
    public let value: Encodable
    public let rawType: String
        
    public init(key: String, value: Encodable, rawType: String) {
        self.key = key
        self.value = value
        self.rawType = rawType
    }
    
    public init<T: GraphQLTypeDescription>(key: String, value: Encodable, rawType: T.Type) {
        self.key = key
        self.value = value
        self.rawType = T.asGraphQLTypeDescription
    }
    
    public init<T: GraphQLTypeDescription & Encodable>(key: String, value: T) {
        self.key = key
        self.value = value
        self.rawType = T.asGraphQLTypeDescription
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: FlexibleCodingKey.self)
        let valueEncoder = container.superEncoder(forKey: .init(key: key))
        try value.encode(to: valueEncoder)
    }
    
}
