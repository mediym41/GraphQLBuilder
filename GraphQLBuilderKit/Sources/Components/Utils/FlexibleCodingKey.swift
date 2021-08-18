//
//  FlexibleCodingKey.swift
//  
//
//  Created by Дмитрий Пащенко on 27.01.2021.
//

import Foundation

struct FlexibleCodingKey: CodingKey, ExpressibleByStringLiteral {
    
    let name: String

    var stringValue: String {
        return name
    }
    
    init(key: String) {
        self.name = key
    }

    init(stringValue: String) {
        self.name = stringValue
    }

    /// Not implemented, don't use it
    var intValue: Int? {
        return nil
    }

    /// Not implemented, don't use it
    init?(intValue: Int) {
        return nil
    }
    
    static func == (lhs: FlexibleCodingKey, rhs: String) -> Bool {
        return lhs.name == rhs
    }
    
    init(stringLiteral value: StringLiteralType) {
        self.name = value
    }
}
