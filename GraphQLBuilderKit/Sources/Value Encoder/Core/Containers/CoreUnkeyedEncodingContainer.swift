//
//  CoreUnkeyedEncodingContainer.swift
//  GraphQLBuilderKit
//
//  Created by Mediym on 1/15/21.
//

final class CoreUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    
    var codingPath: [CodingKey] = []
    private(set) var count: Int = 0
    
    var data: UnkeyedContainerResult
    var config: CoreEncoder.Config

    init(data: UnkeyedContainerResult, config: CoreEncoder.Config) {
        self.data = data
        self.config = config
    }
    
    func encodeNil() throws {
        data.values.append(nil)
    }
    
    func encode(_ value: Bool) throws {
        data.values.append(.singleValue(data: value))
    }
    
    func encode(_ value: String) throws {
        data.values.append(.singleValue(data: value, useQuotes: true))
    }
    
    func encode(_ value: Double) throws {
        data.values.append(.singleValue(data: value))
    }
    
    func encode(_ value: Float) throws {
        data.values.append(.singleValue(data: value))
    }
    
    func encode(_ value: Int) throws {
        data.values.append(.singleValue(data: value))
    }
    
    func encode(_ value: Int8) throws {
        data.values.append(.singleValue(data: value))
    }
    
    func encode(_ value: Int16) throws {
        data.values.append(.singleValue(data: value))
    }
    
    func encode(_ value: Int32) throws {
        data.values.append(.singleValue(data: value))
    }
    
    func encode(_ value: Int64) throws {
        data.values.append(.singleValue(data: value))
    }
    
    func encode(_ value: UInt) throws {
        data.values.append(.singleValue(data: value))
    }
    
    func encode(_ value: UInt8) throws {
        data.values.append(.singleValue(data: value))
    }
    
    func encode(_ value: UInt16) throws {
        data.values.append(.singleValue(data: value))
    }
    
    func encode(_ value: UInt32) throws {
        data.values.append(.singleValue(data: value))
    }
    
    func encode(_ value: UInt64) throws {
        data.values.append(.singleValue(data: value))
    }
    
    func encode<T>(_ value: T) throws where T: Encodable {
        let encoder = CoreEncoder()
        try value.encode(to: encoder)
        
        if let encodedValue = encoder.data.value {
            data.values.append(encodedValue)
        }
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        
        let nestedData = KeyedContainerResult()
        data.values.append(.keyed(nestedData))
        
        let container = CoreKeyedEncodingContainer<NestedKey>(data: nestedData, config: config)
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let nestedData = UnkeyedContainerResult()
        data.values.append(.unkeyed(nestedData))
        
        return CoreUnkeyedEncodingContainer(data: nestedData, config: config)
    }
    
    func superEncoder() -> Encoder {
        let nestedData = CoreEncoderResult(value: nil)
        data.values.append(.unknown(nestedData))
        
        return CoreEncoder(data: nestedData, config: config)
    }
    
    
}
