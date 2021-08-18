//
//  CoreSingleValueContainer.swift
//  GraphQLBuilderKit
//
//  Created by Mediym on 1/17/21.
//

final class CoreSingleValueEncodingContainer: SingleValueEncodingContainer {
    var codingPath: [CodingKey] = []
    
    var data: SingleValueContainerResult
    var config: CoreEncoder.Config
    
    init(data: SingleValueContainerResult, config: CoreEncoder.Config) {
        self.data = data
        self.config = config
    }
    
    func encodeNil() throws {
        data = .init()
    }
    
    func encode(_ value: Bool) throws {
        data.encode(value: value)
    }
    
    func encode(_ value: String) throws {
        data.encode(value: value, useQuotes: true)
    }
    
    func encode(_ value: Double) throws {
        data.encode(value: value)
    }
    
    func encode(_ value: Float) throws {
        data.encode(value: value)
    }
    
    func encode(_ value: Int) throws {
        data.encode(value: value)
    }
    
    func encode(_ value: Int8) throws {
        data.encode(value: value)
    }
    
    func encode(_ value: Int16) throws {
        data.encode(value: value)
    }
    
    func encode(_ value: Int32) throws {
        data.encode(value: value)
    }
    
    func encode(_ value: Int64) throws {
        data.encode(value: value)
    }
    
    func encode(_ value: UInt) throws {
        data.encode(value: value)
    }
    
    func encode(_ value: UInt8) throws {
        data.encode(value: value)
    }
    
    func encode(_ value: UInt16) throws {
        data.encode(value: value)
    }
    
    func encode(_ value: UInt32) throws {
        data.encode(value: value)
    }
    
    func encode(_ value: UInt64) throws {
        data.encode(value: value)
    }
    
    func encode<T>(_ value: T) throws where T: Encodable {
        let encoder = CoreEncoder(config: config)
        try value.encode(to: encoder)
        
        if let encodedValue = encoder.data.value {
            data.value = encodedValue
        }
    }
}
