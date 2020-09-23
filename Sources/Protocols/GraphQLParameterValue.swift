//
//  GraphQLParameterValue.swift
//  GraphQLBuilder
//
//  Created by Vitalii Vasylyda on 21.05.2020.
//  Copyright © 2020 Vitalii Vasylyda. All rights reserved.
//

import Foundation

public protocol GraphQLParameterValue {
  var asGraphQLEncodableValue: Any { get }
}

extension String: GraphQLParameterValue {
    public var asGraphQLEncodableValue: Any {
        return self
    }
}

extension Int: GraphQLParameterValue {
    public var asGraphQLEncodableValue: Any {
        return self
    }
}

extension Float: GraphQLParameterValue {
    public var asGraphQLEncodableValue: Any {
        return self
    }
}

extension Double: GraphQLParameterValue {
    public var asGraphQLEncodableValue: Any {
        return self
    }
}

extension Bool: GraphQLParameterValue {
    public var asGraphQLEncodableValue: Any {
        return self
    }
}

extension Array: GraphQLParameterValue where Element: GraphQLParameterValue {
    public var asGraphQLEncodableValue: Any {
        return map { $0.asGraphQLEncodableValue }
    }
}

extension Dictionary: GraphQLParameterValue where Key == String, Value == GraphQLParameterValue {
    public var asGraphQLEncodableValue: Any {
        return mapValues { $0.asGraphQLEncodableValue }
    }
}

extension Optional: GraphQLParameterValue where Wrapped: GraphQLParameterValue {
    public var asGraphQLEncodableValue: Any {
        return self?.asGraphQLEncodableValue as Any
    }
}
