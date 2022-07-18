//
//  NullableArgument.swift
//  
//
//  Created by Дмитрий Пащенко on 18.07.2022.
//

import Foundation

public extension Optional where Wrapped: Encodable {
    var wrapOrNull: Encodable {
        switch self {
        case .some(let value):
            return value
        case .none:
            return StringWithoutQuotes(value: "null")
        }
    }
}
