//
//  GraphQLFragment.swift
//  FunctionalGraph
//
//  Created by Дмитрий Пащенко on 13.09.2020.
//  Copyright © 2020 Дмитрий Пащенко. All rights reserved.
//

import Foundation

public final class GraphQLFragment {
    public let alias: String
    public let type: String
    public var fields: [GraphQLFieldConvertible]
  
    public init(alias: String, on type: String, fields: [GraphQLFieldConvertible]) {
        self.alias = alias
        self.type = type
        self.fields = fields
    }
    
    public init(alias: String, on type: String, @GraphQLFieldBuilder fieldsBlock: () -> [GraphQLFieldConvertible]) {
        self.alias = alias
        self.type = type
        self.fields = fieldsBlock()
    }
}

// MARK: - GraphQLFieldConvertible

extension GraphQLFragment: GraphQLFieldConvertible {
    
    public func asGraphQLFieldString(config: GraphQLBuilderConfig = .default) throws -> String {
        return "...\(alias)"
    }
    
    public func asPrettyGraphQLFieldString(level: Int = 0, offset: Int = 2, config: GraphQLBuilderConfig = .default) throws -> String {
        let encodedFieldString = try asGraphQLFieldString(config: config)
        return String(repeating: " ", count: level * offset) + encodedFieldString
    }
    
}

// MARK: GraphQLBuilderConvertible

extension GraphQLFragment: GraphQLBuilderConvertible {
    
    public func asGraphQLBuilderString(config: GraphQLBuilderConfig = .default) throws -> String {
        let encodedSubfields = try fields.map { try $0.asGraphQLFieldString(config: config) }
        return "fragment \(alias) on \(type) {\(encodedSubfields.joined(separator: " "))}"
    }
    
}

// MARK: - Debug

extension GraphQLFragment {
    
    func asPrettyGraphQLBuilderString(level: Int = 0, offset: Int = 2, config: GraphQLBuilderConfig = .default) throws -> String {
        let fieldStrings = try fields.map { field in
            try field.asPrettyGraphQLFieldString(level: level + 1, offset: offset, config: config)
        }
        return "fragment \(alias) on \(type) {\n\(fieldStrings.joined(separator: "\n"))\n}"
    }

}
