//
//  KeyedContainerResult.swift
//  
//
//  Created by Mediym on 1/15/21.
//

final class KeyedContainerResult {
    var values: [String: ContainerResult]

    init(values: [String: ContainerResult] = [:]) {
        self.values = values
    }
}


// MARK: - Expressible By Literal

extension KeyedContainerResult: ExpressibleByDictionaryLiteral {
    convenience init(dictionaryLiteral elements: (String, ContainerResult)...) {
        self.init(dictionaryItems: elements)
    }
    
    convenience init(dictionaryItems elements: [(String, ContainerResult)]) {
        self.init()
        
        for (key, value) in elements {
            values[key] = value
        }
    }
}
