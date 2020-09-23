//
//  GraphBuilderError.swift
//  Prom
//
//  Created by v.vasylyda on 09.06.2020.
//  Copyright © 2020 UAProm. All rights reserved.
//

import Foundation

// MARK: - GraphBuilderError
public enum GraphBuilderError: Int {
    // Network
    case stringFromDictSerializationFailed = 20000
    
    // Static
    public static var domain: String {
        return "GraphBuilderError"
    }
    
    public static func error(for errorType: GraphBuilderError) -> NSError {
        switch errorType {
        case .stringFromDictSerializationFailed:
            return NSError(domain: domain, code: GraphBuilderError.stringFromDictSerializationFailed.rawValue, userInfo: [NSLocalizedDescriptionKey: "String from dict serialization error."])
        }
    }
}
