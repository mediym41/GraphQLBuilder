//
//  GraphQLFieldConvertible.swift
//  FunctionalGraph
//
//  Created by Дмитрий Пащенко on 15.09.2020.
//  Copyright © 2020 Дмитрий Пащенко. All rights reserved.
//

public protocol GraphQLFieldConvertible {
    var asGraphQLFieldString: String { get }
}

@_functionBuilder
struct GraphQLFieldBuilder {
    
    typealias Expression = GraphQLFieldConvertible
    typealias Component = [GraphQLFieldConvertible]
    
    static func buildBlock(_ components: Component...) -> Component {
        return components.flatMap { $0 }
    }
    
    static func buildExpression(_ expression: Expression) -> Component {
        return [expression]
    }
    
    static func buildExpression(_ component: Component) -> Component {
        return component
    }
    
    static func buildIf(_ component: Component?) -> Component {
        return component ?? []
    }
    
    static func buildEither(first: Component) -> Component {
        return first
    }
    
    static func buildEither(second: Component) -> Component {
        return second
    }
    
}
