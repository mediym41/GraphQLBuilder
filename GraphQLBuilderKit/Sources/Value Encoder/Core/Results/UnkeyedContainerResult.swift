//
//  UnkeyedContainerResult.swift
//  
//
//  Created by Mediym on 1/15/21.
//

final class UnkeyedContainerResult {
    var values: [ContainerResult]

    init(values: [ContainerResult] = []) {
        self.values = values
    }
}

// MARK: - Expressible By Literal

extension UnkeyedContainerResult: ExpressibleByArrayLiteral {
    convenience init(arrayLiteral elements: ContainerResult...) {
        self.init(values: elements)
    }
}
