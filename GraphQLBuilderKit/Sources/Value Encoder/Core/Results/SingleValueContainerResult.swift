//
//  SingleValueContainerResult.swift
//  
//
//  Created by Mediym on 1/15/21.
//

final class SingleValueContainerResult {
    var value: ContainerResult?

    init(value: ContainerResult? = nil) {
        self.value = value
    }
    
    init(value: CustomStringConvertible, useQuotes: Bool = false) {
        if useQuotes {
            self.value = .string("\"\(value.description.escapedSpecialCharacters)\"")
        } else {
            self.value = .string(value.description.escapedSpecialCharacters)
        }
    }
    
    func encode(value: CustomStringConvertible, useQuotes: Bool = false) {
        if useQuotes {
            self.value = .string("\"\(value.description.escapedSpecialCharacters)\"")
        } else {
            self.value = .string(value.description.escapedSpecialCharacters)
        }
    }
}

// MARK: - Exrepssible By Literal

extension SingleValueContainerResult: ExpressibleByStringLiteral {
    convenience init(stringLiteral value: String) {
        self.init(value: value)
    }
}

extension SingleValueContainerResult: ExpressibleByIntegerLiteral {
    convenience init(integerLiteral value: Int) {
        self.init(value: value)
    }
}

extension SingleValueContainerResult: ExpressibleByFloatLiteral {
    convenience init(floatLiteral value: Double) {
        self.init(value: value)
    }
}

extension SingleValueContainerResult: ExpressibleByBooleanLiteral {
    convenience init(booleanLiteral value: Bool) {
        self.init(value: value)
    }
}

extension SingleValueContainerResult: ExpressibleByNilLiteral {
    convenience init(nilLiteral: ()) {
        self.init()
    }
}
