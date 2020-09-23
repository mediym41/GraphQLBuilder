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
    
    public init(alias: String, on type: String, @GraphQLFieldBuilder subfieldBlock: () -> GraphQLFieldConvertible) {
        self.alias = alias
        self.type = type
        self.fields = []
        self.fragments = []
        self.apply(items: [subfieldBlock()])
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
    
    public var asGraphQLFieldString: String {
        return "...\(alias)"
    }
    
}

// MARK: GraphQLBuilderConvertible

extension GraphQLFragment: GraphQLBuilderConvertible {
    
    public var asGraphQLBuilderString: String {
        let subfields: [GraphQLFieldConvertible] = fragments + fields
        return "fragment \(alias) on \(type) {\n\(subfields.map { $0.asGraphQLFieldString }.joined(separator: "\n"))\n}"
    }
    
}

// MARK: - Debug

extension GraphQLFragment {
    
    func asPrettyGraphQLFieldString(level: Int = 0, offset: Int = 2) -> String {
        return String(repeating: " ", count: level * offset) + asGraphQLFieldString
    }
    
    func asPrettyGraphQLBuilderString(level: Int = 0, offset: Int = 2) -> String {
        let fieldStrings = fields.map { $0.asPrettyGraphQLFieldString(level: level + 1, offset: offset) }
        let fragmentStrings = fragments.map { $0.asPrettyGraphQLFieldString(level: level + 1, offset: offset) }
        let allSubfieldsString = (fieldStrings + fragmentStrings).joined(separator: "\n")
        return "fragment \(alias) on \(type) {\n\(allSubfieldsString)\n}"
    }

}
