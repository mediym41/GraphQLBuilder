//
//  CraphQLQuery.swift
//  Prom
//
//  Created by v.vasylyda on 21.05.2020.
//  Copyright © 2020 UAProm. All rights reserved.
//

import Foundation

public final class GraphQLOperation {
    
    public enum Kind: String {
        case query = "query"
        case mutation = "mutation"
    }
    
    let kind: Kind
    let alias: String?
    var variables: [GraphQLVariable]
    var fields: [GraphQLField]
    var fragments: [GraphQLFragment]
    
    public init(kind: Kind = .query, alias: String? = nil, variables: [GraphQLVariable] = [], fields: [GraphQLField] = [], fragments: [GraphQLFragment] = []) {
        self.kind = kind
        self.alias = alias
        self.variables = variables
        self.fields = fields
        self.fragments = fragments
    }
    
    public init(kind: Kind = .query, alias: String? = nil, @GraphQLFieldBuilder requestsBlock: () -> [GraphQLFieldConvertible]) {
        self.kind = kind
        self.alias = alias
        self.variables = []
        self.fields = []
        self.fragments = []
        self.apply(items: requestsBlock())
    }

    public init(kind: Kind = .query, alias: String? = nil, @GraphQLFieldBuilder requestBlock: () -> GraphQLFieldConvertible) {
        self.kind = kind
        self.alias = alias
        self.variables = []
        self.fields = []
        self.fragments = []
        self.apply(items: [requestBlock()])
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
    
    // MARK: - Convenience methods for build query
    @discardableResult public func with(variables: [GraphQLVariable]) -> Self {
        self.variables.append(contentsOf: variables)
        return self
    }
    
    @discardableResult public func with(variables: [GraphQLVariable?]) -> Self {
        for variable in variables {
            guard let variable = variable else {
                continue
            }
            
            self.variables.append(variable)
        }
        
        return self
    }
    
    @discardableResult public func with(fields: [GraphQLField]) -> Self {
        self.fields.append(contentsOf: fields)
        return self
    }
    
    @discardableResult public func with(fragments: [GraphQLFragment]) -> Self {
        self.fragments.append(contentsOf: fragments)
        return self
    }
}

// MARK: - GraphQLBuilderConvertible protocol

extension GraphQLOperation: GraphQLBuilderConvertible {
    public var asGraphQLBuilderString: String {
        var result = kind.rawValue
        
        if let alias = alias {
            result += " \(alias)"
        }
        
        if !variables.isEmpty {
            result += " (\(variables.map { "$\($0.key): \($0.rawType)" }.joined(separator: ",")))"
        }
        
        let allFieldConvertible: [GraphQLFieldConvertible] = fields + fragments
        
        result += " {\n\(allFieldConvertible.map { $0.asGraphQLFieldString }.joined(separator: "\n"))\n}"
        
        if !fragments.isEmpty {
            result += "\n\(fragments.map { $0.asGraphQLBuilderString }.joined(separator: "\n"))"
        }
        
        return result
    }
}

// MARK: - Debug

extension GraphQLOperation {
    public func asPrettyGraphQLBuilderString(offset: Int = 2) -> String {
        var result = kind.rawValue
        
        if let alias = alias {
            result += " \(alias)"
        }
        
        if !variables.isEmpty {
            result += " (\(variables.map { "$\($0.key): \($0.rawType)" }.joined(separator: ", ")))"
        }
        
        result += "{\n\(fields.map { $0.asPrettyGraphQLFieldString(level: 1, offset: offset) }.joined(separator: "\n"))\n}"
        
        if !fragments.isEmpty {
            result += "\n\n\(fragments.map { $0.asPrettyGraphQLBuilderString(level: 1, offset: offset) }.joined(separator: "\n\n"))"
        }
        
        return result
    }
}
