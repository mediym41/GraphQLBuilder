//
//  CodingUserInfoKey+Extensions.swift
//  
//
//  Created by Дмитрий Пащенко on 28.01.2021.
//


public extension CodingUserInfoKey {
    
    static func makeGraphQLBuilderConfigKey() throws -> CodingUserInfoKey {
        guard let key = CodingUserInfoKey(rawValue: graphQLBuilderConfigKeyRawValue) else {
            throw GraphBuilderError.failedToCreateConfigCodingUserInfoKey
        }
        
        return key
    }
    
}

extension CodingUserInfoKey {
    
    static var graphQLBuilderConfigKeyRawValue: String {
        return "GraphQLBuilderConfigKey"
    }
    
}
