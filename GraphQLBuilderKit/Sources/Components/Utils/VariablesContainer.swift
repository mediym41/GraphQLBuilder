//
//  VariablesContainer.swift
//  
//
//  Created by Дмитрий Пащенко on 19.04.2021.
//

import Foundation

public struct VariablesContainer: Encodable {
    public init(variables: [GraphQLVariable]) {
        self.variables = variables
    }
    
    public var variables: [GraphQLVariable]
    
    public func encode(to encoder: Encoder) throws {
        for variable in variables {
            try variable.encode(to: encoder)
        }
    }
}
