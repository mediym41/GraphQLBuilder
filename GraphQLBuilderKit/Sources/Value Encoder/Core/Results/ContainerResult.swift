//
//  ContainerResult.swift
//  
//
//  Created by Mediym on 1/15/21.
//

enum ContainerResult {
    case keyed(KeyedContainerResult)
    case unkeyed(UnkeyedContainerResult)
    case singleValue(SingleValueContainerResult)
    case string(String)
    case unknown(CoreEncoderResult)
    
    static func singleValue(data: CustomStringConvertible, useQuotes: Bool = false) -> ContainerResult {
        return .singleValue(SingleValueContainerResult(value: data, useQuotes: useQuotes))
    }
    
    // MARK: - Private API for unit testing
    
    var asKeyed: KeyedContainerResult? {
        if case .keyed(let value) = self {
            return value
        }
        
        return nil
    }
    
    var asUnkeyed: UnkeyedContainerResult? {
        if case .unkeyed(let value) = self {
            return value
        }
        
        return nil
    }
    
    var asSingle: SingleValueContainerResult? {
        if case .singleValue(let value) = self {
            return value
        }
        
        return nil
    }
    
    var asString: String? {
        if case .string(let value) = self {
            return value
        }
        
        return nil
    }
}

extension ContainerResult: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .keyed(let result):
            let values = result
                .values
                .map { ($0, $1) }
                .sorted(by: { $0.0 < $1.0 })
                .map { "\"\($0)\": \($1.description)" }
                .joined(separator: ", ")
            
            return "{\(values)}"
            
        case .unkeyed(let result):
            let values = result.values.map { $0.description }.joined(separator: ", ")
            return "[\(values)]"
            
        case .singleValue(let result):
            return result.value?.description ?? "null"
        
        case .string(let value):
            return value
            
        case .unknown(let result):
            return result.value?.description ?? "null"
        }
    }
    
    var debugDescription: String {
        switch self {
        case .keyed(let result):
            let values = result
                .values
                .map { ($0, $1) }
                .sorted(by: { $0.0 < $1.0 })
                .map { "\"\($0)\": \($1.debugDescription)" }
                .joined(separator: ", ")
            
            return ".keyed{\(values)}"
            
        case .unkeyed(let result):
            let values = result.values.map { $0.debugDescription }.joined(separator: ", ")
            return ".unkeyed[\(values)]"
            
        case .singleValue(let result):
            let value = result.value?.debugDescription ?? "null"
            return ".single(\(value))"
        
        case .string(let value):
            return ".string(\(value))"
            
        case .unknown(let result):
            return ".unknown(\(result.value?.debugDescription ?? "null"))"
        }
    }
}



extension ContainerResult: Equatable {
    
    static func == (lhs: ContainerResult, rhs: ContainerResult) -> Bool {
        switch (lhs, rhs) {
        case (.keyed(let lhsValue), .keyed(let rhsValue)):
            let lhsKeys = lhsValue.values.keys.map { item in
                return String(item)
            }
            let rhsKeys = rhsValue.values.keys.map { item in
                return String(item)
            }
            
            guard lhsKeys.containsSameElements(as: rhsKeys) else {
                return false
            }
            
            let lhsValues = lhsKeys.compactMap { key in
                return lhsValue.values[key]
            }
            let rhsValues = rhsKeys.compactMap { key in
                return rhsValue.values[key]
            }
            
            return lhsValues.containsSameElements(as: rhsValues)
            
        case (.unkeyed(let lhsValue), .unkeyed(let rhsValue)):
            return lhsValue.values.containsSameElements(as: rhsValue.values)
            
        case (.singleValue(let lhsValue), .singleValue(let rhsValue)):
            return lhsValue.value == rhsValue.value
            
        case (.string(let lhsValue), .string(let rhsValue)):
            return lhsValue == rhsValue
            
        // Unwrap optionals
        case (.singleValue(let lhsValue), _):
            return lhsValue.value == rhs
            
        case (_, .singleValue(let rhsValue)):
            return lhs == rhsValue.value
        
        case (.unknown(let lhsValue), .unknown(let rhsValue)):
            return lhsValue.value == rhsValue.value
            
        case (_, .unknown(let rhsValue)):
            return lhs == rhsValue.value
            
        case (.unknown(let lhsValue), _):
            return lhsValue.value == rhs
            
        default:
            return false
        }
    }
}


extension Array where Element: Equatable {
    func containsSameElements(as other: [Element]) -> Bool {
        var otherCopy = other
        
        for item in self {
            if let indexOfItem = otherCopy.firstIndex(of: item) {
                otherCopy.remove(at: indexOfItem)
            } else {
                return false
            }
        }

        return otherCopy.isEmpty
    }
}

// MARK: - Expressible By Literal

extension ContainerResult: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: ContainerResult...) {
        self = .unkeyed(.init(values: elements))
    }
}

extension ContainerResult: ExpressibleByDictionaryLiteral {
    init(dictionaryLiteral elements: (String, ContainerResult)...) {
        self = .keyed(.init(dictionaryItems: elements))
    }
}

extension ContainerResult: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self = .singleValue(SingleValueContainerResult(value: .string(value)))
    }
}

extension ContainerResult: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        self = .singleValue(SingleValueContainerResult(value: .string(String(value))))
    }
}

extension ContainerResult: ExpressibleByFloatLiteral {
    init(floatLiteral value: Double) {
        self = .singleValue(SingleValueContainerResult(value: .string(String(value))))
    }
}

extension ContainerResult: ExpressibleByBooleanLiteral {
    init(booleanLiteral value: Bool) {
        self = .singleValue(SingleValueContainerResult(value: .string(String(value))))
    }
}

extension ContainerResult: ExpressibleByNilLiteral {
    init(nilLiteral: ()) {
        self = .singleValue(nil)
    }
}
