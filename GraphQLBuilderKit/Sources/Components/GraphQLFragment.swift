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
    public var fields: [GraphQLField]
    public var fragments: [GraphQLFragment]
  
    public init(alias: String, on type: String, fields: [GraphQLField], fragments: [GraphQLFragment] = []) {
        self.alias = alias
        self.type = type
        self.fields = fields
        self.fragments = fragments
    }
    
    public init(alias: String, on type: String, @GraphQLFieldBuilder subfieldsBlock: () -> [GraphQLFieldConvertible]) {
        self.alias = alias
        self.type = type
        self.fields = []
        self.fragments = []
        self.apply(items: subfieldsBlock())
    }
    
    private func apply(items: [GraphQLFieldConvertible]) {
        for item in items {
            switch item {
            case let field as GraphQLField:
                fields.append(field)
            case let fragment as GraphQLFragment:
                fragments.append(fragment)
            default:
                break
            }
        }
    }
}

// MARK: - GraphQLFieldConvertible

extension GraphQLFragment: GraphQLFieldConvertible {
    
    public func asGraphQLFieldString(config: GraphQLBuilderConfig = .default) throws -> String {
        return "...\(alias)"
    }
    
}

// MARK: GraphQLBuilderConvertible

extension GraphQLFragment: GraphQLBuilderConvertible {
    
    public func asGraphQLBuilderString(config: GraphQLBuilderConfig = .default) throws -> String {
        let subfields: [GraphQLFieldConvertible] = fragments + fields
        let encodedSubfields = try subfields.map { try $0.asGraphQLFieldString(config: config) }
        return "fragment \(alias) on \(type) {\(encodedSubfields.joined(separator: " "))}"
    }
    
}

// MARK: - Debug

extension GraphQLFragment {
    
    func asPrettyGraphQLFieldString(level: Int = 0, offset: Int = 2, config: GraphQLBuilderConfig = .default) throws -> String {
        let encodedFieldString = try asGraphQLFieldString(config: config)
        return String(repeating: " ", count: level * offset) + encodedFieldString
    }
    
    func asPrettyGraphQLBuilderString(level: Int = 0, offset: Int = 2, config: GraphQLBuilderConfig = .default) throws -> String {
        let fieldStrings = try fields.map { field in
            try field.asPrettyGraphQLFieldString(level: level + 1, offset: offset, config: config)
        }
        let fragmentStrings = try fragments.map { fragment in
            try fragment.asPrettyGraphQLFieldString(level: level + 1, offset: offset, config: config)
        }
        let allSubfieldsString = (fieldStrings + fragmentStrings).joined(separator: "\n")
        return "fragment \(alias) on \(type) {\n\(allSubfieldsString)\n}"
    }

}
