//
//  GraphQLInlineFragment.swift
//  GraphQLBuilderKit
//
//  Created by Дмитрий Пащенко on 22.06.2022.
//

import Foundation

public final class GraphQLInlineFragment {
    public let type: String
    public var fields: [GraphQLFieldConvertible]
  
    public init(on type: String, fields: [GraphQLFieldConvertible]) {
        self.type = type
        self.fields = fields
    }
    
    public init(on type: String, @GraphQLFieldBuilder subfieldsBlock: () -> [GraphQLFieldConvertible]) {
        self.type = type
        self.fields = subfieldsBlock()
    }
}

// MARK: - GraphQLFieldConvertible

extension GraphQLInlineFragment: GraphQLFieldConvertible {
    public func asGraphQLFieldString(config: GraphQLBuilderConfig = .default) throws -> String {
        var result: String = "... on \(type)"
        result += "{\(try fields.map { try $0.asGraphQLFieldString(config: config) }.joined(separator: " "))}"
        
        return result
    }
    
    // MARK: - Debug
    public func asPrettyGraphQLFieldString(level: Int = 0, offset: Int = 2, config: GraphQLBuilderConfig = .default) throws -> String {
        let currentOffset = String(repeating: " ", count: level * offset)
        var result: String = "\(currentOffset)... on \(type)"
        

        let fieldsString = try fields.map { field in
            try field.asPrettyGraphQLFieldString(level: level + 1, offset: offset, config: config)
        }.joined(separator: "\n")
        result += " {\n\(fieldsString)\n\(currentOffset)}"
        
        return result
    }
}
