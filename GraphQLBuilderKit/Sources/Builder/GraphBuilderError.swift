//
//  GraphBuilderError.swift
//  Prom
//
//  Created by v.vasylyda on 09.06.2020.
//  Copyright © 2020 UAProm. All rights reserved.
//

import Foundation

// MARK: - GraphBuilderError
public enum GraphBuilderError: LocalizedError {
    case failedToCreateConfigCodingUserInfoKey
    case failedToFetchGraphQLBuilderConfig
    
    public var errorDescription: String? {
        switch self {
        case .failedToCreateConfigCodingUserInfoKey:
            return "Failed to create CodingUserInfoKey with rawValue: \(CodingUserInfoKey.graphQLBuilderConfigKeyRawValue)"
        case .failedToFetchGraphQLBuilderConfig:
            return "Failed to fetch GraphQLBuilderConfig from Encoder.userInfo by CodingUserInfoKey.graphQLBuilderConfigKey"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .failedToCreateConfigCodingUserInfoKey:
            return "Check initialization CodingUserInfoKey with rawValue: \(CodingUserInfoKey.graphQLBuilderConfigKeyRawValue)"
        case .failedToFetchGraphQLBuilderConfig:
            return "Encode GraphQLOperation via GraphQLBuilder or pass GraphQLBuilderConfig to Encoder.userInfo with key: CodingUserInfoKey.graphQLBuilderConfigKey"
        }
    }
    
}
