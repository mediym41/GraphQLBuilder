//
//  GraphQLField.swift
//  GraphQLBuilder
//
//  Created by Vitalii Vasylyda on 21.05.2020.
//  Copyright © 2020 Vitalii Vasylyda. All rights reserved.
//

import Foundation

public final class GraphQLField {
    
    let name: String
    let alias: String?
    var variables: [String: GraphQLVariable]
    var arguments: [String: GraphQLParameterValue]
    var fields: [GraphQLField]
    var fragments: [GraphQLFragment]
    
    public init(name: String, alias: String? = nil, variables: [String: GraphQLVariable] = [:], arguments: [String: GraphQLParameterValue] = [:], fields: [GraphQLField] = [], fragments: [GraphQLFragment] = []) {
        self.name = name
        self.alias = alias
        self.variables = variables
        self.arguments = arguments
        self.fields = fields
        self.fragments = fragments
    }
    
    // declarative ui
    public init(name: String, alias: String? = nil, variables: [String: GraphQLVariable] = [:], arguments: [String: GraphQLParameterValue] = [:], @GraphQLFieldBuilder subfieldsBlock: () -> [GraphQLFieldConvertible]) {
        self.name = name
        self.alias = alias
        self.variables = variables
        self.arguments = arguments
        self.fields = []
        self.fragments = []
        self.apply(items: subfieldsBlock())
    }
    
    public init(name: String, alias: String? = nil, variables: [String: GraphQLVariable] = [:], arguments: [String: GraphQLParameterValue] = [:],  @GraphQLFieldBuilder subfieldBlock: () -> GraphQLFieldConvertible) {
        self.name = name
        self.alias = alias
        self.variables = variables
        self.arguments = arguments
        self.fields = []
        self.fragments = []
        self.apply(items: [subfieldBlock()])
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
    
    // MARK: Variables
    
    @discardableResult public func with(variables: [GraphQLVariable]) -> Self {
        for variable in variables {
            self.variables[variable.key] = variable
        }
        
        return self
    }
    
    @discardableResult public func with(variables: [GraphQLVariable?]) -> Self {
        for case let variable? in variables {
            self.variables[variable.key] = variable
        }
        
        return self
    }
    
    @discardableResult public func with(variables: [String: GraphQLVariable]) -> Self {
        for (key, value) in variables {
            self.variables[key] = value
        }
        
        return self
    }
    
    @discardableResult public func with(variables: [String: GraphQLVariable?]) -> Self {
        for (key, value) in variables {
            self.variables[key] = value
        }
        
        return self
    }
    
    // MARK: Arguments
    
    @discardableResult public func with(arguments: [String: GraphQLParameterValue]) -> Self {
        for (key, value) in arguments {
            self.arguments[key] = value
        }
        
        return self
    }
    
    @discardableResult public func with(fields: [GraphQLField]) -> Self {
        self.fields.append(contentsOf: fields)
        return self
    }
    
}

// MARK: - GraphQLBuilderConvertible protocol

extension GraphQLField: GraphQLFieldConvertible {
    
    public var asGraphQLFieldString: String {
        var result: String = ""
        
        if let alias = alias {
            result += "\(alias): \(name)"
        } else {
            result += name
        }
        
        var parametersList: [String] = []
        
        for (key, value) in variables {
            parametersList.append("\(key): $\(value.key)")
        }
        
        for (key, value) in arguments {
            parametersList.append("\(key): \(value)")
        }
        
        if !parametersList.isEmpty {
            result += "(\(parametersList.joined(separator: ", ")))"
        }
        
        if !fields.isEmpty || !fragments.isEmpty   {
            let allSubfields: [GraphQLFieldConvertible] = fields + fragments
            result += "{\n\(allSubfields.map { $0.asGraphQLFieldString }.joined(separator: "\n"))\n}"
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

// MARK: - Debug

extension GraphQLField {
    
    func asPrettyGraphQLFieldString(level: Int = 0, offset: Int = 2) -> String {
    
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
        
        for (key, value) in arguments {
            parametersList.append("\(key): \(value)")
        }
        
        if !parametersList.isEmpty {
            result += "(\(parametersList.joined(separator: ", ")))"
        }
        
        if !fields.isEmpty || !fragments.isEmpty   {
            let fieldStrings = fields.map { $0.asPrettyGraphQLFieldString(level: level + 1, offset: offset) }
            let fragmentStrings = fragments.map { $0.asPrettyGraphQLFieldString(level: level + 1, offset: offset) }
            let allSubfieldsStirng = (fieldStrings + fragmentStrings).joined(separator: "\n")
            result += " {\n\(allSubfieldsStirng)\n\(currentOffset)}"
        }
        
        return result
    }

}
