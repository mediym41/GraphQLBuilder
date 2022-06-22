//
//  CraphQLQuery.swift
//  Prom
//
//  Created by v.vasylyda on 21.05.2020.
//  Copyright © 2020 UAProm. All rights reserved.
//

import Foundation

public final class GraphQLOperation: Encodable {
    
    public enum Kind: String {
        case query = "query"
        case mutation = "mutation"
        case none = ""
    }
    
    let kind: Kind
    let alias: String?
    var variables: [GraphQLVariable]
    var fields: [GraphQLFieldConvertible]
    var fragments: [GraphQLFragment]
    
    public init(kind: Kind = .query, alias: String? = nil, variables: [GraphQLVariable] = [], fields: [GraphQLFieldConvertible] = [], fragments: [GraphQLFragment] = []) {
        self.kind = kind
        self.alias = alias
        self.variables = variables
        self.fields = fields
        self.fragments = fragments
    }
    
    public init<Key: RawRepresentable>(kind: Kind = .query, alias: Key, variables: [GraphQLVariable] = [], fields: [GraphQLFieldConvertible] = [], fragments: [GraphQLFragment] = []) where Key.RawValue == String {
        self.kind = kind
        self.alias = alias.rawValue
        self.variables = variables
        self.fields = fields
        self.fragments = fragments
    }
    
    public init(kind: Kind = .query, alias: String? = nil, @GraphQLFieldBuilder fieldsBlock: () -> [GraphQLFieldConvertible]) {
        self.kind = kind
        self.alias = alias
        self.variables = []
        self.fields = fieldsBlock()
        self.fragments = []
    }
    
    public init<Key: RawRepresentable>(kind: Kind = .query, alias: Key, @GraphQLFieldBuilder fieldsBlock: () -> [GraphQLFieldConvertible]) where Key.RawValue == String {
        self.kind = kind
        self.alias = alias.rawValue
        self.variables = []
        self.fields = fieldsBlock()
        self.fragments = []
    }
    
    // MARK: - Encoding
    
    enum CodingKeys: String, CodingKey {
        case query
        case operationName
        case variables
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let graphQLBuilderConfig = try fetchBuilderConfig(from: encoder.userInfo)
        let encodedQueryString = try asGraphQLBuilderString(config: graphQLBuilderConfig)
        try container.encode(encodedQueryString, forKey: .query)
        
        try container.encodeIfPresent(alias, forKey: .operationName)
        
        let variablesEncoder = container.superEncoder(forKey: .variables)
        
        for variable in variables {
            try variable.encode(to: variablesEncoder)
        }
    }
    
    private func fetchBuilderConfig(from userInfo: [CodingUserInfoKey: Any]) throws -> GraphQLBuilderConfig {
        let key: CodingUserInfoKey = try .makeGraphQLBuilderConfigKey()
        
        guard let config = userInfo[key] as? GraphQLBuilderConfig else {
            throw GraphBuilderError.failedToFetchGraphQLBuilderConfig
        }
        
        return config
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
    
    @discardableResult public func with(fields: [GraphQLFieldConvertible]) -> Self {
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
    public func asGraphQLBuilderString(config: GraphQLBuilderConfig = .default) throws -> String {
        var result = kind.rawValue
        
        if let alias = alias {
            if kind != .none {
                result += " "
            }
            
            result += alias
        }
        
        if !variables.isEmpty {
            result += "(\(variables.map { "$\($0.key):\($0.rawType)" }.joined(separator: ",")))"
        }
        
        let allFieldConvertible: [GraphQLFieldConvertible] = fields + fragments
        
        result += "{\(try allFieldConvertible.map { try $0.asGraphQLFieldString(config: config) }.joined(separator: " "))}"
        
        if !fragments.isEmpty {
            result += "\(try fragments.map { try $0.asGraphQLBuilderString(config: config) }.joined(separator: " "))"
        }
        
        return result
    }

    // MARK: Debug
    
    public func asPrettyGraphQLBuilderString(offset: Int = 2, config: GraphQLBuilderConfig = .default) throws -> String {
        var result = kind.rawValue
        
        if let alias = alias {
            if kind != .none {
                result += " "
            }
            
            result += alias
        }
        
        if !variables.isEmpty {
            result += " (\(variables.map { "$\($0.key): \($0.rawType)" }.joined(separator: ", ")))"
        }
        
        let encodedFields = try fields.map { field in
            return try field.asPrettyGraphQLFieldString(level: 1, offset: offset, config: config)
        }
        result += " {\n\(encodedFields.joined(separator: "\n"))\n}"
        
        if !fragments.isEmpty {
            let encodedFragments = try fragments.map { fragment in
                return try fragment.asPrettyGraphQLBuilderString(level: 1, offset: offset, config: config)
            }
            result += "\n\n\(encodedFragments.joined(separator: "\n\n"))"
        }
        
        return result
    }
}
