//
//  GraphQLBuilderConvertible.swift
//  FunctionalGraph
//
//  Created by Дмитрий Пащенко on 13.09.2020.
//  Copyright © 2020 Дмитрий Пащенко. All rights reserved.
//

public protocol GraphQLBuilderConvertible {
    func asGraphQLBuilderString(config: GraphQLBuilderConfig) throws -> String 
}
