//
//  BuilderQueryParameter.swift
//  GraphQLBuilder
//
//  Created by Vitalii Vasylyda on 21.05.2020.
//  Copyright © 2020 Vitalii Vasylyda. All rights reserved.
//

import Foundation

public struct GraphQLVariable {
    
    public let key: String
    public let value: GraphQLParameterValue
    public let rawType: String
    
    public init(key: String, value: GraphQLParameterValue, rawType: String) {
        self.key = key
        self.value = value
        self.rawType = rawType
    }
    
    public init<T: GraphQLTypeDescription>(key: String, value: GraphQLParameterValue, rawType: T.Type) {
        self.key = key
        self.value = value
        self.rawType = T.asGraphQLTypeDescription
    }
    
}
