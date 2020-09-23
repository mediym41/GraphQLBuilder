//
//  GraphQLTypeDescription.swift
//  FunctionalGraph
//
//  Created by Дмитрий Пащенко on 13.09.2020.
//  Copyright © 2020 Дмитрий Пащенко. All rights reserved.
//

public protocol GraphQLTypeDescription {
    static var asGraphQLTypeDescription: String { get }
}

extension GraphQLTypeDescription {
    public static var asGraphQLTypeDescription: String {
        return "\(self)!"
    }
}

extension Optional: GraphQLTypeDescription where Wrapped: GraphQLTypeDescription {
    public static var asGraphQLTypeDescription: String {
        return String(Wrapped.asGraphQLTypeDescription.dropLast())
    }
}

extension Int: GraphQLTypeDescription {}
extension Float: GraphQLTypeDescription {}
extension Double: GraphQLTypeDescription {}
extension String: GraphQLTypeDescription {}
extension Bool: GraphQLTypeDescription {}

extension Array: GraphQLTypeDescription where Element: GraphQLTypeDescription {
    public static var asGraphQLTypeDescription: String {
        return "[\(Element.asGraphQLTypeDescription)]!"
    }
}
