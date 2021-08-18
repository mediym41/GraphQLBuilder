//
//  GraphQLFieldConvertible.swift
//  FunctionalGraph
//
//  Created by Дмитрий Пащенко on 15.09.2020.
//  Copyright © 2020 Дмитрий Пащенко. All rights reserved.
//

public protocol GraphQLFieldConvertible {
    func asGraphQLFieldString(config: GraphQLBuilderConfig) throws -> String
}

@resultBuilder
public struct GraphQLFieldBuilder {
    
    public typealias Expression = GraphQLFieldConvertible
    public typealias Component = [GraphQLFieldConvertible]
    
    public static func buildBlock(_ components: Component...) -> Component {
        return components.flatMap { $0 }
    }
    
    public static func buildExpression(_ expression: Expression) -> Component {
        return [expression]
    }
    
    public static func buildExpression(_ component: Component) -> Component {
        return component
    }
    
    public static func buildIf(_ component: Component?) -> Component {
        return component ?? []
    }
    
    public static func buildEither(first: Component) -> Component {
        return first
    }
    
    public static func buildEither(second: Component) -> Component {
        return second
    }
    
    public static func buildArray(_ components: [Component]) -> Component {
        return components.flatMap({ $0 })
    }
    
}
