//
//  GraphQLValueEncoder.swift
//  
//
//  Created by Mediym on 1/15/21.
//

import Foundation

enum GraphQLValueEncoderError: LocalizedError {
    case noData
    
    var errorDescription: String? {
        switch self {
        case .noData:
            return "Nothing to encode"
        }
    }
}

final class GraphQLValueEncoder {

    var shouldWrapKeys: Bool = true
    var shouldEncodeNils: Bool = true
    
    var userInfo: [CodingUserInfoKey: Any] = [:]
    
    /**
     Encode ContainerResult to string representatiion.

     - Parameter result: CoreEncoder result for encoding.
     
     - Returns: A string representation of Encodable entity. Will return nil, if only ContainerResult consists of SingleValuesContainers without value or Encodable entity throws error during encoding.
     */
    public func encode(value: Encodable) throws -> String? {
        
        let config = CoreEncoder.Config()
        let encoder = CoreEncoder(config: config)
        encoder.userInfo = userInfo
        
        try value.encode(to: encoder)
        
        return encoder.data.value.flatMap { encode(result: $0) }
    }
    
    /**
     Encode ContainerResult to data representatiion.

     - Parameter result: CoreEncoder result for encoding.
     
     - Returns: A data representation of Encodable entity. Will return nil, if only ContainerResult consists of SingleValuesContainers without value or Encodable entity throws error during encoding.
     */
    public func encode(value: Encodable) throws -> Data? {
        return try encode(value: value)?.data(using: .utf8)
    }
    
    /**
     Encode ContainerResult to string representatiion.

     - Parameter result: CoreEncoder result for encoding.
     
     - Returns: A string representation of ContainerResult. Will return nil, if only ContainerResult consists of SingleValuesContainers without value.
     */
    private func encode(result: ContainerResult) -> String? {
        switch result {
        case .keyed(let result):
            guard !result.values.isEmpty else {
                return "{}"
            }
            
            let encodedResult = result.values.compactMap { (key: String, value: ContainerResult) -> String? in
                guard let encodedValue = encode(result: value) else {
                    return nil
                }
                
                if shouldWrapKeys {
                    return "\"\(key)\": \(encodedValue)"
                } else {
                    return "\(key): \(encodedValue)"
                }
                
            }.joined(separator: ",")
            
            return "{\(encodedResult)}"
            
        case .unkeyed(let result):
            guard !result.values.isEmpty else {
                return "[]"
            }
            
            let encodedResult = result.values.compactMap(encode(result:)).joined(separator: ",")
            
            return "[\(encodedResult)]"
            
        case .singleValue(let result):
            guard let value = result.value else {
                if shouldEncodeNils {
                    return "null"
                } else {
                    // nothing was passed into single value container, empty state
                    return nil
                }
            }
            
            return encode(result: value)
        
        case .string(let value):
            return value
            
        case .unknown(let result):
            guard let value = result.value else {
                // it is single value container, and nothing was passed into single value container
                return nil
            }
            
            return encode(result: value)
        }
    }
    
    // MARK: - Helpers
    
    func setUserInfo(graphQLBuilderConfig: GraphQLBuilderConfig) throws {
        let key: CodingUserInfoKey = try .makeGraphQLBuilderConfigKey()
        userInfo[key] = graphQLBuilderConfig
    }
}
