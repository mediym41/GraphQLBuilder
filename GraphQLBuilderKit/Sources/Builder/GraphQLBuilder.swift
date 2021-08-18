//
//  GraphQLBuilder.swift
//  Prom Покупки
//
//  Created by v.vasylyda on 21.05.2020.
//  Copyright © 2020 UAProm. All rights reserved.
//

import Foundation

public struct GraphQLBuilder {
    
    @available(*, deprecated, message: "Use buildQueryParams(operation:) instead")
    public static func buildQueryString(operation: GraphQLOperation) throws -> String {
        let config = GraphQLBuilderConfig()
        return try operation.asGraphQLBuilderString(config: config)
    }
    
    public static func buildQueryParams(operation: GraphQLOperation) throws -> [String: String] {
        var result: [String: String] = [:]
        
        let config = GraphQLBuilderConfig()
        result["query"] = try operation.asGraphQLBuilderString(config: config)
        
        if let operationName = operation.alias {
            result["operationName"] = operationName
        }
        
        if !operation.variables.isEmpty {
            let encoder = GraphQLValueEncoder()
            encoder.shouldWrapKeys = false
            encoder.shouldEncodeNils = false
            
            let container = VariablesContainer(variables: operation.variables)
            if let encodedVariables: String = try encoder.encode(value: container) {
                result["variables"] = encodedVariables
            }
        }

        return result        
    }
    
    public static func buildRequestData(operation: GraphQLOperation) throws -> Data? {
        let encoder = GraphQLValueEncoder()
        encoder.shouldWrapKeys = true
        encoder.shouldEncodeNils = true
        
        let config = GraphQLBuilderConfig()
        try encoder.setUserInfo(graphQLBuilderConfig: config)
        
        return try encoder.encode(value: operation)
    }
    
    public static func buildRequestString(operation: GraphQLOperation) throws -> String? {
        let encoder = GraphQLValueEncoder()
        encoder.shouldWrapKeys = true
        encoder.shouldEncodeNils = true
        
        let config = GraphQLBuilderConfig()
        try encoder.setUserInfo(graphQLBuilderConfig: config)
        
        return try encoder.encode(value: operation)
    }
}

