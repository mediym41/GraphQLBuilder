//
//  GraphQLField.swift
//  GraphQLBuilder
//
//  Created by Vitalii Vasylyda on 21.05.2020.
//  Copyright © 2020 Vitalii Vasylyda. All rights reserved.
//

import Foundation

public final class GraphQLField {
    
    public static var typename: GraphQLField {
        return .init(name: "__typename")
    }
    
    let name: String
    let alias: String?
    var variables: [String: GraphQLVariable]
    var arguments: [String: Encodable]
    var fields: [GraphQLFieldConvertible]
    
    public init(name: String,
                alias: String? = nil,
                variables: [String: GraphQLVariable] = [:],
                arguments: [String: Encodable] = [:],
                fields: [GraphQLFieldConvertible] = []) {
        self.name = name
        self.alias = alias
        self.variables = variables
        self.arguments = arguments
        self.fields = fields
    }
    
    public init<Key: RawRepresentable>(name: Key,
                                       alias: String? = nil,
                                       variables: [String: GraphQLVariable] = [:],
                                       arguments: [String: Encodable] = [:],
                                       fields: [GraphQLFieldConvertible] = []) where Key.RawValue == String {
        self.name = name.rawValue
        self.alias = alias
        self.variables = variables
        self.arguments = arguments
        self.fields = fields
    }
    
    // declarative ui
    public init(name: String,
                alias: String? = nil,
                variables: [String: GraphQLVariable] = [:],
                arguments: [String: Encodable] = [:],
                @GraphQLFieldBuilder fieldsBlock: () -> [GraphQLFieldConvertible]) {
        self.name = name
        self.alias = alias
        self.variables = variables
        self.arguments = arguments
        self.fields = fieldsBlock()
    }
    
    public init<Key: RawRepresentable>(name: Key,
                                       alias: String? = nil,
                                       variables: [String: GraphQLVariable] = [:],
                                       arguments: [String: Encodable] = [:],
                                       @GraphQLFieldBuilder fieldsBlock: () -> [GraphQLFieldConvertible]) where Key.RawValue == String {
        self.name = name.rawValue
        self.alias = alias
        self.variables = variables
        self.arguments = arguments
        self.fields = fieldsBlock()
    }
    
    // MARK: - Convenience methods for build query
            
    // MARK: Fields
    
    @discardableResult public func with(fields: [GraphQLFieldConvertible]) -> Self {
        self.fields.append(contentsOf: fields)
        return self
    }
    
    // MARK: Arguments, static flow
    
    @discardableResult public func with(arguments: [String: Encodable?]) -> Self {
        for (key, value) in arguments {
            self.arguments[key] = value
        }
        
        return self
    }
    
    // MARK: Variables, dynamic flow
    
    @discardableResult public func with(variables: [String: GraphQLVariable?]) -> Self {
        for (key, value) in variables {
            self.variables[key] = value
        }
        
        return self
    }
    
}

// MARK: - GraphQLBuilderConvertible protocol

extension GraphQLField: GraphQLFieldConvertible {
    
    public func asGraphQLFieldString(config: GraphQLBuilderConfig = .default) throws -> String {
        var result: String = ""
        
        if let alias = alias {
            result += "\(alias):\(name)"
        } else {
            result += name
        }
        
        var parametersList: [String] = []
        
        for (key, value) in variables {
            parametersList.append("\(key):$\(value.key)")
        }
        
        // Arguments
        
        let encoder = GraphQLValueEncoder()
        encoder.shouldWrapKeys = false
        encoder.shouldEncodeNils = false
        
        for (key, value) in arguments {
            do {
                guard let encodedValue: String = try encoder.encode(value: value) else {
                    continue
                }

                parametersList.append("\(key):\(encodedValue)")
            } catch {
                let debugDescription = "Failed to encode argument value in GraphQLField.asGraphQLFieldString()"
                let context = EncodingError.Context(codingPath: [FlexibleCodingKey(key: key)],
                                                    debugDescription: debugDescription,
                                                    underlyingError: error)
                throw EncodingError.invalidValue(value, context)
            }
        }
        
        if !parametersList.isEmpty {
            result += "(\(parametersList.joined(separator: ",")))"
        }
        
        if !fields.isEmpty {
            result += "{\(try fields.map { try $0.asGraphQLFieldString(config: config) }.joined(separator: " "))}"
        }
        
        return result
    }
    
    // MARK: - Debug
    
    public func asPrettyGraphQLFieldString(level: Int = 0, offset: Int = 2, config: GraphQLBuilderConfig = .default) throws -> String {
    
        let currentOffset = String(repeating: " ", count: level * offset)
        
        var result: String = currentOffset
        
        if let alias = alias {
            result += "\(alias): \(name)"
        } else {
            result += name
        }
        
        var parametersList: [String] = []
        
        for (key, value) in variables {
            parametersList.append("\(key): $\(value.key)")
        }
        
        let encoder = GraphQLValueEncoder()
        encoder.shouldWrapKeys = false
        encoder.shouldEncodeNils = false
        
        for (key, value) in arguments {
            do {
                guard let encodedValue: String = try encoder.encode(value: value) else {
                    continue
                }
                
                parametersList.append("\(key): \(encodedValue)")
            } catch {
                let debugDescription = "Failed to encode argument value in GraphQLField.asGraphQLFieldString()"
                let context = EncodingError.Context(codingPath: [FlexibleCodingKey(key: key)],
                                                    debugDescription: debugDescription,
                                                    underlyingError: error)
                throw EncodingError.invalidValue(value, context)
            }
        }
        
        if !parametersList.isEmpty {
            result += "(\(parametersList.joined(separator: ", ")))"
        }
        
        if !fields.isEmpty {
            let fieldsString = try fields.map { field in
                try field.asPrettyGraphQLFieldString(level: level + 1, offset: offset, config: config)
            }.joined(separator: "\n")
            result += " {\n\(fieldsString)\n\(currentOffset)}"
        }
        
        return result
    }
}

// MARK: - ExpressibleByStringLiteral

extension GraphQLField: ExpressibleByStringLiteral {
    public convenience init(stringLiteral value: String) {
        self.init(name: value)
    }
}
