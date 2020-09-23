//
//  GraphQLBuilder.swift
//  Prom Покупки
//
//  Created by v.vasylyda on 21.05.2020.
//  Copyright © 2020 UAProm. All rights reserved.
//

import Foundation

fileprivate enum GraphQLConstants: String {
    case query = "query"
    case operationName = "operationName"
    case variables = "variables"
}

public struct GraphQLBuilder {
    @discardableResult public static func buildDictionary(operation: GraphQLOperation) -> [String: Any] {
        var dictionary: [String: Any] = [GraphQLConstants.query.rawValue: operation.asGraphQLBuilderString]
        
        if let alias = operation.alias {
            dictionary[GraphQLConstants.operationName.rawValue] = alias
        }
        
        if !operation.variables.isEmpty {
            var variables: [String: Any] = [:]
            
            for variable in operation.variables {
                variables[variable.key] = variable.value.asGraphQLEncodableValue
            }
            
            dictionary[GraphQLConstants.variables.rawValue] = variables
        }
        
        return dictionary
    }
    
    @discardableResult public static func build(operation: GraphQLOperation) throws -> String {
        do {
            let dictionary = buildDictionary(operation: operation)
            
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            
            guard let string = String(bytes: jsonData, encoding: String.Encoding.utf8) else {
                throw GraphBuilderError.error(for: .stringFromDictSerializationFailed)
            }
            
            return string
            
        } catch let error {
            throw error
        }
    }
}

